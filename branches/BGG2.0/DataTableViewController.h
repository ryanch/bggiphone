//
//  DataTableViewController.h
//  TestApp
//
//  Created by rchristi on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DownloadImageOperation.h"

@class ImageDiscCache;
@class TableCellImageLoader;


@interface DataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	NSString * dataListKey;
	TableCellImageLoader * tableCellImageLoader;
	ImageDiscCache * imageDiscCache;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString *dataListKey;
@property (nonatomic, retain) ImageDiscCache * imageDiscCache;

- (void) cellImageIsReady: (DownloadImageOperation*) operation;

- (void) loadImagesForOnscreenRows;

@end
