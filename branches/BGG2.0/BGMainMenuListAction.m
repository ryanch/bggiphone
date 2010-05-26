//
//  BGMainMenuListAction.m
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BGMainMenuListAction.h"
#import "BGListAction.h"
#import "BGCore.h"
#import "DataRow.h"
#import "BGMainMenuListAction.h"
#import "BGActionOperation.h"


@implementation BGMainMenuListAction



/// this should return the key for the list we build
- (NSString*) buildDataListKey {
	return ACTION_URL_MAIN_MENU;
}


/// this method is called in the ns operation queue
- (void) operationMain {
	
	NSManagedObjectContext * managedObjectContext = [bgCore managedObjectContext];
	
	
	NSString * key = [self buildDataListKey];
	
	if ( key == nil ) {
		[NSException raise:@"error! should have returned a key from buildDataListKey" format: @"missing key" ];
	}
	
	
	DataList * list = [bgCore getDataListForKey:key];
	
	if ( list == nil ) {
		list = [NSEntityDescription
				insertNewObjectForEntityForName:@"DataList"
				inManagedObjectContext:managedObjectContext];
	}
	
	list.key = key;
	list.listTitle = @"Menu";
	
	
	
	NSMutableSet * newRows = [[NSMutableSet alloc] initWithCapacity:20];
	
	// add the menu items to the list
	DataRow * row = [NSEntityDescription
					 insertNewObjectForEntityForName:@"DataRow"
					 inManagedObjectContext:managedObjectContext];
	row.detailText = nil;
	row.imageURL = @"images/mainMenuIcons/own.png";
	row.topText = @"Test";
	
	[newRows addObject:row];
	
	// set the rows on the data list object
	list.rows = newRows;
	
	
	// save to db
	[managedObjectContext refreshObject:list mergeChanges:YES];
	[managedObjectContext save:nil];
	
	
	[newRows release];
	
	
	[self performSelectorOnMainThread:@selector(dataIsReady:) withObject:list.listTitle  waitUntilDone:YES];
	
}


@end
