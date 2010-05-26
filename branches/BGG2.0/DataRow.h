//
//  DataRow.h
//  BGG2.0
//
//  Created by rchristi on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DataForRow;
@class DataList;

@interface DataRow :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * actionURL;
@property (nonatomic, retain) NSString * topText;
@property (nonatomic, retain) NSString * sectionTitle;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * detailText;
@property (nonatomic, retain) NSString * sortTitle;
@property (nonatomic, retain) DataList * parentList;
@property (nonatomic, retain) DataForRow * data;

@end



