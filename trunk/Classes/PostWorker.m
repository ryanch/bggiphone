//
//  PostWorker.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 1/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PostWorker.h"
#import "BGGAppDelegate.h"

@implementation PostWorker

@synthesize url;
@synthesize usePost;
@synthesize params;
@synthesize responseCookies;
@synthesize responseData;
@synthesize requestCookies;


- (BOOL) start {

	// build post data
	NSData * postData = nil;
	if ( params != nil && [params count] > 0 ) {
	
		NSMutableString * postString = [[NSMutableString alloc] initWithCapacity:500];
		
		NSArray * allKeys = [params allKeys];
		NSInteger count = [allKeys count];
		for ( int i = 0; i < count; i++ ) {
			NSString * key = [allKeys objectAtIndex:i];
			NSString * value = [params objectForKey:key];
			
			[postString appendString: @"&"];
			[postString appendString: [BGGAppDelegate urlEncode:key]];
			[postString appendString: @"="];
			[postString appendString: [BGGAppDelegate urlEncode:value]];
		}
		
		
		postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	}
	
	
    
	// setup the request object
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
	
	
	// see if we have cookies to send
	if ( requestCookies != nil && [requestCookies count] > 0 ) {
		NSDictionary * cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies: requestCookies];
		NSMutableDictionary * mutableCookieHeaders =[[NSMutableDictionary alloc] initWithDictionary:cookieHeaders];
		[request setAllHTTPHeaderFields:mutableCookieHeaders];
	}
	
	// add the params
	if ( usePost ) {
		[request setHTTPMethod:@"POST"];
		
		if ( postData != nil ) {
			NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
			[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			[request setHTTPBody:postData];
		}
		
	}
	else {
		[request setHTTPMethod:@"GET"];	
	}
	
	
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	responseData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	
	/*
#ifdef __DEBUGGING__
	NSString * responseBody = [[NSString alloc] initWithData:responseData encoding:  NSASCIIStringEncoding];
	NSLog( @"%@",  responseBody );
	[responseBody release];
#endif
	*/
	 
	if ( error == nil && response != nil ) {
		responseCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[ (NSHTTPURLResponse*)response allHeaderFields] forURL:[NSURL URLWithString:url]];
	}
	
	
	return (error == nil);
	 
}







- (id) init
{
	self = [super init];
	if (self != nil) {
		usePost = YES;
		
	}
	return self;
}



@end
