//
//  BGCore.m
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BGCore.h"
#import "BGMainMenuListAction.h"
#import "DataList.h"

@implementation BGCore

@synthesize mainNavController;

#pragma mark life cycle

- (void) start: (UIWindow*) theWindow device: (BGDevice*) bgDevice {
	
	window = theWindow;
	[window retain];
	
	
	
	coreDataOperationQueue = [[NSOperationQueue alloc] init];
	[coreDataOperationQueue setMaxConcurrentOperationCount:1];
	
	
	imageDiscCache = [[ImageDiscCache alloc] init];
	imageDiscCache.cacheDir = @"images";
	imageDiscCache.managedObjectContext = [self managedObjectContext];
	
	
	device = bgDevice;
	[device retain];
	
	
	actionFactory = [[BGActionFactory alloc] init];
	actionFactory.device = bgDevice;
	
	
	/*
	// TODO load history from disc
	actionHistory = [[NSMutableArray alloc] init];
	
	
	if( [actionHistory count] == 0 ) {
		[actionHistory addObject:@"MAIN MENU TODO"];
	}

	NSInteger count = [actionHistory count];
	for (NSInteger i = 0; i < count; i++ ) {		
		NSString * actionStr = [actionHistory objectAtIndex:i];
		BGAction * action = [actionFactory fetchBGAction:actionStr];
		[self pr_pushActionToView: action animated: NO];
		
	}
	 */
	
	BGAction * action = [actionFactory fetchBGAction:ACTION_URL_MAIN_MENU];
	
	[self pr_pushActionToView:action animated:NO];
	
	
	
}

- (void) stop {

}

- (void) lowMem {
	
}

- (void) dealloc
{
	[window release];
	[mainNavController release];
	[coreDataOperationQueue cancelAllOperations];
	[coreDataOperationQueue release];
	[imageDiscCache release];
	[device release];
	[actionFactory release];
	[actionHistory release];
	[super dealloc];
}



#pragma mark navigation

/// push a new action, execute it
- (void) pushAction: (NSString*) actionStr animated:(BOOL) isAnimated {
	[actionHistory addObject:actionStr];
	
	BGAction * action = [actionFactory fetchBGAction:actionStr];
	
	// TODO save history
	
	[self pr_pushActionToView: action animated: isAnimated];
}
- (void) pr_pushActionToView: (BGAction*)action animated:(BOOL)isAnimated {
	[action executeActionAnimated:isAnimated withCore:self];
	
}

- (void) pushViewInMainNavigation: (UIViewController*) controller animated:(BOOL) isAnimated {
	
	if ( mainNavController == nil ) {
			
		if (!device.isIPad ) {
			mainNavController = [[UINavigationController alloc] initWithRootViewController:controller];
			[window addSubview:mainNavController.view];
		}
		
		
	}
	else {
		[mainNavController pushViewController:controller animated:isAnimated];
	}
	
}

- (void) pushDetailView:(UIViewController*) controller animated:(BOOL) isAnimated {
	// TODO
}

- (void) showLoadingContentsInMainViewAnimated: (BOOL) animated {
	// TODO 
}



#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CoreDataTest.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}


- (ImageDiscCache*) imageDiscCache {
	return imageDiscCache;
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark data list helpers
- (NSString*) dataListHasContentsForKey:(NSString*) key {

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataList" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(key ==  %@) ", key];
	[fetchRequest setPredicate:predicate];
	
	[fetchRequest setFetchLimit:1];
	
	NSError *error = nil;
	
	NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if ( array != nil && [array count] > 0 ) {
		DataList * dataList = (DataList * )[array objectAtIndex:0];
		NSString * title = dataList.listTitle;
		[title retain];
		[title autorelease];
		return title;
	}
	else {
		return nil;
	}

}

- (DataList*) getDataListForKey:(NSString*) key {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataList" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(key ==  %@) ", key];
	[fetchRequest setPredicate:predicate];
	
	[fetchRequest setFetchLimit:1];
	
	NSError *error = nil;
	
	NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if ( array != nil && [array count] > 0 ) {
		DataList * dataList = (DataList * )[array objectAtIndex:0];
		return dataList;
	}
	else {
		return nil;
	}
}

- (void) addCoreDataLoadOperation: (NSOperation*) operation {
	[coreDataOperationQueue addOperation:operation];
}


@end
