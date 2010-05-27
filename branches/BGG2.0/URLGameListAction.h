//
//  URLGameListAction.h
//  BGG2.0
//
//  Created by rchristi on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGListAction.h"


@interface URLGameListAction : BGListAction {

	NSOperation * operation;
	NSMutableData * activeDownload;
	NSURLConnection * urlConnection;
	BOOL isDone;	
	
}

- (NSString*) buildURLToFetch;

- (void) saveRows;

- (NSString*) buildListTitle;

@end
