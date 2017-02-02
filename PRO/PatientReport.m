//
//  PatientReport.m
//  PRO
//
//  Created by vignesh on 1/31/17.
//  Copyright © 2017 vignesh. All rights reserved.
//

#import "PatientReport.h"
#import "PatientListTable.h"
#import "SQLiteManager.h"

@interface PatientReport ()

@end

@implementation PatientReport

@synthesize SurveyName,Answer,home_out,patientImage,genderLbl;

@synthesize PatientName,DateOfBirth,Location;




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    
    patientImage.layer.masksToBounds = YES;
    patientImage.layer.cornerRadius = 20.0;
    
    UILabel *newl= [[UILabel alloc] initWithFrame:CGRectMake(0, patientImage.bounds.size.width-15.5f, patientImage.bounds.size.width, 28)];
    newl.backgroundColor = [UIColor colorWithRed:(73/255.0f) green:(73/255.0f) blue:(73/255.0f) alpha:1.0];
    newl.textColor = [UIColor whiteColor];
    newl.textAlignment = NSTextAlignmentCenter;
    newl.text=_NameOfPatient;
    [patientImage addSubview:newl];
    PatientName.text=_NameOfPatient;
    DateOfBirth.text=_dobofpatient;
    Location.text=_locatinOfPatient;
    SurveyName.text=_nameofSurvey;
    Answer.text=_surveyanswer;
    genderLbl.text=_genPat;
    
    
    PatientName.layer.borderWidth=1.5;
    PatientName.layer.borderColor=[UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1.0].CGColor;
    PatientName.layer.cornerRadius=5;
    
    DateOfBirth.layer.borderWidth=1.5;
    DateOfBirth.layer.borderColor=[UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1.0].CGColor;
    DateOfBirth.layer.cornerRadius=5;
    
    Location.layer.borderWidth=1.5;
    Location.layer.borderColor=[UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1.0].CGColor;
    Location.layer.cornerRadius=5;
    
    SurveyName.layer.borderWidth=1.5;
    SurveyName.layer.borderColor=[UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1.0].CGColor;
    SurveyName.layer.cornerRadius=5;
    
    Answer.layer.borderWidth=1.5;
    Answer.layer.borderColor=[UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1.0].CGColor;
    Answer.layer.cornerRadius=5;
    
    home_out.layer.borderWidth=1.5;
    home_out.layer.borderColor=[UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1.0].CGColor;
    home_out.layer.cornerRadius=5;
    
    genderLbl.layer.borderWidth=1.5;
    genderLbl.layer.borderColor=[UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1.0].CGColor;
    genderLbl.layer.cornerRadius=5;
    
    UIImage *imgfromdata=[UIImage imageWithData:_dataForimg];
    patientImage.image=imgfromdata;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)home_btn_action:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end