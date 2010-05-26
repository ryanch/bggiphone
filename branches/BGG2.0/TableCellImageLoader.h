//
//  TableCellImageLoader.h
//  TestApp
//
//  Created by rchristi on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class DataTableViewController;
@class ImageDiscCache;
@class DownloadImageOperation;

@interface TableCellImageLoader : NSObject {
	ImageDiscCache * discCache;
	NSOperationQueue * operationQueue;
	NSMutableSet * pathSetAlreadyWorking;
	
}

- (UIImage*) fetchImageIfExists: (NSString*) url;

- (BOOL) checkImageIsInCache: (NSString*) url;

- (void) fetchImageForTableView: (DataTableViewController*) dataTableViewController forPath: (NSIndexPath*) path withImageURL: (NSString*) url;

- (void) saveImageForTableViewInCache: (NSString*) url data: (NSData*) data;

- (void) cancelAll;

- (void) pathIsFetched:(NSIndexPath*) path;

@property( nonatomic, retain ) ImageDiscCache * discCache;

@end
