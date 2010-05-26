//
//  BGActionOperation.m
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BGActionOperation.h"


@implementation BGActionOperation

@synthesize bgAction;

- (void) dealloc
{
	[bgAction release];
	[super dealloc];
}

- (void) main {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[bgAction operationMain: self];
	[pool release];
}


@end
