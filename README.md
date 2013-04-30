# SimpleInstapaperKit

`SimpleInstapaperKit` is a minimalist iOS wrapper for the [Instapaper Simple Developer API](http://www.instapaper.com/api/simple). With this version of the API, you can verify login info and add URLs to the user's Instapaper list.

## Requirements

- iOS 6.0
- This project uses ARC. If you want to use it in a non ARC project, you must add the -fobjc-arc compiler flag to TUSafariActivity.m in Target Settings > Build Phases > Compile Sources.

## Installation

### [CocoaPods](http://cocoapods.org)

    pod 'SimpleInstapaperKit'

### Manual

1. Add the `SimpleInstapaperKit` subfolder to your project.
2. Add [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore) to your project.
3. Link your target to `Security` and `QuartzCore` frameworks.

## Usage

*(See example Xcode project)*

### IKRequest

`IKRequest` is the class that actually connects to the API and what the other classes use. It stores the current logged in username in `NSUSerDefaults` and the password in the keychain.

`+[IKRequest setUsername:password:completed:]` will check with the server to verify the login credentials and if they are correct, then saves the login info. Either way, the completed block will be called.

`+[IKRequest requestForAddWithURL:completed:]` will add the given URL to the user's list without a title or description. The success argument in the block is determined by a successful HTTP request as well as a successful HTTP status code (either 200 or 201).

### IKInstapaperActivity

![Login Screenshot](http://f.cl.ly/items/290j3a1S1P3t0n1X210J/iOS%20Simulator%20Screen%20shot%20Dec%203,%202012%208.26.03%20PM.png "Login")

`IKInstapaperActivity` is a `UIActivity` subclass for use in `UIActivityViewController`. It will add any `NSURL`s in the activity items array to the user's Instapaper list.

```objectivec
NSURL *URL = [NSURL URLWithString:@"http://github.com/davbeck/SimpleInstapaperKit"];
IKInstapaperActivity *activity = [[IKInstapaperActivity alloc] init];
UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[activity]];
```

Note that you can include the activity in any UIActivityViewController and it will only be shown to the user if there is a URL in the activity items. It will also only show up if the user is logged in or the Instapaper app is installed on the device. If adding the URL fails because of a authentication problem, the `IKLoginViewController` will be shown and the URL will try to be re-added.

### IKLoginViewController

![Login Screenshot](http://f.cl.ly/items/2E2a2i051N2b202L1w1O/iOS%20Simulator%20Screen%20shot%20Dec%203,%202012%208.27.32%20PM.png "Login")

`IKLoginViewController` is a `UIViewController` that manages getting the user's username and password, checking the API for successful login, and then saving credentials.

`-[IKLoginViewController initWithCompletionHandler:]` (or just `-[IKLoginViewController init]`) will create a view controller that is mostly fire and forget. You will just need to embed it in a `UINavigationController`.

```objectivec
IKLoginViewController *loginViewController = [[IKLoginViewController alloc] init];
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];

[self presentViewController:navigationController animated:YES completion:nil];
```