//
//  IKLoginViewController.h
//  SimpleInstapaperKitExample
//
//  Created by David Beck on 12/3/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IKLoginViewController : UITableViewController <UITextFieldDelegate>

- (id)initWithCompletionHandler:(void(^)(BOOL loggedIn))completion;

@end
