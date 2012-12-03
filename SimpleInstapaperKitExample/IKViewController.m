//
//  IKViewController.m
//  BasicInstapaperKitExample
//
//  Created by David Beck on 12/3/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "IKViewController.h"

#import "SimpleInstapaperKit.h"


@interface IKViewController () <UIPopoverControllerDelegate>

@end

@implementation IKViewController
{
	UIPopoverController *_popover;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://github.com/davbeck/SimpleInstapaperKit"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)login:(id)sender
{
	IKLoginViewController *loginViewController = [[IKLoginViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)share:(id)sender
{
	NSURL *URL = self.webView.request.URL;
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[[[IKInstapaperActivity alloc] init]]];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[self presentViewController:activityViewController animated:YES completion:nil];
	} else if (![_popover isPopoverVisible]) {
		_popover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
		_popover.delegate = self;
		[_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	_popover = nil;
}

@end
