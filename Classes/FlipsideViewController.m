//
//  FlipsideViewController.m
//  Cleavage
//
//  Created by Jesse MacFadyen on 10-04-19.
//  Copyright Nitobi 2010. All rights reserved.
//

#import "FlipsideViewController.h"




@implementation FlipsideViewController

@synthesize delegate;
@synthesize commandObjects;
@synthesize settings;
@synthesize invokedURL;

-(void) awakeFromNib
{
	[super awakeFromNib];
	commandObjects = [[NSMutableDictionary alloc] initWithCapacity:4];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];     
	
	commandObjects = [[NSMutableDictionary alloc] initWithCapacity:4];
	
	CGRect screenBounds = [ [ UIScreen mainScreen ] bounds ];
	
	//self.window = [ [ [ UIWindow alloc ] initWithFrame:screenBounds ] autorelease ];
	//viewController = [ [ PhoneGapViewController alloc ] init ];
	
	webView = [ [ UIWebView alloc ] initWithFrame:screenBounds ];
    [webView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight) ];
	CGRect frame = webView.frame;
	frame.origin.y  += 40;
	webView.frame = frame;
	[ self setWebView:webView ];
	[ self.view addSubview:webView ];
	
	/*
	 * PhoneGap.plist
	 *
	 * This block of code navigates to the PhoneGap.plist in the Config Group and reads the XML into an Hash (Dictionary)
	 *
	 */
    NSDictionary *temp = [FlipsideViewController getBundlePlist:@"PhoneGap"];
    settings = [[NSDictionary alloc] initWithDictionary:temp];
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000
    NSNumber *detectNumber         = [settings objectForKey:@"DetectPhoneNumber"];
#endif
    NSNumber *useLocation          = [settings objectForKey:@"UseLocation"];
    NSNumber *_autoRotate           = [settings objectForKey:@"AutoRotate"];
    NSString *startOrientation     = [settings objectForKey:@"StartOrientation"];
    NSString *_rotateOrientation    = [settings objectForKey:@"RotateOrientation"];
    //NSString *topActivityIndicator = [settings objectForKey:@"TopActivityIndicator"];
	
	/*
	 * Fire up the GPS Service right away as it takes a moment for data to come back.
	 */
    if ([useLocation boolValue]) {
        [[self getCommandInstance:@"Location"] startLocation:nil withDict:nil];
    }
	
	webView.delegate = self;
	
	//[window addSubview:viewController.view];
	
	/*
	 * webView
	 * This is where we define the inital instance of the browser (WebKit) and give it a starting url/file.
	 */
	
	
    NSURL *appURL        = [NSURL fileURLWithPath:[FlipsideViewController  pathForResource:@"index.html"]];
    NSURLRequest *appReq = [NSURLRequest requestWithURL:appURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
	[webView loadRequest:appReq];
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000
	webView.detectsPhoneNumbers = [detectNumber boolValue];
#endif
	
	/*
	 * imageView - is the Default loading screen, it stay up until the app and UIWebView (WebKit) has completly loaded.
	 * You can change this image by swapping out the Default.png file within the resource folder.
	 */
	/*
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]];
	imageView = [[UIImageView alloc] initWithImage:image];
	[image release];
	
    imageView.tag = 1;
	[window addSubview:imageView];
	[imageView release];
	*/
	 
    /*
     * autoRotate - If you want your phone to automatically rotate its display when the phone is rotated
     * Value should be BOOL (YES|NO)
     */
    [self setAutoRotate:[_autoRotate boolValue]];
	
    /*
     * startOrientation - This option dictates what the starting orientation will be of the application 
     * Value should be one of: portrait, portraitUpsideDown, landscapeLeft, landscapeRight
     */
    orientationType = UIInterfaceOrientationPortrait;
    if ([startOrientation isEqualToString:@"portrait"]) {
        orientationType = UIInterfaceOrientationPortrait;
    } else if ([startOrientation isEqualToString:@"portraitUpsideDown"]) {
        orientationType = UIInterfaceOrientationPortraitUpsideDown;
    } else if ([startOrientation isEqualToString:@"landscapeLeft"]) {
        orientationType = UIInterfaceOrientationLandscapeLeft;
    } else if ([startOrientation isEqualToString:@"landscapeRight"]) {
        orientationType = UIInterfaceOrientationLandscapeRight;
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:orientationType animated:NO];
	
    /*
     * rotateOrientation - This option is only enabled when AutoRotate is enabled.  If the phone is still rotated
     * when AutoRotate is disabled, this will control what orientations will be rotated to.  If you wish your app to
     * only use landscape or portrait orientations, change the value in PhoneGap.plist to indicate that.
     * Value should be one of: any, portrait, landscape
     */
    [self setRotateOrientation:_rotateOrientation];
    
	/*
	 * The Activity View is the top spinning throbber in the status/battery bar. We init it with the default Grey Style.
	 *
	 *	 whiteLarge = UIActivityIndicatorViewStyleWhiteLarge
	 *	 white      = UIActivityIndicatorViewStyleWhite
	 *	 gray       = UIActivityIndicatorViewStyleGray
	 *
	 */
	
	/*
    UIActivityIndicatorViewStyle topActivityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    if ([topActivityIndicator isEqualToString:@"whiteLarge"]) {
        topActivityIndicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
    } else if ([topActivityIndicator isEqualToString:@"white"]) {
        topActivityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    } else if ([topActivityIndicator isEqualToString:@"gray"]) {
        topActivityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    }
    activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:topActivityIndicatorStyle] retain];
    activityView.tag = 2;
    [window addSubview:activityView];
    [activityView startAnimating];
	
	[window makeKeyAndVisible];
	 
	 */

	
}



/**
 Returns the current version of phoneGap as read from the VERSION file
 This only touches the filesystem once and stores the result in the class variable gapVersion
 */
static NSString *gapVersion;
+ (NSString*) phoneGapVersion
{
	if (gapVersion == nil) {
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *filename = [mainBundle pathForResource:@"VERSION" ofType:nil];
		// read from the filesystem and save in the variable
		gapVersion = [ [ NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL ] retain ];
	}
	return gapVersion;
}

/**
 Returns the contents of the named plist bundle, loaded as a dictionary object
 */
+ (NSDictionary*)getBundlePlist:(NSString *)plistName
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves			  
                                          format:&format errorDescription:&errorDesc];
    return temp;
}

+ (NSString*) wwwFolderName
{
	return @"www";
}

+ (NSString*) pathForResource:(NSString*)resourcepath
{
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSMutableArray *directoryParts = [NSMutableArray arrayWithArray:[resourcepath componentsSeparatedByString:@"/"]];
    NSString       *filename       = [directoryParts lastObject];
    [directoryParts removeLastObject];
	
    NSString *directoryStr = [NSString stringWithFormat:@"%@/%@", [self wwwFolderName], [directoryParts componentsJoinedByString:@"/"]];
    return [mainBundle pathForResource:filename
								ofType:@""
						   inDirectory:directoryStr];
}

/**
 When web application loads Add stuff to the DOM, mainly the user-defined settings from the Settings.plist file, and
 the device's data such as device ID, platform version, etc.
 */
- (void)webViewDidStartLoad:(UIWebView *)theWebView 
{
	
    
	// Play any default movie
	if(![[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) 
	{
		/*NSLog(@"Going to play default movie");
		Movie* mov = (Movie*)[self getCommandInstance:@"Movie"];
		NSMutableArray *args = [[[NSMutableArray alloc] init] autorelease];
		[args addObject:@"default.mov"];
		NSMutableDictionary* opts = [[[NSMutableDictionary alloc] init] autorelease];
		[opts setObject:@"1" forKey:@"repeat"];
		[mov play:args withDict:opts];*/
	}
	
    // Determine the URL used to invoke this application.
    // Described in http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html
	
 	if ([[invokedURL scheme] isEqualToString:[self appURLScheme]]) {
		InvokedUrlCommand* iuc = [[InvokedUrlCommand newFromUrl:invokedURL] autorelease];
		
		NSLog(@"Arguments: %@", iuc.arguments);
		NSString *optionsString = [[NSString alloc] initWithFormat:@"var Invoke_params=%@;", [iuc.options JSONFragment]];
		
		[webView stringByEvaluatingJavaScriptFromString:optionsString];
		
		[optionsString release];
    }
}

- (NSDictionary*) deviceProperties
{
	UIDevice *device = [UIDevice currentDevice];
    NSMutableDictionary *devProps = [NSMutableDictionary dictionaryWithCapacity:4];
    [devProps setObject:[device model] forKey:@"platform"];
    [devProps setObject:[device systemVersion] forKey:@"version"];
    [devProps setObject:[device uniqueIdentifier] forKey:@"uuid"];
    [devProps setObject:[device name] forKey:@"name"];
    [devProps setObject:[FlipsideViewController phoneGapVersion ] forKey:@"gap"];
	
    NSDictionary *devReturn = [NSDictionary dictionaryWithDictionary:devProps];
    return devReturn;
}

- (NSString*) appURLScheme
{
	// The info.plist contains this structure:
	//<key>CFBundleURLTypes</key>
	// <array>
	//		<dict>
	//			<key>CFBundleURLSchemes</key>
	//			<array>
	//				<string>yourscheme</string>
	//			</array>
	//			<key>CFBundleURLName</key>
	//			<string>YourbundleURLName</string>
	//		</dict>
	// </array>
	
	NSString* URLScheme = nil;
	
    NSArray *URLTypes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    if(URLTypes != nil ) {
		NSDictionary* dict = [URLTypes objectAtIndex:0];
		if(dict != nil ) {
			NSArray* URLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
			if( URLSchemes != nil ) {    
				URLScheme = [URLSchemes objectAtIndex:0];
			}
		}
	}
	
	return URLScheme;
}




- (IBAction)done {
	[self.delegate flipsideViewControllerDidFinish:self];	
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

/**
 Returns an instance of a PhoneGapCommand object, based on its name.  If one exists already, it is returned.
 */
-(id) getCommandInstance:(NSString*)className
{
    id obj = [commandObjects objectForKey:className];
    if (!obj) {
        // attempt to load the settings for this command class
        NSDictionary* classSettings;
        classSettings = [settings objectForKey:className];
		
        if (classSettings)
            obj = [[NSClassFromString(className) alloc] initWithWebView:webView settings:classSettings];
        else
            obj = [[NSClassFromString(className) alloc] initWithWebView:webView];
        
        [commandObjects setObject:obj forKey:className];
		[obj release];
    }
    return obj;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation 
{
    if (autoRotate == YES) {
        return YES;
    } else {
        if ([rotateOrientation isEqualToString:@"portrait"]) {
            return (interfaceOrientation == UIInterfaceOrientationPortrait ||
                    interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
        } else if ([rotateOrientation isEqualToString:@"landscape"]) {
            return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                    interfaceOrientation == UIInterfaceOrientationLandscapeRight);
        } else {
            return NO;
        }
    }
}

/**
 Called by UIKit when the device starts to rotate to a new orientation.  This fires the \c setOrientation
 method on the Orientation object in JavaScript.  Look at the JavaScript documentation for more information.
 */
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration: (NSTimeInterval)duration {
	double i = 0;
	
	switch (toInterfaceOrientation){
		case UIInterfaceOrientationPortrait:
			i = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			i = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			i = 90;
			break;
		case UIInterfaceOrientationLandscapeRight:
			i = -90;
			break;
	}
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"navigator.orientation.setOrientation(%f);", i]];
}

- (void) setAutoRotate:(BOOL) shouldRotate {
    autoRotate = shouldRotate;
}

- (void) setRotateOrientation:(NSString*) orientation {
    rotateOrientation = orientation;
}

- (void) setWebView:(UIWebView*) theWebView {
    webView = theWebView;
}

/**
 Called when the webview finishes loading.  This stops the activity view and closes the imageview
 */
- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	/*
	 * Hide the Top Activity THROBER in the Battery Bar
	 */
	

  //  NSMutableString *result = [ self deviceProperties];
	
	NSDictionary *deviceProperties = [ self deviceProperties];
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"DeviceInfo = %@;", [deviceProperties JSONFragment]];
	
   /* */
    /* Settings.plist
	 * Read the optional Settings.plist file and push these user-defined settings down into the web application.
	 * This can be useful for supplying build-time configuration variables down to the app to change its behaviour,
     * such as specifying Full / Lite version, or localization (English vs German, for instance).
	 */
	
    NSDictionary *temp = [FlipsideViewController getBundlePlist:@"Settings"];
    if ([temp respondsToSelector:@selector(JSONFragment)]) {
        [result appendFormat:@"\nwindow.Settings = %@;", [temp JSONFragment]];
    }
	
    NSLog(@"Device initialization: %@", result);
    [theWebView stringByEvaluatingJavaScriptFromString:result];
	[result release];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	//activityView.hidden = YES;	
	
	
	//imageView.hidden = YES;
	//[window bringSubviewToFront:viewController.view];
	
	webView = theWebView; 	
}

/**
 * Start Loading Request
 * This is where most of the magic happens... We take the request(s) and process the response.
 * From here we can re direct links and other protocalls to different internal methods.
 *
 */
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];
	
	NSLog(@"webView request to load :: %@",url);
    /*
     * Get Command and Options From URL
     * We are looking for URLS that match gap://<Class>.<command>/[<arguments>][?<dictionary>]
     * We have to strip off the leading slash for the options.
     */
	if ([[url scheme] isEqualToString:@"gap"]) {
		
		InvokedUrlCommand* iuc = [[InvokedUrlCommand newFromUrl:url] autorelease];
        
		// Tell the JS code that we've gotten this command, and we're ready for another
        [theWebView stringByEvaluatingJavaScriptFromString:@"PhoneGap.queue.ready = true;"];
		
		// Check to see if we are provided a class:method style command.
		[self execute:iuc];
		
		return NO;
	}
    
    /*
     * If a URL is being loaded that's a local file URL, just load it internally
     */
    else if ([url isFileURL])
    {
        //NSLog(@"File URL %@", [url description]);
        return YES;
    }
    
    /*
     * We don't have a PhoneGap or local file request, load it in the main Safari browser.
     */
    else
    {
        //NSLog(@"Unknown URL %@", [url description]);
        [[UIApplication sharedApplication] openURL:url];
        return NO;
	}
	
	return YES;
}

- (BOOL) execute:(InvokedUrlCommand*)command
{
	if (command.className == nil || command.methodName == nil) {
		return NO;
	}
	
	// Fetch an instance of this class
	PhoneGapCommand* obj = [self getCommandInstance:command.className];
	
	// construct the fill method name to ammend the second argument.
	NSString* fullMethodName = [[NSString alloc] initWithFormat:@"%@:withDict:", command.methodName];
	if ([obj respondsToSelector:NSSelectorFromString(fullMethodName)]) {
		[obj performSelector:NSSelectorFromString(fullMethodName) withObject:command.arguments withObject:command.options];
	}
	else {
		// There's no method to call, so throw an error.
		NSLog(@"Class method '%@' not defined in class '%@'", fullMethodName, command.className);
		[NSException raise:NSInternalInconsistencyException format:@"Class method '%@' not defined against class '%@'.", fullMethodName, command.className];
	}
	[fullMethodName release];
	
	return YES;
}


- (void)dealloc {
    [super dealloc];
}


@end
