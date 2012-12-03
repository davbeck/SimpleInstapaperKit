//
//  IKViewController.h
//  BasicInstapaperKitExample
//
//  Created by David Beck on 12/3/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IKViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)login:(id)sender;
- (IBAction)share:(id)sender;

@end
