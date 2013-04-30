//
//  IKInstapaperActivity.m
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
