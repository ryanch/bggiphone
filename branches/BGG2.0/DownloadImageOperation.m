//
//  DownloadImageOperation.m
//  TestApp
//
//  Created by rchristi on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadImageOperation.h"
#import "DataTableViewController.h"
#import "TableCellImageLoader.h"

#define IMAGE_RESIZE_SIZE 50

@implementation DownloadImageOperation

@synthesize indexPath;
@synthesize downloadedImage;
@synthesize imageURLString;
@synthesize dataTableViewController;
@synthesize tableCellImageLoader;

#pragma mark ns operation methods

/// this is invoked by the operation queue when it is time to start downloading
- (void) main {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//NSLog(@"start main method on operation" );
	
	isDone = NO;
	
	downloadedImage = nil;
	
	activeDownload = [NSMutableData data];
	[activeDownload retain];
	
	
    imageConnection = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:imageURLString]] delegate:self startImmediately:YES];
	
	[imageConnection start];

	
	if (imageConnection != nil) {
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!isDone && ![self isCancelled]);
	}	
	
	
	[pool release];
	
}

- (void) cancel {
	[super cancel];
	isDone = YES;
	[imageConnection cancel];
}


#pragma mark clean up

- (void) dealloc {
	[imageConnection cancel];
	[imageURLString release];
	[indexPath release];
	[downloadedImage release];
	[dataTableViewController release];
	[activeDownload release];
	[imageConnection release];
	[tableCellImageLoader release];
	[super dealloc];
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {	
	if ( [self isCancelled] ) {
		[imageConnection cancel];
		return;
	}	
	
    [activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	
	[tableCellImageLoader pathIsFetched: indexPath ];
	
	
    // Clear the activeDownload property to allow later attempts
	[activeDownload release];
    activeDownload = nil;
    
    // Release the connection now that it's finished
	[imageConnection release];
    imageConnection = nil;
	
	isDone = YES;
}

- (void) saveImageToCache:( NSData*) data {
	[tableCellImageLoader saveImageForTableViewInCache:imageURLString data: data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	[tableCellImageLoader pathIsFetched: indexPath ];
	
	if ( [self isCancelled] ) {
		isDone = YES;
		return;
	}
	
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:activeDownload];
	
	UIImage * imageToUse = nil;
    
    if (image.size.width != IMAGE_RESIZE_SIZE && image.size.height != IMAGE_RESIZE_SIZE) {
        CGSize itemSize = CGSizeMake(IMAGE_RESIZE_SIZE, IMAGE_RESIZE_SIZE);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [image drawInRect:imageRect];
        imageToUse = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
		
		// dont need image any more
		[image release];
		
		// save in cache
		NSData * thumbData = UIImagePNGRepresentation( imageToUse );
		[self performSelectorOnMainThread:@selector(saveImageToCache:) withObject:thumbData waitUntilDone:YES];
		
    }
    else {
		
		// save in cache
		[self performSelectorOnMainThread:@selector(saveImageToCache:) withObject:activeDownload waitUntilDone:YES];
		
        imageToUse = image;
		[imageToUse autorelease]; // this is so the code below can assume it is all auto release
    }

    // clean up the stuff we dont need
	[activeDownload release];
    activeDownload = nil;

	[imageConnection release];
    imageConnection = nil;
	
	if (imageToUse == nil ){
		isDone = YES;
		return;
	}
	
	// check for cancel again
	if ( [self isCancelled] ) {
		isDone = YES;
		return;
	}
	
	// save the image
	downloadedImage = imageToUse;
	[downloadedImage retain];
	

	// let the table view controller know
	if (dataTableViewController != nil && [dataTableViewController.view superview] != nil ) {
		[dataTableViewController performSelectorOnMainThread:@selector(cellImageIsReady:) withObject:self waitUntilDone:YES];
	}
	
	isDone = YES;
	
}

@end
