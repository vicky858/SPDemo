//
//  PatientListTable.h
//  PRO
//
//  Created by vignesh on 1/31/17.
//  Copyright © 2017 vignesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "NSData+NSDataAdditions.h"
#import "NSString+NSStringAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import <MultipeerConnectivity/MCBrowserViewController.h>
#import "SessionContainer.h"
#import "THMultipeer.h"
#import "THMultipeerSession.h"

@import MultipeerConnectivity;


@interface PatientListTable : UIViewController <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *rehreshout;
@property (weak, nonatomic) IBOutlet UIButton *addNewOut;
@property (weak, nonatomic) IBOutlet UITableView *tblPatientList;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *filtereddata;
@property(nonatomic,assign)bool isFiltered;
@property (copy, nonatomic) NSString *displayName;
@property (copy, nonatomic) NSString *serviceType;
@property (retain, nonatomic) SessionContainer *sessionContainer;
@property (retain, nonatomic) NSMutableArray *transcripts;
@property (retain, nonatomic) NSMutableDictionary *imageNameIndex;
@property (retain, nonatomic) IBOutlet UITextField *messageComposeTextField;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *sendMessageButton;
@property(retain,nonatomic)MCAdvertiserAssistant *advertiserAssistant;
@property (weak, nonatomic) IBOutlet UIButton *searchpeers;
@property (weak, nonatomic) IBOutlet UIButton *syncdata;
@property (weak, nonatomic) IBOutlet UILabel *devicename;
- (IBAction)Refresh_btn:(id)sender;
- (IBAction)Btn_Check:(id)sender;




@end
