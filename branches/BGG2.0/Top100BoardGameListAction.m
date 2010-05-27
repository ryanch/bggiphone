//
//  Top100BoardGameListAction.m
//  BGG2.0
//
//  Created by rchristi on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Top100BoardGameListAction.h"
#import "BGGHTMLScraper.h"
#import "BGCore.h"
#import "BBGSearchResult.h"
#import "DataRow.h"
#import "DataList.h"

@implementation Top100BoardGameListAction

/// this should return the key for the list we build
- (NSString*) buildDataListKey {
	return ACTION_URL_TOP_100;
}

- (NSString*) buildURLToFetch {
	return @"http://www.boardgamegeek.com/browse/boardgame";
}

- (NSString*) buildListTitle {
	return NSLocalizedString( @"Browse Top 100", @"Browse Top 100 screen title" );
}

- (void) saveRows {
	
	NSManagedObjectContext * managedObjectContext = [bgCore managedObjectContext];
	
	
	NSString * key = [self buildDataListKey];
	
	// create the string
	NSString * markup = [[NSString alloc] initWithData:activeDownload encoding:  NSUTF8StringEncoding];	
	
	//NSLog( @"markup: %@", markup );
	
	[markup autorelease];
	
	// don't need the data any more
	[activeDownload release];
    activeDownload = nil;
	
	// parse the markup data
	BGGHTMLScraper * scaper = [[BGGHTMLScraper alloc] init];
	NSArray * top100list = [scaper scrapeGamesFromTop100: markup];
	[scaper release];
	scaper = nil;
	
	
	
	if ( top100list == nil || [top100list count] == 0 ) {
		NSString * errorMsg = NSLocalizedString( @"Error loading top 100 from web site.", @"error loading" );
		[bgCore dataErrorForAction:[self buildDataListKey] withErrorString:errorMsg];
		return;
	}
	
	
	NSInteger count = [top100list count];
	NSMutableSet * newRows = [[NSMutableSet alloc] initWithCapacity:count];
	
	
	DataList * list = [bgCore getDataListForKey:key];
	
	if ( list == nil ) {
		list = [NSEntityDescription
				insertNewObjectForEntityForName:@"DataList"
				inManagedObjectContext:managedObjectContext];
	}
	
	list.key = key;
	list.listTitle = [self buildListTitle];
	
	
	
	
	for ( NSInteger i = 0; i < count; i++ ) {
		BBGSearchResult * result = [top100list objectAtIndex:i];
		
		// add the menu items to the list
		DataRow * row = [NSEntityDescription
						 insertNewObjectForEntityForName:@"DataRow"
						 inManagedObjectContext:managedObjectContext];
		row.detailText = nil;
		row.imageURL = result.imageURL;
		row.topText = result.primaryTitle;
		row.actionURL = ACTION_URL_TOP_100;
		row.sortTitle = result.primaryTitle;
		
		[newRows addObject:row];		
		
	}
	
	// save the rows to the db
	list.rows = newRows;
	
	
	// save to db
	[managedObjectContext refreshObject:list mergeChanges:YES];
	[managedObjectContext save:nil];	
}






@end
