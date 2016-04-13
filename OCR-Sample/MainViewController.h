//
//  MainViewController.h
//  OCR-Sample
//
//  Created by Arai on 2016/04/13.
//  Copyright © 2016年 masato_arai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIImageView *imaegView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UITabBar *tabBar;

- (IBAction)cameraButtonDidTouch:(id)sender;

@end
