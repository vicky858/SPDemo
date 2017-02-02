//
//  ViewController.h
//  PRO
//
//  Created by vignesh on 1/31/17.
//  Copyright © 2017 vignesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernamne;
@property (weak, nonatomic) IBOutlet UITextField *passworsd;
@property (weak, nonatomic) IBOutlet UIButton *login;

- (IBAction)login_btn:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *img_view;


@end

