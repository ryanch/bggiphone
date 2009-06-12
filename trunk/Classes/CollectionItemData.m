//
//  CollectionItemData.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 6/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CollectionItemData.h"


@implementation CollectionItemData

@synthesize own;
@synthesize prevOwn;
@synthesize forTrade;
@synthesize wantInTrade;
@synthesize wantToBuy;
@synthesize wantToPlay;
@synthesize preOrdered;
@synthesize inWish;
@synthesize wishValue;
@synthesize   collId;
@synthesize   gameId;
@synthesize response;

- (id) init
{
	self = [super init];
	if (self != nil) {
		own = NO;
		prevOwn= NO;
		forTrade = NO;
		wantInTrade= NO;
		wantToBuy = NO;
		wantToPlay = NO;
		preOrdered = NO;
		inWish = NO;
		wishValue = 1;
		collId = 0;
		gameId= 0;
		response= SUCCESS;
	}
	return self;
}




@end
