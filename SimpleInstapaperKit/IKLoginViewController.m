//
//  IKLoginViewController.m
//  SimpleInstapaperKitExample
//
//  Created by David Beck on 12/3/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//
//  https://github.com/davbeck/SimpleInstapaperKit
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//  OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "IKLoginViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "IKRequest.h"


@interface IKLoginViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITableViewCell *loadingCell;
@property (strong, nonatomic) IBOutlet UITextField *loadingField;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

- (IBAction)selectNext:(id)sender;
- (IBAction)login:(id)sender;

@end

@implementation IKLoginViewController
{
	BOOL _loading;
	void(^_completionHandler)(BOOL loggedIn);
}

- (void)_setLoading:(BOOL)loading
{
	_loading = loading;
	
	[self.tableView reloadData];
	
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.25];
	[animation setType:kCATransitionFade];
	[self.view.layer addAnimation:animation forKey:nil];
}

- (UINavigationItem *)navigationItem
{
	UINavigationItem *navigationItem = [super navigationItem];
	
	navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Login", nil)
																		 style:UIBarButtonItemStyleDone
																		target:self action:@selector(login:)];
	navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																					 target:self action:@selector(cancel:)];
	
	UILabel *title = [[UILabel alloc] init];
	title.text = NSLocalizedString(@"Instapaper", nil);
	title.font = [UIFont fontWithName:@"Georgia" size:22.0];
	title.backgroundColor = [UIColor clearColor];
	title.textColor = [UIColor whiteColor];
	title.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[title sizeToFit];
	navigationItem.titleView = title;
	
	return navigationItem;
}

- (id)initWithCompletionHandler:(void(^)(BOOL loggedIn))completion
{
	self = [self initWithNibName:nil bundle:nil];
	if (self != nil) {
		_completionHandler = [completion copy];
	}
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self != nil) {
		self.title = NSLocalizedString(@"Instapaper", nil);
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.loadingField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
	
	self.usernameField.text = [IKRequest username];
	self.passwordField.text = [IKRequest password];
	[self.usernameField becomeFirstResponder];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_loading) {
		return 1;
	}
	
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_loading) {
		return self.loadingCell;
	}
	
	if (indexPath.row == 0) {
		return self.usernameCell;
	} else if (indexPath.row == 1) {
		return self.passwordCell;
	}
	
	return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
		[self.usernameField becomeFirstResponder];
	} else {
		[self.passwordField becomeFirstResponder];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_loading) {
		return 44.0 * 2.0;
	}
	
	return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return self.headerView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return self.footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return self.footerView.frame.size.height;
}


#pragma mark - Actions

- (IBAction)login:(id)sender
{
	[self _setLoading:YES];
	
	
	[IKRequest setUsername:self.usernameField.text password:self.passwordField.text completed:^(BOOL success, NSInteger statusCode) {
		if (success) {
			if (_completionHandler != nil) {
				_completionHandler(YES);
				_completionHandler = nil;
			}
			
			[self cancel:nil];
		} else {
			NSString *reason;
			
			if (statusCode == 403) {
				reason = NSLocalizedString(@"Invalid username or password.", nil);
			} else {
				reason = NSLocalizedString(@"The service encountered an error. Please try again later.", nil);
			}
			
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed", nil)
									   message:reason
									  delegate:self
							 cancelButtonTitle:NSLocalizedString(@"OK", nil)
							 otherButtonTitles:nil] show];
			
			[self _setLoading:NO];
		}
	}];
}

- (IBAction)cancel:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	if (_completionHandler != nil) {
		_completionHandler(NO);
	}
}

- (IBAction)selectNext:(id)sender
{
	[self.passwordField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.passwordField) {
		[self login:textField];
		return NO;
	}
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self.loadingField becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.passwordField becomeFirstResponder];
}

@end
