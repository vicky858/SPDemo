//
//  PatientReport.h
//  PRO
//
//  Created by vignesh on 1/31/17.
//  Copyright © 2017 vignesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientListTable.h"
#import "PatientDetails.h"

@interface PatientReport : UIViewController<UITextViewDelegate, UITextFieldDelegate>


@property(retain,nonatomic)NSString *NameOfPatient;
@property(retain,nonatomic)NSString *dobofpatient;
@property(retain,nonatomic)NSNumber *Idofpatient;
@property(retain,nonatomic)NSString *locatinOfPatient;
@property(retain,nonatomic)NSString *genPat;
@property(retain,nonatomic)NSString *nameofSurvey;
@property(retain,nonatomic)NSString  *surveyanswer;
@property(retain,nonatomic)NSData *dataForimg;
@property (strong, nonatomic) IBOutlet UIView *reportHeadView;
@property (strong, nonatomic) IBOutlet UIButton *home_out;
@property (strong, nonatomic) IBOutlet UITextField *PatientName;
@property (strong, nonatomic) IBOutlet UITextField *DateOfBirth;
@property (strong, nonatomic) IBOutlet UITextField *Location;
@property (strong, nonatomic) IBOutlet UITextField *SurveyName;
@property (strong, nonatomic) IBOutlet UITextField *Answer;
@property (strong, nonatomic) IBOutlet UIImageView *patientImage;
@property (strong, nonatomic) IBOutlet UITextField *genderLbl;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) PatientDetails* patDetails;

- (IBAction)home_btn_action:(id)sender;






@end