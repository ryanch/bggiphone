//
//  BGCore.h
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGAction.h"
#import "BGDevice.h"
#import "BGActionFactory.h"
#import <CoreData/CoreData.h>;
#import "ImageDiscCache.h"
#import "DataList.h"

@interface BGCore : NSObject {
	NSMutableArray * actionHistory;
	BGActionFactory * actionFactory;
	BGDevice * device;
	UIWindow * window;
	
	// core data
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	ImageDiscCache * imageDiscCache;
	
	NSOperationQueue * coreDataOperationQueue;
	
	UINavigationController * mainNavController;
}

#pragma mark life cycle

- (void) start: (UIWindow*) window device: (BGDevice*) device;
- (void) stop;
- (void) lowMem;

#pragma mark navigation

/// push a new action, execute it
- (void) pushAction: (NSString*) action animated:(BOOL) isAnimated;
- (void) pr_pushActionToView: (BGAction*)action animated:(BOOL)isAnimated;

- (void) pushViewInMainNavigation: (UIViewController*) controller animated:(BOOL) isAnimated;
- (void) pushDetailView:(UIViewController*) controller animated:(BOOL) isAnimated;
- (void) showLoadingContentsInMainViewAnimated: (BOOL) animated;
@property (nonatomic,retain) UINavigationController * mainNavController;

#pragma mark data list helpers
- (NSString*) dataListHasContentsForKey:(NSString*) key;
- (DataList*) getDataListForKey:(NSString*) key;
- (void) addCoreDataLoadOperation: (NSOperation*) operation;

#pragma mark core data stuff
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSString *)applicationDocumentsDirectory;
@property (nonatomic,readonly) ImageDiscCache * imageDiscCache;

@end
