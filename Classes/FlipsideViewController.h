//
//  FlipsideViewController.h
//  Cleavage
//
//  Created by Jesse MacFadyen on 10-04-19.
//  Copyright Nitobi 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UINavigationController.h>
#import "JSON/JSON.h"

#import "Location.h"
#import "Sound.h"
#import "Contacts.h"
#import "DebugConsole.h"
#import "UIControls.h"

#import "InvokedUrlCommand.h"

@class InvokedUrlCommand;
@class PhoneGapViewController;
@class Sound;
@class Contacts;
@class Console;


@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController <UIApplicationDelegate, 
											  UIWebViewDelegate, 
											  UIAccelerometerDelegate,
											  UINavigationControllerDelegate
											  
											>
{
	id <FlipsideViewControllerDelegate> delegate;
	BOOL     autoRotate;
	IBOutlet UIWebView *webView;
	NSString *rotateOrientation;
	NSMutableDictionary *commandObjects;
	NSDictionary *settings;
	UIInterfaceOrientation orientationType;
	NSURL *invokedURL;
}

@property (nonatomic, retain) NSMutableDictionary *commandObjects;
@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, retain) NSURL *invokedURL;

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)done;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation; 
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration: (NSTimeInterval)duration;
- (void)setAutoRotate:(BOOL) shouldRotate;
- (void)setRotateOrientation:(NSString*) orientation;

// PhoneGap Stuff
- (void)setWebView:(UIWebView*) theWebView;
- (id) getCommandInstance:(NSString*)className;

- (BOOL) execute:(InvokedUrlCommand*)command;
- (NSString*) appURLScheme;

// Static Methods
+ (NSDictionary*)getBundlePlist:(NSString *)plistName;
+ (NSString*) wwwFolderName;
+ (NSString*) pathForResource:(NSString*)resourcepath;
+ (NSString*) phoneGapVersion;

@end




@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

