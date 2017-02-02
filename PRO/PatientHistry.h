//
//  PatientHistry.h
//  PRO
//
//  Created by vignesh on 1/31/17.
//  Copyright © 2017 vignesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatientHistry : NSObject

@property(retain,nonatomic)NSString *patientname;
@property(retain,nonatomic)NSString *dob;
@property(retain,nonatomic)NSString *gender;
@property(retain,nonatomic)NSString *patientid;
@property(retain,nonatomic)NSString *locationName;
@property(retain,nonatomic)NSString *surveyname;
@property(retain,nonatomic)NSString *answer;
@property(retain,nonatomic)NSData *dataForImag;
@end
