



@import MultipeerConnectivity;
#import "SessionContainer.h"
#import "Transcript.h"
#import "SQLiteManager.h"
#import "FMDatabase.h"
#import "PatientListTable.h"
#import "NSString+NSStringAdditions.h"
#import "NSData+NSDataAdditions.h"

@interface SessionContainer()
{
    NSMutableArray *PatienttableArray;
    NSMutableArray *LocationArray;
    NSMutableArray *surveyresulrarray;
    
    NSMutableArray *ArrayForEmtyData;
    
    NSMutableArray *arrReceiveDeletePatient;
}
// Framework UI class for handling incoming invitations
@property (retain, nonatomic) MCAdvertiserAssistant *advertiserAssistant;
@end

@implementation SessionContainer

// Session container designated initializer
- (id)initWithDisplayName:(NSString *)displayName serviceType:(NSString *)serviceType
{
    if (self = [super init]) {
        // Create the peer ID with user input display name.  This display name will be seen by other browsing peers
        //        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
        MCPeerID *peerID;
        
        //If there is no PeerID save, create one and save it
        if ([[NSUserDefaults standardUserDefaults] dataForKey:@"PeerID"] == nil)
        {
            peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:peerID] forKey:@"PeerID"];
        }
        //Else, load it
        else
        {
            peerID            = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] dataForKey:@"PeerID"]];
        }
        
        
        // Create the session that peers will be invited/join into.  You can provide an optinal security identity for custom authentication.  Also you can set the encryption preference for the session.
        _session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionRequired];
        // Set ourselves as the MCSessionDelegate
        _session.delegate = self;
        // Create the advertiser assistant for managing incoming invitation
        _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:serviceType discoveryInfo:nil session:_session];
        // Start the assistant to begin advertising your peers availability
        [_advertiserAssistant start];
    }
    return self;
}

// On dealloc we should clean up the session by disconnecting from it.
- (void)dealloc
{
    [_advertiserAssistant stop];
    [_session disconnect];
}

// Helper method for human readable printing of MCSessionState.  This state is per peer.
- (NSString *)stringForPeerConnectionState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected:
            
            //  [self.delegate displayConnectionStatus];
            return @"Connected";
            
        case MCSessionStateConnecting:
            return @"Connecting";
            
        case MCSessionStateNotConnected:
            return @"Disconneted";
    }
}

#pragma mark - Public methods

// Instance method for sending a string bassed text message to all remote peers
- (Transcript *)sendMessage:(NSString *)message
{
    // Convert the string into a UTF8 encoded data
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    // Send text message to all connected peers
    NSError *error;
    [self.session sendData:messageData toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    // Check the error return to know if there was an issue sending data to peers.  Note any peers in the 'toPeers' array argument are not connected this will fail.
    if (error) {
        NSLog(@"Error sending message to peers [%@]", error);
        return nil;
    }
    else {
        // Create a new send transcript
        return [[Transcript alloc] initWithPeerID:_session.myPeerID message:message direction:TRANSCRIPT_DIRECTION_SEND];
    }
}

// Method for sending image resources to all connected remote peers.  Returns an progress type transcript for monitoring tranfer
- (Transcript *)sendImage:(NSURL *)imageUrl
{
    NSProgress *progress;
    // Loop on connected peers and send the image to each
    for (MCPeerID *peerID in _session.connectedPeers) {
        
        //imageUrl = [NSURL URLWithString:@"http://images.apple.com/home/images/promo_logic_pro.jpg"];
        // Send the resource to the remote peer.  The completion handler block will be called at the end of sending or if any errors occur
        progress = [self.session sendResourceAtURL:imageUrl withName:[imageUrl lastPathComponent] toPeer:peerID withCompletionHandler:^(NSError *error) {
            // Implement this block to know when the sending resource transfer completes and if there is an error.
            if (error) {
                NSLog(@"Send resource to peer [%@] completed with Error [%@]", peerID.displayName, error);
            }
            else {
                // Create an image transcript for this received image resource
                Transcript *transcript = [[Transcript alloc] initWithPeerID:_session.myPeerID imageUrl:imageUrl direction:TRANSCRIPT_DIRECTION_SEND];
                [self.delegate updateTranscript:transcript];
            }
        }];
    }
    // Create an outgoing progress transcript.  For simplicity we will monitor a single NSProgress.  However users can measure each NSProgress returned individually as needed
    Transcript *transcript = [[Transcript alloc] initWithPeerID:_session.myPeerID imageName:[imageUrl lastPathComponent] progress:progress direction:TRANSCRIPT_DIRECTION_SEND];
    
    return transcript;
}

//count already data in db
//patienttable....
-(int)patientCount{
    int totCt = 0;
    NSString *strQry = [NSString stringWithFormat:@"select count(rowid) as totCount from PatientTable"];
    SQLiteManager *dbManage = [[SQLiteManager alloc] init];
    FMResultSet *result = [dbManage ExecuteQuery:strQry];
    if ([result next]) {
        totCt = [result intForColumn:@"totCount"];
    }
    return totCt;
}
//Location table.........
-(int)Locationcount{
    int totCt = 0;
    NSString *strQry = [NSString stringWithFormat:@"select count(rowid) as totCount from Location"];
    SQLiteManager *dbManage = [[SQLiteManager alloc] init];
    FMResultSet *result = [dbManage ExecuteQuery:strQry];
    if ([result next]) {
        totCt = [result intForColumn:@"totCount"];
    }
    return totCt;
}
//Surveyresullt table..........
-(int)surveyresultcount{
    int totCt = 0;
    NSString *strQry = [NSString stringWithFormat:@"select count(rowid) as totCount from SurveyResult"];
    SQLiteManager *dbManage = [[SQLiteManager alloc] init];
    FMResultSet *result = [dbManage ExecuteQuery:strQry];
    if ([result next]) {
        totCt = [result intForColumn:@"totCount"];
    }
    return totCt;
}

#pragma mark - MCSessionDelegate methods

// Override this method to handle changes to peer session state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"Peer [%@] changed state to %@", peerID.displayName, [self stringForPeerConnectionState:state]);
    //connection status delegate method
     dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate displayConnectionStatus:[self stringForPeerConnectionState:state] RecePeer:peerID.displayName];
     });
    
    NSString *adminMessage = [NSString stringWithFormat:@"'%@' is %@", peerID.displayName, [self stringForPeerConnectionState:state]];
    // Create an local transcript
    Transcript *transcript = [[Transcript alloc] initWithPeerID:peerID message:adminMessage direction:TRANSCRIPT_DIRECTION_LOCAL];
    
    // Notify the delegate that we have received a new chunk of data from a peer
    [self.delegate receivedTranscript:transcript];
    
}

// MCSession Delegate callback when receiving data from a peer in a given session
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
    ArrayForEmtyData=[[NSMutableArray alloc]init];
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    
    //JOSN Convert
    NSError *jsonError;
    NSData *objectData = [receivedMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dicjson = [NSJSONSerialization JSONObjectWithData:objectData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
    //NSLog(@"---Received message-----:%@",receivedMessage);
    
    //select data from current device DB
    NSMutableArray *PatientArr=[[NSMutableArray alloc]init];
    NSMutableArray *LocationArr=[[NSMutableArray alloc]init];
    NSMutableArray *surveyArr=[[NSMutableArray alloc]init];
    SQLiteManager *sqlMng=[[SQLiteManager alloc]init];
    FMResultSet *fmr=[sqlMng ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM PatientTable"]];
    while ([fmr next])
    {
        NSMutableDictionary *dicLocation = [[NSMutableDictionary alloc] init];
        [dicLocation  setObject:[NSString stringWithFormat:@"%@",[fmr stringForColumn:@"PatientName"]] forKey:@"patientname"];
        [dicLocation  setObject:[NSString stringWithFormat:@"%@",[fmr stringForColumn:@"Dob"]] forKey:@"Dob"];
        [dicLocation  setObject:[NSString stringWithFormat:@"%@",[fmr stringForColumn:@"Gender"]] forKey:@"Gender"];
        [dicLocation  setObject:[NSString stringWithFormat:@"%@",[fmr stringForColumn:@"Patient_id"]] forKey:@"patientid"];
        
        
        NSData *dataforimage=[NSData dataWithData:[fmr dataForColumn:@"Img_data"]];
        NSString *str=[NSString base64StringFromData:dataforimage length:0];
        
        [dicLocation setObject:str forKey:@"imagedata"];
        
        [PatientArr addObject:dicLocation];
        
        //[ArrayForEmtyData addObject:[NSString stringWithFormat:@"%@",[fmr stringForColumn:@"Patient_id"]]];
    }
    FMResultSet *fmr2=[sqlMng ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM Location"]];
    while ([fmr2 next])
    {
        NSMutableDictionary *dicLocation = [[NSMutableDictionary alloc] init];
        [dicLocation  setObject:[NSString stringWithFormat:@"%@",[fmr2 stringForColumn:@"Loct_Name"]] forKey:@"locationname"];
        [dicLocation  setObject:[NSString stringWithFormat:@"%@",[fmr2 stringForColumn:@"Patient_id"]] forKey:@"patientid"];
        
        [LocationArr addObject:dicLocation];
        
        //        [LocationArr addObject:];
        //  [LocationArr addObject:[NSString stringWithFormat:@"%@",[fmr2 stringForColumn:@"Patient_id"]]];
    }
    FMResultSet *fmr3=[sqlMng ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM SurveyResult"]];
    while ([fmr3 next])
    {
        NSMutableDictionary *dictSurvey=[[NSMutableDictionary alloc]init];
        [dictSurvey setObject:[NSString stringWithFormat:@"%@",[fmr3 stringForColumn:@"SurveyName"]] forKey:@"surveyname"];
        [dictSurvey setObject:[NSString stringWithFormat:@"%@",[fmr3 stringForColumn:@"Answer"]] forKey:@"answer"];
        [dictSurvey setObject:[NSString stringWithFormat:@"%@",[fmr3 stringForColumn:@"Patient_id"]] forKey:@"patientid"];
        [surveyArr addObject:dictSurvey];
    }
    
    
    NSMutableArray *arrReceivePatient = [[NSMutableArray alloc] initWithArray:[dicjson objectForKey:@"PatientTable"]];
    NSMutableArray *arrReceiveLocation = [[NSMutableArray alloc] initWithArray:[dicjson objectForKey:@"Location"]];
    NSMutableArray *arrReceiveSurvey = [[NSMutableArray alloc] initWithArray:[dicjson objectForKey:@"Surveyresult"]];
    arrReceiveDeletePatient=[[NSMutableArray alloc]initWithArray:[dicjson objectForKey:@"deletearry"]];
    
    
    //delete same patient name in two device
    for (NSMutableDictionary *DictOld in arrReceiveDeletePatient)
    {
        if ([DictOld valueForKey:@"patientid"])
        {
            SQLiteManager *manager = [[SQLiteManager alloc]init];
            NSString *strQuery = [NSString stringWithFormat:@"Delete from PatientTable where Patient_id= '%@'",[DictOld valueForKey:@"patientid"]];
            [manager ExecuteUpdateQuery:strQuery];
            NSString *strQuery1 = [NSString stringWithFormat:@"Delete from Location where Patient_id= '%@'",[DictOld valueForKey:@"patientid"]];
            [manager ExecuteUpdateQuery:strQuery1];
            NSString *strQuery2 = [NSString stringWithFormat:@"Delete from SurveyResult where Patient_id= '%@'",[DictOld valueForKey:@"patientid"]];
            [manager ExecuteUpdateQuery:strQuery2];
            if ([DictOld valueForKey:@"patientid"]){
                [self.delegate alertForDeletePat:peerID.displayName];}
        }
        
    }
    
    //patient table values comparion...
    
    if (!PatientArr || !PatientArr.count) {
        for (int i=0; i<[arrReceivePatient count]; i++) {
            [self insertPatient:[arrReceivePatient objectAtIndex:i]];
        }
        
        
        
    }else{
        
        NSMutableArray  *arrObject = [[NSMutableArray alloc] init];
        for (int i = 0; i<[PatientArr count]; i++) {
            [arrObject addObject:[[PatientArr objectAtIndex:i] objectForKey:@"patientid"]];
        }
        
        for (NSMutableDictionary *DictOld in arrReceivePatient)
        {
            if (![arrObject containsObject:[DictOld objectForKey:@"patientid"]] ) {
                [self insertPatient:DictOld];
            }
            
        }
        
    }
    //.............
    
    //location table value comparison....
    
    if (!LocationArr || !LocationArr.count) {
        for (int i=0; i<[arrReceiveLocation count]; i++) {
            [self insertLocation:[arrReceiveLocation objectAtIndex:i]];
        }
        
        
        
    }else{
        
        NSMutableArray  *arrObject = [[NSMutableArray alloc] init];
        for (int i = 0; i<[LocationArr count]; i++) {
            [arrObject addObject:[[LocationArr objectAtIndex:i] objectForKey:@"patientid"]];
        }
        
        for (NSMutableDictionary *DictOld in arrReceiveLocation)
        {
            if (![arrObject containsObject:[DictOld objectForKey:@"patientid"]] ) {
                [self insertLocation:DictOld];
            }
            
        }
        
        
    }
    //..............
    //Surveyresult table value comparison....
    
    if (!surveyArr || !surveyArr.count) {
        for (int i=0; i<[arrReceiveSurvey count]; i++) {
            [self insertSurveyResult:[arrReceiveSurvey objectAtIndex:i]];
        }
        
        
        
    }else{
        
        //        if ([surveyArr count] > [arrReceiveSurvey count]) {
        //            NSMutableArray  *arrObject = [[NSMutableArray alloc] init];
        //            for (int i = 0; i<[arrReceiveSurvey count]; i++) {
        //                [arrObject addObject:[[arrReceiveSurvey objectAtIndex:i] objectForKey:@"patientid"]];
        //            }
        //
        //            for (NSMutableDictionary *DictOld in surveyArr)
        //            {
        //                if (![arrObject containsObject:[DictOld objectForKey:@"patientid"]] ) {
        //                    [self insertSurveyResult:DictOld];
        //                }
        //
        //            }
        //        }
        //        else{
        //
        //            NSMutableArray  *arrObject = [[NSMutableArray alloc] init];
        //            for (int i = 0; i<[surveyArr count]; i++) {
        //                [arrObject addObject:[[surveyArr objectAtIndex:i] objectForKey:@"patientid"]];
        //            }
        //
        //            for (NSMutableDictionary *DictOld in arrReceiveSurvey)
        //            {
        //
        //                if (![arrObject containsObject:[DictOld objectForKey:@"patientid"]] ) {
        //                    [self insertSurveyResult:DictOld];
        //                }
        //
        //            }
        //
        //        }
        NSMutableArray  *arrObject = [[NSMutableArray alloc] init];
        for (int i = 0; i<[surveyArr count]; i++) {
            [arrObject addObject:[[surveyArr objectAtIndex:i] objectForKey:@"patientid"]];
        }
        
        for (NSMutableDictionary *DictOld in arrReceiveSurvey)
        {
            
            if (![arrObject containsObject:[DictOld objectForKey:@"patientid"]] ) {
                [self insertSurveyResult:DictOld];
            }
            
        }
        
        
    }
    //..............
    
    // Create an received transcript
    Transcript *transcript = [[Transcript alloc] initWithPeerID:peerID message:receivedMessage direction:TRANSCRIPT_DIRECTION_RECEIVE];
    
    // Notify the delegate that we have received a new chunk of data from a peer
    
    [self.delegate receivedTranscript:transcript];
    
    //delete send device patient..
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate reloadTableView];
    });
    
}
//delete send device patient..

//insert patient table remaing value into db..
-(void)insertPatient:(NSDictionary *)dicPatient
{
    SQLiteManager *sqlMng=[[SQLiteManager alloc]init];
    static NSString *strQry1=@"INSERT INTO PatientTable(PatientName,Dob,Gender,Patient_id,Img_data)VALUES(?,?,?,?,?)";
    
    PatienttableArray=[[NSMutableArray alloc]init];
    [PatienttableArray addObject:[dicPatient valueForKey:@"patientname"]];
    [PatienttableArray addObject:[dicPatient valueForKey:@"Dob"]];
    [PatienttableArray addObject:[dicPatient valueForKey:@"Gender"]];
    [PatienttableArray addObject:[dicPatient valueForKey:@"patientid"]];
    
    NSString *strFromData=[NSString stringWithString:[dicPatient valueForKey:@"imagedata"]];
    
    NSData *data = [NSData base64DataFromString:strFromData];
    [PatienttableArray addObject:data];
    
    //NSData *base64StringOf_my_image = [strFromData base64DataFromString];
    
    [sqlMng ExecuteInsertQuery:strQry1 withCollectionOfValues:PatienttableArray];
    
}
//my code....
//insert location table remaing value into db..
-(void)insertLocation:(NSDictionary *)dicPatient{
    SQLiteManager *sqlMng=[[SQLiteManager alloc]init];
    
    static NSString *strQry1=@"INSERT INTO Location(Loct_Name,Patient_id)VALUES(?,?)";
    
    LocationArray=[[NSMutableArray alloc]init];
    [LocationArray addObject:[dicPatient valueForKey:@"locationname"]];
    [LocationArray addObject:[dicPatient valueForKey:@"patientid"]];
    [sqlMng ExecuteInsertQuery:strQry1 withCollectionOfValues:LocationArray];
}
//insert surveyresult table remaing value into db...
-(void)insertSurveyResult:(NSDictionary *)dicPatient{
    SQLiteManager *sqlMng=[[SQLiteManager alloc]init];
    static NSString *strQry1=@"INSERT INTO SurveyResult(SurveyName,Answer,Patient_id)VALUES(?,?,?)";
    
    surveyresulrarray=[[NSMutableArray alloc]init];
    [surveyresulrarray addObject:[dicPatient valueForKey:@"surveyname"]];
    [surveyresulrarray addObject:[dicPatient valueForKey:@"answer"]];
    [surveyresulrarray addObject:[dicPatient valueForKey:@"patientid"]];
    [sqlMng ExecuteInsertQuery:strQry1 withCollectionOfValues:surveyresulrarray];
}


// MCSession delegate callback when we start to receive a resource from a peer in a given session
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Start receiving resource [%@] from peer %@ with progress [%@]", resourceName, peerID.displayName, progress);
    // Create a resource progress transcript
    Transcript *transcript = [[Transcript alloc] initWithPeerID:peerID imageName:resourceName progress:progress direction:TRANSCRIPT_DIRECTION_RECEIVE];
    // Notify the UI delegate
    [self.delegate receivedTranscript:transcript];
}

// MCSession delegate callback when a incoming resource transfer ends (possibly with error)
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    // If error is not nil something went wrong
    if (error)
    {
        NSLog(@"Error [%@] receiving resource from peer %@ ", [error localizedDescription], peerID.displayName);
    }
    else
    {
        // No error so this is a completed transfer.  The resources is located in a temporary location and should be copied to a permenant locatation immediately.
        // Write to documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *copyPath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], resourceName];
        if (![[NSFileManager defaultManager] copyItemAtPath:[localURL path] toPath:copyPath error:nil])
        {
            NSLog(@"Error copying resource to documents directory");
        }
        else {
            // Get a URL for the path we just copied the resource to
            NSURL *imageUrl = [NSURL fileURLWithPath:copyPath];
            // Create an image transcript for this received image resource
            Transcript *transcript = [[Transcript alloc] initWithPeerID:peerID imageUrl:imageUrl direction:TRANSCRIPT_DIRECTION_RECEIVE];
            [self.delegate updateTranscript:transcript];
        }
    }
}

// Streaming API not utilized in this sample code
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
    NSLog(@"Received data over stream with name %@ from peer %@", streamName, peerID.displayName);
    
}



@end
