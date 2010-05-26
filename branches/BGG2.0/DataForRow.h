//
//  DataForRow.h
//  TestApp
//
//  Created by rchristi on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DataRow;

@interface DataForRow :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * dataString;
@property (nonatomic, retain) NSData * dataBytes;
@property (nonatomic, retain) DataRow * parentRow;

@end



