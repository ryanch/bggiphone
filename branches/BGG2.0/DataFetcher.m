//
//  DataFetcher.m
//  TestApp
//
//  Created by rchristi on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataFetcher.h"


@implementation DataFetcher

@synthesize	imageCache;





- (void) dealloc {
	[imageCache release];
	[super dealloc];
}
	

@end
