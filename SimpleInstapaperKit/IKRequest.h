//
//  IKRequest.h
//  SimpleInstapaperKitExample
//
//  Created by David Beck on 12/3/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IKRequestAPIPrefix @"https://www.instapaper.com/api/"

#define IKRequestAuthenticationEndpoint @"authenticate"
#define IKRequestAddEndpoint @"add"

#define IKRequestUsernameParameter @"username"
#define IKRequestPasswordParameter @"password"
#define IKRequestURLParameter @"url"
#define IKRequestTitleParameter @"title"
#define IKRequestSelectionParameter @"selection"


typedef void(^IKRequestCompletionBlock)(BOOL success, NSInteger statusCode);


@interface IKRequest : NSObject

+ (void)setUsername:(NSString *)username password:(NSString *)password completed:(IKRequestCompletionBlock)completed;
+ (NSString *)username;
+ (NSString *)password;
+ (BOOL)loggedIn;

+ (void)requestForEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters completed:(IKRequestCompletionBlock)completed;
+ (void)requestForAuthenticationWithParameters:(NSDictionary *)parameters completed:(IKRequestCompletionBlock)completed;
+ (void)requestForAddWithURL:(NSURL *)URL title:(NSString *)title selection:(NSString *)selection parameters:(NSDictionary *)parameters completed:(IKRequestCompletionBlock)completed;
+ (void)requestForAddWithURL:(NSURL *)URL completed:(IKRequestCompletionBlock)completed;

@end
