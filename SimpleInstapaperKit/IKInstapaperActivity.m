//
//  IKInstapaperActivity.m
//  SimpleInstapaperKitExample
//
//  Created by David Beck on 12/3/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "IKInstapaperActivity.h"

#import "IKRequest.h"
#import "IKLoginViewController.h"


@implementation IKInstapaperActivity
{
	NSArray *_URLs;
}

- (NSString *)activityType
{
	return @"Instapaper";
}

- (NSString *)activityTitle
{
	return NSLocalizedString(@"Send to Instapaper", nil);
}

- (UIImage *)activityImage
{
	return [UIImage imageNamed:@"InstapaperActivity.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			NSURL *instapaperURL = [NSURL URLWithString:@"ihttp:test"];
			
			if ([[UIApplication sharedApplication] canOpenURL:instapaperURL] || [IKRequest loggedIn]) {
				return YES;
			}
		}
	}
	
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	NSMutableArray *URLs = [NSMutableArray array];
	
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			[URLs addObject:activityItem];
		}
	}
	
	_URLs = [URLs copy];
}

- (void)performActivity
{
	__block NSUInteger URLsLeft = _URLs.count;
	__block BOOL URLFailed = NO;
	__block BOOL authFailure = NO;
	
	for (NSURL *URL in _URLs) {
		[IKRequest requestForAddWithURL:URL completed:^(BOOL success, NSInteger statusCode) {
			if (!success) {
				URLFailed = YES;
			}
			if (statusCode == 403) {
				authFailure = YES;
			}
			
			URLsLeft--;
			
			if (URLsLeft == 0) {
				if (authFailure) {
					[self _login];
				} else {
					[self activityDidFinish:!URLFailed];
				}
			}
		}];
	}
}

- (void)_login
{
	IKLoginViewController *loginViewController = [[IKLoginViewController alloc] initWithCompletionHandler:^(BOOL loggedIn) {
		if (loggedIn) {
			[self performActivity];
		} else {
			[self activityDidFinish:NO];
		}
	}];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	
	UIViewController *rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;
	while ([rootViewController presentedViewController] != nil) {
		rootViewController = [rootViewController presentedViewController];
	}
	
	[rootViewController presentViewController:navigationController animated:YES completion:nil];
}

@end
