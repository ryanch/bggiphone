//
//  BaseAppDelegate.m
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseAppDelegate.h"

@implementation BaseAppDelegate

@synthesize window;
@synthesize core;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	core = [[BGCore alloc] init];
	[core start:window device: [self buildBGDevice] ];
	
    [window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[core lowMem];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[core stop];
}

- (void)dealloc {
	
	[core release];
    [window release];
    [super dealloc];
}

- (BGDevice*) buildBGDevice {
	// do in sub class
	return nil;
}

@end
