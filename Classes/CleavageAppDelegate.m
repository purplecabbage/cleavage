//
//  CleavageAppDelegate.m
//  Cleavage
//
//  Created by Jesse MacFadyen on 10-04-19.
//  Copyright Nitobi 2010. All rights reserved.
//

#import "CleavageAppDelegate.h"
#import "MainViewController.h"

@implementation CleavageAppDelegate


@synthesize window;
@synthesize mainViewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
