//
//  IKRequest.h
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
