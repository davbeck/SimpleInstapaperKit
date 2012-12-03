//
//  IKRequest.m
//  SimpleInstapaperKitExample
//
//  Created by David Beck on 12/3/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
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
	
	if (allParameters[IKRequestUsernameParameter] == nil) {
		allParameters[IKRequestUsernameParameter] = [self username];
	}
	if (allParameters[IKRequestPasswordParameter] == nil) {
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
