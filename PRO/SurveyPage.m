//
//  SurveyPage.m
//  PRO
//
//  Created by vignesh on 1/31/17.
//  Copyright © 2017 vignesh. All rights reserved.
//

#import "SurveyPage.h"

@interface SurveyPage ()
{
    NSString *Answer;
    NSString *NameSurvey;
    NSMutableArray *SurveyArray;
}

@end

@implementation SurveyPage
@synthesize Aneg_out,Apos_out,Bneg_out,Bpos_out,ABneg_out,ABpos_out,Oneg_out,Opos_btn;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nf2pXZp.jpg"]];
    
    
    Aneg_out.layer.borderWidth=2;
    Aneg_out.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    Aneg_out.layer.cornerRadius=4;
    
    Apos_out.layer.borderWidth=2;
    Apos_out.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    Apos_out.layer.cornerRadius=4;
    
    Bneg_out.layer.borderWidth=2;
    Bneg_out.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    Bneg_out.layer.cornerRadius=4;
    
    Bpos_out.layer.borderWidth=2;
    Bpos_out.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    Bpos_out.layer.cornerRadius=4;
    
    ABneg_out.layer.borderWidth=2;
    ABneg_out.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    ABneg_out.layer.cornerRadius=4;
    
    ABpos_out.layer.borderWidth=2;
    ABpos_out.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    ABpos_out.layer.cornerRadius=4;
    
    Oneg_out.layer.borderWidth=2;
    Oneg_out.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    Oneg_out.layer.cornerRadius=4;
    
    Opos_btn.layer.borderWidth=2;
    Opos_btn.layer.borderColor=[[UIColor colorWithRed:50/255.0f green:84/255.0f blue:255/255.0f alpha:1.0]CGColor];
    Opos_btn.layer.cornerRadius=4;
    
    
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
    NSString *strQry = [NSString stringWithFormat:@"select count(rowid) as totCount from SurveyResult"];
    SQLiteManager *dbManage = [[SQLiteManager alloc] init];
    FMResultSet *result = [dbManage ExecuteQuery:strQry];
    if ([result next]) {
        totCt = [result intForColumn:@"totCount"];
    }
    return totCt;
}

-(void)surveyAnswerReload
{
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    SQLiteManager *sqlMng=[[SQLiteManager alloc]init];
    static NSString *strQry=@"INSERT INTO SurveyResult(SurveyName,Answer,Patient_id)VALUES(?,?,?)";
    
    SurveyArray=[[NSMutableArray alloc]init];
    [SurveyArray addObject:NameSurvey];
    [SurveyArray addObject:Answer];
    [SurveyArray addObject:[NSString stringWithFormat:@"%d_%@",[self patientCount]+1,currentDeviceId]];
    [sqlMng ExecuteInsertQuery:strQry withCollectionOfValues:SurveyArray];
}

- (IBAction)AN:(id)sender
{
    Answer=@"A(-) Negative";
    NameSurvey=@"Blood Group";
    [self surveyAnswerReload];
}
- (IBAction)AP:(id)sender
{
    Answer=@"A(+) Postive";
    NameSurvey=@"Blood Group";
    [self surveyAnswerReload];
}
- (IBAction)BN:(id)sender
{
    Answer=@"B(-) Negative";
    NameSurvey=@"Blood Group";
    [self surveyAnswerReload];
}
- (IBAction)BP:(id)sender
{
    Answer=@"B(+) Positive";
    NameSurvey=@"Blood Group";
    [self surveyAnswerReload];
}
- (IBAction)ABN:(id)sender
{
    Answer=@"AB(-) Negative";
    NameSurvey=@"Blood Group";
    [self surveyAnswerReload];
}
- (IBAction)ABP:(id)sender
{
    Answer=@"AB(+) Postive";
    NameSurvey=@"Blood Group";
    [self surveyAnswerReload];
}
- (IBAction)ON:(id)sender
{
    Answer=@"O(-) Negative";
    NameSurvey=@"Blood Group";
    [self surveyAnswerReload];
}
- (IBAction)OP:(id)sender
{
    Answer=@"O(+) Postive";
    NameSurvey=@"Blood Group";
    [self surveyAnswerReload];
}
@end