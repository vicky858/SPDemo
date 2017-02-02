//
//  CollectionView.h
//  PRO
//
//  Created by vignesh on 1/31/17.
//  Copyright © 2017 vignesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientRegistration.h"

@protocol colldeleggate <NSObject>

-(void)getdatacollection:(NSData *)imgdata;

@end

@interface collectionview : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource>

@property(assign,nonatomic)id <colldeleggate> delegate;


- (IBAction)backBtn:(id)sender;

@end