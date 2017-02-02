//
//  PatientListTable.m
//  PRO
//
//  Created by vignesh on 1/31/17.
//  Copyright © 2017 vignesh. All rights reserved.
//

#import "PatientListTable.h"
#import "SQLiteManager.h"
#import "FMDatabase.h"
#import "PatientHistry.h"
#import "PatientReport.h"
#import <QuartzCore/QuartzCore.h>
#import <MultipeerConnectivity/MCBrowserViewController.h>
#import "SessionContainer.h"
#import "Transcript.h"
#import "THMultipeer/THMultipeer.h"

@import MultipeerConnectivity;


NSString * const kNSDefaultDisplayName = @"displayNameKey";
NSString * const kNSDefaultServiceType = @"serviceTypeKey";


@interface PatientListTable ()<MCBrowserViewControllerDelegate, UITextFieldDelegate, SessionContainerDelegate, UINavigationControllerDelegate,UISearchBarDelegate,THMultipeerDelegate,THMultipeerSessionDelegate>

{
    NSMutableArray *PatientListArry;
    NSMutableArray *JoinDataArray;
    NSMutableArray *myArray;
    NSMutableArray *DeleteArray;
    UIImageView *recipeImageView;
}

+ (NSData *) base64DataFromString:(NSString *)string;


@end

@implementation PatientListTable

@synthesize filtereddata,searchBar,isFiltered;

@synthesize rehreshout,transcripts;

@synthesize addNewOut;

@synthesize tblPatientList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.layer.borderColor = [[UIColor greenColor]CGColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"504080170.jpeg"]];
    searchBar.delegate=(id)self;
    filtereddata=[[NSMutableArray alloc]init];
    myArray=[[NSMutableArray alloc]init];
    DeleteArray=[[NSMutableArray alloc]init];
    
    [myArray addObject:[UIImage imageNamed:@"pat_2N@2x.png"]];
    [myArray addObject:[UIImage imageNamed:@"pat_5n@2x.png"]];
    [myArray addObject:[UIImage imageNamed:@"pat_6@2x.png"]];
    [myArray addObject:[UIImage imageNamed:@"pat_7@2x"]];
    [myArray addObject:[UIImage imageNamed:@"pat_8@2x"]];
    [myArray addObject:[UIImage imageNamed:@"pat_9@2x"]];
    [myArray addObject:[UIImage imageNamed:@"pat_10@2x"]];
    [myArray addObject:[UIImage imageNamed:@"Untitled-1.png"]];
    
    
    // Init transcripts array to use as table view data source
    
    transcripts = [NSMutableArray new];
    _imageNameIndex = [NSMutableDictionary new];
    JoinDataArray=[[NSMutableArray alloc]init];
    PatientListArry=[[NSMutableArray alloc]init];
    
    
    
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"Name :%@",[[device identifierForVendor]UUIDString]);
    UIDevice *deviceInfo = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    NSString *DisplayName=[NSString stringWithFormat:@"[%@]-%@",deviceInfo.name,currentDeviceId];
    self.displayName=DisplayName;
    self.serviceType=@"SolvEdge";
    [self createSession];
    [tblPatientList reloadData];
    NSString *Statuslbl=[NSString stringWithFormat:@"%@ Not Connected",deviceInfo.name];
    _devicename.text=Statuslbl;
    
    tblPatientList.backgroundColor=[UIColor clearColor];
    
    
    rehreshout.layer.cornerRadius = 6.5f;
    rehreshout.layer.borderWidth=2;
    rehreshout.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    
    addNewOut.layer.cornerRadius = 6.5f;
    addNewOut.layer.borderWidth=2;
    addNewOut.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    
    //    THMultipeer *thmul=[THMultipeer me];
    //
    //    thmul.serviceType = @"thkeen-Num";
    //
    //    NSDictionary *nsdict=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",deviceInfo.model], @"model",nil];
    //    thmul.info =nsdict;
    //    [thmul broadcast];
    
}
-(void)alertForDeletePat:(NSString *)msg
{
    
    NSString *str=[NSString stringWithFormat:@"'From' %@",msg];
    UIAlertController *alertNew=[UIAlertController alertControllerWithTitle:@"Patient Deleted" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *nobutton=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }];
    
    [alertNew addAction:nobutton];
    [self presentViewController:alertNew animated:YES completion:nil];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self getDataFormDB];
    [tblPatientList reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getDataFormDB{
    
    [JoinDataArray removeAllObjects];
    [PatientListArry removeAllObjects];
    [filtereddata removeAllObjects];
    
    SQLiteManager *dbmang=[[SQLiteManager alloc]init];
    FMResultSet *fmr=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM PatientTable"]];
    while ([fmr next])
    {
        PatientHistry *ph=[[PatientHistry alloc]init];
        ph.patientid=[fmr stringForColumn:@"Patient_id"];
        ph.patientname=[fmr stringForColumn:@"PatientName"];
        ph.dob=[fmr stringForColumn:@"Dob"];
        ph.gender=[fmr stringForColumn:@"Gender"];
        ph.dataForImag=[fmr dataForColumn:@"Img_data"];
        [JoinDataArray addObject:ph];
    }
    for (PatientHistry *ph in JoinDataArray)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM Location where Patient_id='%@'",ph.patientid];
        fmr=[dbmang ExecuteQuery:query];
        
        while ([fmr next])
        {
            ph.locationName=[fmr stringForColumn:@"Loct_Name"];
        }
        fmr=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM SurveyResult where Patient_id='%@'",ph.patientid]];
        while ([fmr next])
        {
            ph.surveyname=[fmr stringForColumn:@"SurveyName"];
            ph.answer=[fmr stringForColumn:@"Answer"];
        }
    }
    
    fmr=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT PatientName FROM PatientTable"]];
    while ([fmr next])
    {
        [PatientListArry addObject:[NSString stringWithFormat:@"%@",[fmr stringForColumn:@"PatientName"]]];
        
    }
    filtereddata = [JoinDataArray mutableCopy];
    [tblPatientList reloadData];
}

//get data from db use of Report Generation...

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    
    NSInteger rowcount;
    rowcount=filtereddata.count;
    return rowcount;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"Cell";
    tableView.layoutMargins=UIEdgeInsetsZero;
    tableView.separatorInset=UIEdgeInsetsZero;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell==nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    recipeImageView=(UIImageView *)[cell viewWithTag:100];
    recipeImageView.layer.cornerRadius=40.5f;
    recipeImageView.layer.masksToBounds = YES;
    
    UILabel *ImageNameLabel = (UILabel *)[cell viewWithTag:101];
    PatientHistry *phon=[self.filtereddata objectAtIndex:indexPath.row];
    ImageNameLabel.text = phon.patientname;
    
    UIImage *imgfromdata=[UIImage imageWithData:phon.dataForImag];
    recipeImageView.image=imgfromdata;
    
    UILabel *doblabel = (UILabel *)[cell viewWithTag:102];
    PatientHistry *phonone=[self.filtereddata objectAtIndex:indexPath.row];
    doblabel.text = phonone.dob;
    cell.backgroundColor=[UIColor clearColor];
    
    
    
    UILabel *showreport = (UILabel *)[cell viewWithTag:103];
    showreport.layer.cornerRadius = 6.5f;
    showreport.layer.borderWidth=2;
    showreport.layer.borderColor=[[UIColor colorWithRed:51/255.0f green:92/255.0f blue:255/255.0f alpha:1.0]CGColor];
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PatientHistry *phon=[filtereddata objectAtIndex:indexPath.row];
    NSLog(@" Patient Name : %@",phon.patientname);
    NSLog(@"Date of Birth : %@",phon.dob);
    NSLog(@"   Patient ID : %@",phon.patientid);
    NSLog(@"     Location : %@",phon.locationName);
    NSLog(@"  Survey Name : %@",phon.surveyname);
    NSLog(@"       Answer : %@",phon.answer);
    
    
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PatientReport *controler=[storyboard instantiateViewControllerWithIdentifier:@"popOne"];
    
    controler.NameOfPatient=phon.patientname;
    controler.dobofpatient=phon.dob;
    controler.genPat=phon.gender;
    controler.Idofpatient=phon.patientid;
    controler.locatinOfPatient=phon.locationName;
    controler.nameofSurvey=phon.surveyname;
    controler.surveyanswer=phon.answer;
    controler.dataForimg=phon.dataForImag;
    [self presentViewController:controler animated:YES completion:nil];
    
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    //Share Action
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Share" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        //insert your editAction here
        [self doneBtnPressAction];
    }];
    editAction.backgroundColor = [UIColor lightGrayColor];
    //editAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"screenShare.png"]];
    
    //Delete Action
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your deleteAction here
        PatientHistry *phon=[filtereddata objectAtIndex:indexPath.row];
        [filtereddata removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        SQLiteManager *manager = [[SQLiteManager alloc]init];
        NSString *strQuery = [NSString stringWithFormat:@"Delete from PatientTable where Patient_id= '%@'",phon.patientid];
        [manager ExecuteUpdateQuery:strQuery];
        NSString *strQuery1 = [NSString stringWithFormat:@"Delete from Location where Patient_id= '%@'",phon.patientid];
        [manager ExecuteUpdateQuery:strQuery1];
        NSString *strQuery2 = [NSString stringWithFormat:@"Delete from SurveyResult where Patient_id= '%@'",phon.patientid];
        [manager ExecuteUpdateQuery:strQuery2];
        
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:phon.patientid forKey:@"patientid"];
        [DeleteArray addObject:dictOne];
        [self automentsenddata];
        
    }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    //    deleteAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"share-icons.png"]];
    return @[deleteAction,editAction];
}


//SEARCH BAR DELEGATE METHOD......

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(nonnull NSString *)text
{
    [filtereddata removeAllObjects];
    
    if (text.length > 0) {
        for (PatientHistry *food in JoinDataArray)
        {
            NSRange nameRange=[food.patientname rangeOfString:text options:NSCaseInsensitiveSearch];
            //NSRange descriptionrange=[food.description rangeOfString:text options:NSCaseInsensitiveSearch];
            if (nameRange.location!=NSNotFound)
            {
                [filtereddata addObject:food];
            }
            
        }
    }else{
        filtereddata =[JoinDataArray mutableCopy];
    }
    
    //    }
    [tblPatientList reloadData];
    
}


#pragma mark - MCBrowserViewControllerDelegate methods

// Override this method to filter out peers based on application specific needs
- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    
    //    NSLog(@"Found a nearby advertising peer %@ withDiscoveryInfo %@", peerID, info);
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"peerConnectionChanged" object:info];
    
    return YES;
}

// Override this to know when the user has pressed the "done" button in the MCBrowserViewController

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    [self doneBtnPressAction];
    
}

// Override this to know when the user has pressed the "cancel" button in the MCBrowserViewController

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - SessionContainerDelegate


-(void)reloadTableView
{
    
    [self getDataFormDB];
    [tblPatientList reloadData];
    
}


-(void)displayConnectionStatus:(NSString *)status RecePeer:(NSString *)recePer
{
    
    UIDevice *deviceInfo = [UIDevice currentDevice];
    NSString *str=[NSString stringWithFormat:@"%@ %@ to %@",deviceInfo.name,status,recePer];
    _devicename.text=str;
    
    
}
-(void)deletePatFrom:(NSString *)msg
{
    NSString *str=[NSString stringWithFormat:@"'From'%@",msg];
    UIAlertController *alertNew=[UIAlertController alertControllerWithTitle:@"Patient Deleted" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *nobutton=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                             {
                                 //no action
                             }];
    [alertNew addAction:nobutton];
    [self presentViewController:alertNew animated:YES completion:nil];
    
}

- (void)receivedTranscript:(Transcript *)transcript
{
    // Add to table view data source and update on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self insertTranscript:transcript];
    });
}

- (void)updateTranscript:(Transcript *)transcript
{
    // Find the data source index of the progress transcript
    NSNumber *index = [_imageNameIndex objectForKey:transcript.imageName];
    NSUInteger idx = [index unsignedLongValue];
    // Replace the progress transcript with the image transcript
    [transcripts replaceObjectAtIndex:idx withObject:transcript];
    
}

#pragma mark - private methods

// Private helper method for the Multipeer Connectivity local peerID, session, and advertiser.  This makes the application discoverable and ready to accept invitations
- (void)createSession
{
    // Create the SessionContainer for managing session related functionality.
    self.sessionContainer = [[SessionContainer alloc] initWithDisplayName:self.displayName serviceType:self.serviceType];
    _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:self.serviceType discoveryInfo:nil session:_sessionContainer.session];
    //Set this view controller as the SessionContainer delegate so we can display incoming Transcripts and session state changes in our table view.
    _sessionContainer.delegate = self;
    
}

// Helper method for inserting a sent/received message into the data source and reload the view.
// Make sure you call this on the main thread
- (void)insertTranscript:(Transcript *)transcript
{
    // Add to the data source
    [transcripts addObject:transcript];
    
}


#pragma mark - IBAction methods
// Action method when pressing the "browse" (search icon).  It presents the MCBrowserViewController: a framework UI which enables users to invite and connect to other peers with the same room name (aka service type).
- (IBAction)browseForPeers:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:_displayName];
    NSLog(@"%@",peerID);
    
    // Instantiate and present the MCBrowserViewController
    MCBrowserViewController *browserViewController = [[MCBrowserViewController alloc] initWithServiceType:self.serviceType session:self.sessionContainer.session];
    
    browserViewController.delegate = self;
    browserViewController.minimumNumberOfPeers = kMCSessionMinimumNumberOfPeers;
    browserViewController.maximumNumberOfPeers = kMCSessionMaximumNumberOfPeers;
    
    [self presentViewController:browserViewController animated:YES completion:nil];
    
    
}

// Action method when user presses "send"
- (IBAction)sendMessageTapped:(id)sender
{
    [DeleteArray removeAllObjects];
    NSMutableArray *One=[[NSMutableArray alloc]init];
    NSMutableArray *Two=[[NSMutableArray alloc]init];
    NSMutableArray *Three=[[NSMutableArray alloc]init];
    
    
    SQLiteManager *dbmang=[[SQLiteManager alloc]init];
    FMResultSet *fmr=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM PatientTable"]];
    while ([fmr next])
    {
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:[fmr stringForColumn:@"PatientName"] forKey:@"patientname"];
        [dictOne setObject:[fmr stringForColumn:@"Dob"] forKey:@"Dob"];
        [dictOne setObject:[fmr stringForColumn:@"Gender"] forKey:@"Gender"];
        [dictOne setObject:[fmr stringForColumn:@"Patient_id"] forKey:@"patientid"];
        //convert data TO string
        NSData *dataforimage=[NSData dataWithData:[fmr dataForColumn:@"Img_data"]];
        NSString *str=[NSString base64StringFromData:dataforimage length:0];
        //NSLog(@"value for String :%@",str);
        [dictOne setObject:str    forKey:@"imagedata"];
        [One addObject:dictOne];
    }
    
    FMResultSet *fmr1=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM Location"]];
    while ([fmr1 next])
    {
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:[fmr1 stringForColumn:@"Loct_Name"] forKey:@"locationname"];
        [dictOne setObject:[fmr1 stringForColumn:@"Patient_id"] forKey:@"patientid"];
        [Two addObject:dictOne];
    }
    
    FMResultSet *fmr2=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM SurveyResult"]];
    while ([fmr2 next])
    {
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:[fmr2 stringForColumn:@"SurveyName"] forKey:@"surveyname"];
        [dictOne setObject:[fmr2 stringForColumn:@"Answer"] forKey:@"answer"];
        [dictOne setObject:[fmr2 stringForColumn:@"Patient_id"] forKey:@"patientid"];
        [Three addObject:dictOne];
    }
    NSError *error;
    NSMutableDictionary *dictTwo=[[NSMutableDictionary alloc]init];
    [dictTwo setObject:One forKey:@"PatientTable"];
    [dictTwo setObject:Two forKey:@"Location"];
    [dictTwo setObject:Three forKey:@"Surveyresult"];
    [dictTwo setObject:DeleteArray forKey:@"deletearry"];
    
    //json conversion......
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictTwo options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"$$$$$$$$$$$$$$---JSON DATA---$$$$$$$$$$$$$$$$$$$$$$$");
    Transcript *transcript = [self.sessionContainer sendMessage:jsonString];
    if (transcript)
    {
        [self insertTranscript:transcript];
    }
    
    UIAlertController *objalert=[UIAlertController alertControllerWithTitle:@"Peer Found" message:@"Patient list are Shared" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *nobutton=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }];
    [objalert addAction:nobutton];
    
    [self presentViewController:objalert animated:YES completion:nil];
    
}

- (IBAction)Refresh_btn:(id)sender
{
    
    [self reloadTableView];
    
}

- (IBAction)Btn_Check:(id)sender
{
    UIDevice *deviceInfo = [UIDevice currentDevice];
    THMultipeer *thmul=[THMultipeer me];
    
    thmul.serviceType = @"thkeen-Num";
    thmul.delegate=self;
    NSDictionary *nsdict=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",deviceInfo.model], @"model",nil];
    thmul.info =nsdict;
    [thmul broadcast];
    
    
}


-(void)automentsenddata
{
    
    NSMutableArray *One=[[NSMutableArray alloc]init];
    NSMutableArray *Two=[[NSMutableArray alloc]init];
    NSMutableArray *Three=[[NSMutableArray alloc]init];
    
    
    SQLiteManager *dbmang=[[SQLiteManager alloc]init];
    FMResultSet *fmr=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM PatientTable"]];
    while ([fmr next])
    {
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:[fmr stringForColumn:@"PatientName"] forKey:@"patientname"];
        [dictOne setObject:[fmr stringForColumn:@"Dob"] forKey:@"Dob"];
        [dictOne setObject:[fmr stringForColumn:@"Gender"] forKey:@"Gender"];
        [dictOne setObject:[fmr stringForColumn:@"Patient_id"] forKey:@"patientid"];
        //convert data to string
        NSData *dataforimage=[NSData dataWithData:[fmr dataForColumn:@"Img_data"]];
        NSString *str=[NSString base64StringFromData:dataforimage length:0];
        //NSLog(@"value for String :%@",str);
        [dictOne setObject:str    forKey:@"imagedata"];
        [One addObject:dictOne];
    }
    
    FMResultSet *fmr1=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM Location"]];
    while ([fmr1 next])
    {
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:[fmr1 stringForColumn:@"Loct_Name"] forKey:@"locationname"];
        [dictOne setObject:[fmr1 stringForColumn:@"Patient_id"] forKey:@"patientid"];
        [Two addObject:dictOne];
    }
    
    FMResultSet *fmr2=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM SurveyResult"]];
    while ([fmr2 next])
    {
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:[fmr2 stringForColumn:@"SurveyName"] forKey:@"surveyname"];
        [dictOne setObject:[fmr2 stringForColumn:@"Answer"] forKey:@"answer"];
        [dictOne setObject:[fmr2 stringForColumn:@"Patient_id"] forKey:@"patientid"];
        [Three addObject:dictOne];
    }
    NSError *error;
    NSMutableDictionary *dictTwo=[[NSMutableDictionary alloc]init];
    [dictTwo setObject:One forKey:@"PatientTable"];
    [dictTwo setObject:Two forKey:@"Location"];
    [dictTwo setObject:Three forKey:@"Surveyresult"];
    [dictTwo setObject:DeleteArray forKey:@"deletearry"];
    
    //json conversion......
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictTwo options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"$$$$$$$$$$$$$$---JSON DATA---$$$$$$$$$$$$$$$$$$$$$$$");
    //    NSLog(@"The Json Data:%@",jsonString);
    
    //NSLog(@" dict two---- %@ ",dictTwo);
    
    Transcript *transcript = [self.sessionContainer sendMessage:jsonString];
    if (transcript) {
        // Add the transcript to the table view data source and reload
        [self insertTranscript:transcript];
    }
    UIAlertController *alertNew=[UIAlertController alertControllerWithTitle:@"Patient Deleted" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *nobutton=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                             {   //connect to next location pade view controller
                                 
                             }];
    
    [alertNew addAction:nobutton];
    [self presentViewController:alertNew animated:YES completion:nil];
    
}

-(void)doneBtnPressAction
{
    
    
    NSMutableArray *One=[[NSMutableArray alloc]init];
    NSMutableArray *Two=[[NSMutableArray alloc]init];
    NSMutableArray *Three=[[NSMutableArray alloc]init];
    
    
    SQLiteManager *dbmang=[[SQLiteManager alloc]init];
    FMResultSet *fmr=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM PatientTable"]];
    while ([fmr next])
    {
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:[fmr stringForColumn:@"PatientName"] forKey:@"patientname"];
        [dictOne setObject:[fmr stringForColumn:@"Dob"] forKey:@"Dob"];
        [dictOne setObject:[fmr stringForColumn:@"Gender"] forKey:@"Gender"];
        [dictOne setObject:[fmr stringForColumn:@"Patient_id"] forKey:@"patientid"];
        //convert data TO string
        NSData *dataforimage=[NSData dataWithData:[fmr dataForColumn:@"Img_data"]];
        NSString *str=[NSString base64StringFromData:dataforimage length:0];
        //NSLog(@"value for String :%@",str);
        [dictOne setObject:str    forKey:@"imagedata"];
        [One addObject:dictOne];
    }
    
    FMResultSet *fmr1=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM Location"]];
    while ([fmr1 next])
    {
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:[fmr1 stringForColumn:@"Loct_Name"] forKey:@"locationname"];
        [dictOne setObject:[fmr1 stringForColumn:@"Patient_id"] forKey:@"patientid"];
        [Two addObject:dictOne];
    }
    
    FMResultSet *fmr2=[dbmang ExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM SurveyResult"]];
    while ([fmr2 next])
    {
        NSMutableDictionary *dictOne=[[NSMutableDictionary alloc]init];
        [dictOne setObject:[fmr2 stringForColumn:@"SurveyName"] forKey:@"surveyname"];
        [dictOne setObject:[fmr2 stringForColumn:@"Answer"] forKey:@"answer"];
        [dictOne setObject:[fmr2 stringForColumn:@"Patient_id"] forKey:@"patientid"];
        [Three addObject:dictOne];
    }
    NSError *error;
    NSMutableDictionary *dictTwo=[[NSMutableDictionary alloc]init];
    [dictTwo setObject:One forKey:@"PatientTable"];
    [dictTwo setObject:Two forKey:@"Location"];
    [dictTwo setObject:Three forKey:@"Surveyresult"];
    [dictTwo setObject:DeleteArray forKey:@"deletearry"];
    
    //json conversion......
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictTwo options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"$$$$$$$$$$$$$$---JSON DATA---$$$$$$$$$$$$$$$$$$$$$$$");
    //    NSLog(@"The Json Data:%@",jsonString);
    
    //NSLog(@" dict two---- %@ ",dictTwo);
    
    Transcript *transcript = [self.sessionContainer sendMessage:jsonString];
    if (transcript) {
        // Add the transcript to the table view data source and reload
        [self insertTranscript:transcript];
    }
    UIAlertController *alertNew=[UIAlertController alertControllerWithTitle:@"Patient Shared" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *nobutton=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                             {   //connect to next location pade view controller
                                 
                             }];
    
    [alertNew addAction:nobutton];
    [self presentViewController:alertNew animated:YES completion:nil];
}





//
/**
 *  New peer found, insert to UI
 *
 *  @param peer  MCPeerID
 *  @param name  Device name that was put during the advertisement
 *  @param info  Other info if any
 *  @param index Insert to the appropriate index in the UIwwd
 */
- (void)multipeerNewPeerFound:(MCPeerID*)peerID withName:(NSString*)name andInfo:(NSDictionary*)info atIndex:(NSInteger)index
{
    NSLog(@"%@  %@  %@",peerID,name,info);
    
}
/**
 *  Lost a peer, remove from UI
 *
 *  @param peer  MCPeerID
 *  @param index Index to remove
 */
- (void)multipeerPeerLost:(MCPeerID*)peerID atIndex:(NSInteger)index{
}
/**
 *  All found peers were removed, update UI now
 */
- (void)multipeerAllPeersRemoved{
}

/**
 *  Could not advertising or browsing
 *
 *  @param error
 */
- (void)multipeerDidNotBroadcastWithError:(NSError*)error{
    
}
/**
 *  This is actually a wrapper on didReceiveInvitation but we make use of it as a protocol for sending simple message without having to accept the invitation.
 *
 *  @param info NSDictionary: invitation context
 *  @param peer MCPeerID
 */
- (void)multipeerDidReceiveInfo:(NSDictionary*)info fromPeer:(MCPeerID*)peerID{
    
}

@end
