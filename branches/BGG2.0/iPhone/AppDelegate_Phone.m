//
//  AppDelegate_Phone.m
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate_Phone.h"

@implementation AppDelegate_Phone

- (BGDevice*) buildBGDevice {
	BGDevice * device = [[BGDevice alloc] init];
	device.isIPad = NO;
	[device autorelease];
	return device;
}



@end
