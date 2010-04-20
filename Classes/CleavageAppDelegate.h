//
//  CleavageAppDelegate.h
//  Cleavage
//
//  Created by Jesse MacFadyen on 10-04-19.
//  Copyright Nitobi 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface CleavageAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;

@end

