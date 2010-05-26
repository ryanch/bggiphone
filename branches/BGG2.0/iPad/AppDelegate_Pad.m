//
//  AppDelegate_Pad.m
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate_Pad.h"

@implementation AppDelegate_Pad

- (BGDevice*) buildBGDevice {
	BGDevice * device = [[BGDevice alloc] init];
	device.isIPad = YES;
	[device autorelease];
	return device;
}


@end
