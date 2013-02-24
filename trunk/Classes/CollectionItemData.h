//
//  CollectionItemData.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 6/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGGAppDelegate.h"

@interface CollectionItemData : NSObject {
	BOOL own;
	BOOL prevOwn;
	BOOL forTrade;
	BOOL wantInTrade;
	BOOL wantToBuy;
	BOOL wantToPlay;
	BOOL preOrdered;
	BOOL inWish;
	NSInteger wishValue;
	NSInteger collId;
	NSInteger gameId;
	BGGConnectResponse response;
    NSInteger rating;
}

@property (nonatomic) BOOL own;
@property (nonatomic) BOOL prevOwn;
@property (nonatomic) BOOL forTrade;
@property (nonatomic) BOOL wantInTrade;
@property (nonatomic) BOOL wantToBuy;
@property (nonatomic) BOOL wantToPlay;
@property (nonatomic) BOOL preOrdered;
@property (nonatomic) BOOL inWish;
@property (nonatomic) NSInteger wishValue;
@property (nonatomic) NSInteger collId;
@property (nonatomic) NSInteger gameId;
@property (nonatomic) NSInteger rating;
@property (nonatomic) BGGConnectResponse response;

@end
