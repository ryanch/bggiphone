//
//  ImageDiscCache.m
//  TestApp
//
//  Created by rchristi on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageDiscCache.h"
#import "FileIdGen.h"

@implementation ImageDiscCache

@synthesize managedObjectContext,cacheDir;

- (void) dealloc {

	self.managedObjectContext = nil;
	
	[super dealloc];
	

}



- (NSInteger) findNewFileId {
	
	NSInteger newId = 0;
		
	@synchronized (self) {
	
		
		// Create the fetch request for the entity.
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		// Edit the entity name as appropriate.
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"FileIdGen" inManagedObjectContext:managedObjectContext];
		[fetchRequest setEntity:entity];
		
		// Set example predicate and sort orderings...
		
		NSError *error = nil;
		NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
		[fetchRequest release];
		
		if ( array != nil && [array count] > 0 ) {
			FileIdGen * item = [array objectAtIndex:0];
			
			item.imageFileId = [NSNumber numberWithInt: [item.imageFileId intValue] + 1];
			newId = [item.imageFileId intValue];
			
			[managedObjectContext refreshObject:item mergeChanges:YES];
			[managedObjectContext save:nil];
		}
		else {
			FileIdGen * item = [NSEntityDescription
							 insertNewObjectForEntityForName:@"FileIdGen"
							 inManagedObjectContext:managedObjectContext];	
			item.imageFileId = [NSNumber numberWithInt:1];
			newId = 1;
			
			[managedObjectContext refreshObject:item mergeChanges:YES];
			[managedObjectContext save:nil];			
			
		}
		
		
		
	}
	
	return newId;
}

- (NSString*) filePathForItem: (NSInteger) fileId {
	// path looks like this:
	// temp/<folder number>/id
	
	NSInteger folder = fileId / 100;
	NSString * folderName = [NSString stringWithFormat:@"%d", folder];
	NSString * fileName = [NSString stringWithFormat:@"%d", fileId];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = [paths objectAtIndex:0];
	NSString *folderPath = [cacheDirectory stringByAppendingPathComponent:folderName];	
	
	// make sure the dir exists
	NSFileManager * manager =[NSFileManager defaultManager];
	if ( ![manager fileExistsAtPath:folderPath] ) {
		[manager createDirectoryAtPath:folderPath
				   withIntermediateDirectories:YES attributes:nil  error:nil];
	}
	
	return [folderPath stringByAppendingPathComponent:fileName];
	
}


- (void) addDataToCache: (NSString*) url dataToCache: (NSData*) data ttl: (NSTimeInterval) timeToKeepInSeconds {
	
	ImageDiscCacheItem * item = [self fetchDataFromCache:url];
	if ( item == nil ) {
		item = [NSEntityDescription
		 insertNewObjectForEntityForName:@"ImageDiscCacheItem"
		 inManagedObjectContext:managedObjectContext];
	}
	
	//item.imageData = data;
	item.imageURL = url;
	
	if ( timeToKeepInSeconds < 0 ) {
		item.expireDate = [NSDate distantFuture];
	}
	else {
		item.expireDate = [[NSDate date] addTimeInterval:timeToKeepInSeconds];
	}
	
	
	item.imageFileId = [NSNumber numberWithInt: [self findNewFileId] ];
	
	[data writeToFile: [self filePathForItem: [item.imageFileId intValue] ] atomically:YES];
	
	
	[managedObjectContext refreshObject:item mergeChanges:YES];
	[managedObjectContext save:nil];

}

- (UIImage*) fetchImageFromCache: (NSString*) url {
	ImageDiscCacheItem * item = [self fetchDataFromCache:url];
	if( item == nil ) {
		return nil;
	}
	
	NSString * path = [self filePathForItem: [item.imageFileId intValue] ];
	
	if ( path == nil ) {
		return nil;
	}
	
	NSFileManager * manager = [NSFileManager defaultManager];
	if ( ![manager fileExistsAtPath:path] ) {
		return nil;
	}
	
	
	UIImage * image = [[UIImage alloc] initWithContentsOfFile:path];
	
	[image autorelease];
	return image;
	
	
	
}

-  (ImageDiscCacheItem*) fetchDataFromCache: (NSString*) url {
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageDiscCacheItem" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(imageURL ==  %@) ", url];
	[fetchRequest setPredicate:predicate];

	NSError *error = nil;
	NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	if ( array != nil && [array count] > 0 ) {
		ImageDiscCacheItem * item = [array objectAtIndex:0];
		
		if (item.expireDate == nil ) {
			return item;
		}
		
		
		NSDate * now = [NSDate date];
		NSDate * expireDate = item.expireDate;
		
		// see if now is later in time than expireDate,
		if ( NSOrderedDescending == [now compare:expireDate] ) {
			[managedObjectContext deleteObject:item];
			[managedObjectContext save:nil];
		}
		else {
			[item retain];
			[item autorelease];
			return item;
		}
		
	}
	
	return nil;
	
}


@end
