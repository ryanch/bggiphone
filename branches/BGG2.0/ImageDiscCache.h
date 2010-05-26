//
//  ImageDiscCache.h
//  TestApp
//
//  Created by rchristi on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "ImageDiscCacheItem.h"

@interface ImageDiscCache : NSObject {

	NSManagedObjectContext *managedObjectContext;
	NSString * cacheDir;
	
}


- (void) addDataToCache: (NSString*) url dataToCache: (NSData*) data ttl: (NSTimeInterval) timeToKeepInSeconds;
- (ImageDiscCacheItem*) fetchDataFromCache: (NSString*) url;
- (NSString*) filePathForItem: (NSInteger) fileId;
- (NSInteger) findNewFileId;
- (UIImage*) fetchImageFromCache: (NSString*) url;


@property (nonatomic,retain) NSString * cacheDir;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@end
