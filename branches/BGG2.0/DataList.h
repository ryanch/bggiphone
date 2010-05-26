//
//  DataList.h
//  BGG2.0
//
//  Created by rchristi on 5/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DataRow;

@interface DataList :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * listTitle;
@property (nonatomic, retain) NSSet* rows;

@end


@interface DataList (CoreDataGeneratedAccessors)
- (void)addRowsObject:(DataRow *)value;
- (void)removeRowsObject:(DataRow *)value;
- (void)addRows:(NSSet *)value;
- (void)removeRows:(NSSet *)value;

@end

