//
//  DataRow.h
//  TestApp
//
//  Created by rchristi on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface DataRow :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * topText;
@property (nonatomic, retain) NSString * sectionTitle;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * detailText;
@property (nonatomic, retain) NSString * sortTitle;
@property (nonatomic, retain) NSManagedObject * parentList;
@property (nonatomic, retain) NSManagedObject * data;

@end



