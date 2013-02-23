//
//  PostWorker.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 1/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PostWorker : NSObject {

	NSString* url;
	BOOL usePost;
	NSDictionary* params;
	NSURLConnection* urlConnection;
	NSData* responseData;
	NSArray* responseCookies;
	NSArray* requestCookies;
}




@property (nonatomic, strong) NSString *  url;
@property (nonatomic) BOOL  usePost;
@property (nonatomic, strong) NSDictionary*  params;
@property (nonatomic, strong) NSArray*  responseCookies;
@property (nonatomic, strong) NSData*  responseData;
@property (nonatomic, strong) NSArray*  requestCookies;

//! start to send the request to the server
- (BOOL) start;




@end
