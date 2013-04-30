//
//  IKRequest.m
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

#import "IKRequest.h"

#import "SFHFKeychainUtils.h"


#define IKInstapaperKeychainServiceName @"Instapaper"
#define IKInstapaperUsernamePreferenceKey @"InstapaperUsername"


@interface NSString (URLEncode)

- (NSString *)URLEncode;

@end

@implementation NSString (URLEncode)

- (NSString *)URLEncode
{
	CFStringRef encodedStringRef = CFURLCreateStringByAddingPercentEscapes(NULL,
																		   (__bridge CFStringRef)self,
																		   NULL,
																		   (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
																		   kCFStringEncodingUTF8);
	return CFBridgingRelease(encodedStringRef);
}

@end


@implementation IKRequest

+ (void)setUsername:(NSString *)username password:(NSString *)password completed:(IKRequestCompletionBlock)completed
{
	[self requestForAuthenticationWithParameters:@{IKRequestUsernameParameter : username, IKRequestPasswordParameter : password} completed:^(BOOL success, NSInteger statusCode) {
		if (success) {
			[SFHFKeychainUtils storeUsername:username andPassword:password forServiceName:IKInstapaperKeychainServiceName updateExisting:YES error:nil];
			[[NSUserDefaults standardUserDefaults] setObject:username forKey:IKInstapaperUsernamePreferenceKey];
		}
		
		if (completed != nil) {
			completed(success, statusCode);
		}
	}];
}

+ (NSString *)username
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:IKInstapaperUsernamePreferenceKey];
}

+ (NSString *)password
{
	return [SFHFKeychainUtils getPasswordForUsername:[self username] andServiceName:IKInstapaperKeychainServiceName error:NULL];
}

+ (BOOL)loggedIn
{
	return [self username].length > 0;
}

+ (void)requestForEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters completed:(IKRequestCompletionBlock)completed
{
	if (parameters == nil) {
		parameters = @{};
	}
	NSMutableDictionary *allParameters = [parameters mutableCopy];
	
	if (allParameters[IKRequestUsernameParameter] == nil && [self username] != nil) {
		allParameters[IKRequestUsernameParameter] = [self username];
	}
	if (allParameters[IKRequestPasswordParameter] == nil && [self password] != nil) {
		allParameters[IKRequestPasswordParameter] = [self password];
	}
	
	NSMutableString *parameterString = [NSMutableString string];
	[allParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		[parameterString appendFormat:@"%@=%@&", [key URLEncode], [value URLEncode]];
	}];
	
	NSURL *URL = [NSURL URLWithString:[IKRequestAPIPrefix stringByAppendingString:endpoint]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		if (completed != nil) {
			NSInteger statusCode = 0;
			if ([response respondsToSelector:@selector(statusCode)]) {
				statusCode = [(NSHTTPURLResponse *)response statusCode];
			}
			
			completed(error == nil && (statusCode == 200 || statusCode == 201), statusCode);
		}
	}];
}

+ (void)requestForAuthenticationWithParameters:(NSDictionary *)parameters completed:(IKRequestCompletionBlock)completed
{
	[self requestForEndpoint:IKRequestAuthenticationEndpoint parameters:parameters completed:completed];
}

+ (void)requestForAddWithURL:(NSURL *)URL title:(NSString *)title selection:(NSString *)selection parameters:(NSDictionary *)parameters completed:(IKRequestCompletionBlock)completed
{
	if (parameters == nil) {
		parameters = @{};
	}
	NSMutableDictionary *allParameters = [parameters mutableCopy];
	
	if (allParameters[IKRequestURLParameter] == nil && URL != nil) {
		allParameters[IKRequestURLParameter] = [URL absoluteString];
	}
	if (allParameters[IKRequestTitleParameter] == nil && title != nil) {
		allParameters[IKRequestTitleParameter] = title;
	}
	if (allParameters[IKRequestSelectionParameter] == nil && selection != nil) {
		allParameters[IKRequestSelectionParameter] = selection;
	}
	
	[self requestForEndpoint:IKRequestAddEndpoint parameters:allParameters completed:completed];
}

+ (void)requestForAddWithURL:(NSURL *)URL completed:(IKRequestCompletionBlock)completed
{
	[self requestForAddWithURL:URL title:nil selection:nil parameters:nil completed:completed];
}

@end
