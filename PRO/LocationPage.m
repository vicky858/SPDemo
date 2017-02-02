//
//  LocationPage.m
//  PRO
//
//  Created by vignesh on 1/31/17.
//  Copyright © 2017 vignesh. All rights reserved.
//

#import "LocationPage.h"

@interface LocationPage ()
{
    NSString *StrHip;
    NSString *StrKnee;
    NSMutableArray *LocationArray;
}

@end

@implementation LocationPage
//@synthesize hip_out,knee_out;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    LocationArray=[[NSMutableArray alloc]init];
    StrHip=@"Hip";
    StrKnee=@"Knee";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(int )patientCount{
    int totCt = 0;
    NSString *strQry = [NSString stringWithFormat:@"select count(rowid) as totCount from Location"];
    SQLiteManager *dbManage = [[SQLiteManager alloc] init];
    FMResultSet *result = [dbManage ExecuteQuery:strQry];
    if ([result next]) {
        totCt = [result intForColumn:@"totCount"];
    }
    return totCt;
}

- (IBAction)Location_Hip_btn:(id)sender
{
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    StrHip=@"Hip";
    SQLiteManager *sqlMng=[[SQLiteManager alloc]init];
    static NSString *strQry=@"INSERT INTO Location(Loct_Name,Patient_id)VALUES(?,?)";
    LocationArray=[[NSMutableArray alloc]init];
    [LocationArray addObject:StrHip];
    [LocationArray addObject:[NSString stringWithFormat:@"%d_%@",[self patientCount]+1,currentDeviceId]];
    [sqlMng ExecuteInsertQuery:strQry withCollectionOfValues:LocationArray];
}

- (IBAction)Location_Knee_btn:(id)sender
{
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    StrKnee=@"Knee";
    SQLiteManager *sqlMng=[[SQLiteManager alloc]init];
    static NSString *strQry=@"INSERT INTO Location(Loct_Name,Patient_id)VALUES(?,?)";
    
    LocationArray=[[NSMutableArray alloc]init];
    [LocationArray addObject:StrKnee];
    [LocationArray addObject:[NSString stringWithFormat:@"%d_%@",[self patientCount]+1,currentDeviceId]];
    
    [sqlMng ExecuteInsertQuery:strQry withCollectionOfValues:LocationArray];
    
}
@end

