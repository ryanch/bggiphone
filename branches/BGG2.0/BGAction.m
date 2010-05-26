//
//  BGAction.m
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BGAction.h"


@implementation BGAction

@synthesize bgCore;

- (void) executeActionAnimated: (BOOL) animated withCore: (BGCore*) core {
		// sub class will implement
}


- (void) dealloc
{
	[bgCore release];
	[super dealloc];
}


- (void) operationMain: (NSOperation*) theOperationObject {
	// to be done by sub class
}

@end
