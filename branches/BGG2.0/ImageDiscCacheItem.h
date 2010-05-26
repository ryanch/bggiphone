//
//  ImageDiscCacheItem.h
//  TestApp
//
//  Created by rchristi on 5/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface ImageDiscCacheItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * imageFileId;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSDate * expireDate;

@end



