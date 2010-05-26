//
//  DownloadImageOperation.h
//  TestApp
//
//  Created by rchristi on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DataTableViewController;
@class TableCellImageLoader;

@interface DownloadImageOperation : NSOperation {

	NSIndexPath * indexPath;
	UIImage * downloadedImage;
	NSString * imageURLString;
	DataTableViewController * dataTableViewController;
	TableCellImageLoader * tableCellImageLoader;
	
	
	NSMutableData * activeDownload;
	NSURLConnection * imageConnection;
	BOOL isDone;
	
}


@property (nonatomic,retain)	NSIndexPath * indexPath;
@property (nonatomic,retain)	UIImage * downloadedImage;
@property (nonatomic,retain)	NSString * imageURLString;
@property (nonatomic,retain)	DataTableViewController * dataTableViewController;
@property (nonatomic,retain)	TableCellImageLoader * tableCellImageLoader;

- (void) saveImageToCache:( NSData*) data;

@end
