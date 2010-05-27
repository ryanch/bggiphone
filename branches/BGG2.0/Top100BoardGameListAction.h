//
//  Top100BoardGameListAction.h
//  BGG2.0
//
//  Created by rchristi on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGListAction.h"


#define ACTION_URL_TOP_100 @"com.boardgamegeek#top100"

@interface Top100BoardGameListAction : BGListAction {

	NSOperation * operation;
	NSMutableData * activeDownload;
	NSURLConnection * urlConnection;
	BOOL isDone;
	
}

@end
