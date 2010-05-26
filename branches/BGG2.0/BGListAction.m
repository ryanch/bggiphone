//
//  BGListAction.m
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BGListAction.h"
#import "BGCore.h"
#import "DataTableViewController.h"


@implementation BGListAction


- (void) executeActionAnimated: (BOOL) animated withCore: (BGCore*) core {
	
	isAnimated = animated;
	
	self.bgCore = core;

	// see if we have the data in cache
	NSString * key = [self buildDataListKey];
	
	NSString * title = [core dataListHasContentsForKey:key];
	
	if ( title == nil ) {
		// push a loading view
		[core addCoreDataLoadOperation: [self buildListActionOperation] ];
		[core showLoadingContentsInMainViewAnimated:animated];
	
	}
	else {
		[self dataIsReady:title ];
	}
	
}

/// this must be called from main thread
/// this should be triggered by the operation
- (void) dataIsReady: (NSString*) titleForList {
	
	NSString * dataListKey = [self buildDataListKey];
	
	DataTableViewController * dataView = [[DataTableViewController alloc] initWithStyle:UITableViewStylePlain];
	dataView.title = titleForList;
	dataView.imageDiscCache = bgCore.imageDiscCache;
	dataView.dataListKey = dataListKey;
	dataView.managedObjectContext = bgCore.managedObjectContext;
	
	[bgCore pushViewInMainNavigation:dataView animated:isAnimated];
	
	[dataView release];
}

/// build an operation
- (BGActionOperation*) buildListActionOperation {
	BGActionOperation * op = [[BGActionOperation alloc] init];
	op.bgAction = self;
	[op autorelease];
	return op;
}


- (NSString*) buildDataListKey {
	// to be done by implementor
	return nil;
}


- (void) dealloc {
	[super dealloc];
}



@end
