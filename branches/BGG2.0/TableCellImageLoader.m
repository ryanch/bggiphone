//
//  TableCellImageLoader.m
//  TestApp
//
//  Created by rchristi on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TableCellImageLoader.h"
#import "ImageDiscCache.h"
#import "DownloadImageOperation.h"
#import "DataTableViewController.h"

#define THUMB_NAIL_CACHE_SECONDS (1 * 60 * 24 * 10)

@implementation TableCellImageLoader


@synthesize discCache;



- (void) cancelAll {
	[operationQueue cancelAllOperations];	
	[pathSetAlreadyWorking removeAllObjects];
}


- (void) dealloc
{
	
	[operationQueue cancelAllOperations];
	[operationQueue release];
	[discCache release];
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:1];
	}
	return self;
}


- (BOOL) checkImageIsInCache: (NSString*) url {
	NSString * key = [url stringByAppendingString:@".thumb"];
	
	return nil != [discCache fetchDataFromCache:key];
	
}

- (UIImage*) fetchImageIfExists: (NSString*) url {
	// check the cache first
	NSString * key = [url stringByAppendingString:@".thumb"];
	
	return [discCache fetchImageFromCache:key];
	
}

- (void) fetchImageForTableView: (DataTableViewController*) dataTableViewController forPath: (NSIndexPath*) path withImageURL: (NSString*) url {
	
	@synchronized( pathSetAlreadyWorking ) {
		if ( [pathSetAlreadyWorking containsObject:path] ) {
			return;
		}
		else {
			[pathSetAlreadyWorking addObject:path];
		}
	}
	
	
	// not found, so add job to queue, and return default image
	DownloadImageOperation * operation = [[DownloadImageOperation alloc] init];
	operation.indexPath = path;
	operation.imageURLString = url;
	operation.dataTableViewController = dataTableViewController;
	operation.tableCellImageLoader = self;
	operation.downloadedImage = nil;
	
	[operationQueue addOperation:operation];
	
	[operation release];

}


- (void) pathIsFetched:(NSIndexPath*) path {
	@synchronized( pathSetAlreadyWorking ) {
		[pathSetAlreadyWorking removeObject:path];
	}
}

/// this is called with the data to save, this must be done on main
/// thread since its with the managed data
- (void) saveImageForTableViewInCache: (NSString*) url data: (NSData*) data {
	
	NSString * key = [url stringByAppendingString:@".thumb"];
	[discCache addDataToCache:key dataToCache:data  ttl:THUMB_NAIL_CACHE_SECONDS];
	
}



@end
