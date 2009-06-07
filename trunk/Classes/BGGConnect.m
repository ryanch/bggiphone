//
//  BGGConnect.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 1/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BGGConnect.h"
#import "PostWorker.h"


@implementation BGGConnect

@synthesize username, password, authCookies;

//! Connect and get a auth key from bgg
- (void) connectForAuthKey {
	
	[authCookies release];
	authCookies = nil;
	
	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];

	// the login URL
	worker.url = @"http://boardgamegeek.com/login";
	
	// setup params
	NSMutableDictionary * params= [[NSMutableDictionary alloc] initWithCapacity:2];
	[params setObject:username forKey:@"username"];
	[params setObject:password forKey:@"password"];
	worker.params = params;
	[params release];
	
	
	BOOL success = [worker start];
	
	if ( success ) {
		NSArray * cookies =  worker.responseCookies ;
		NSInteger count = [cookies count];
		for ( NSInteger i = 0; i < count; i++ ) {
			NSHTTPCookie * cookie = (NSHTTPCookie*) [ cookies objectAtIndex:i];
			// see if the bggpassword cookie is set, if it is then auth is good
			if ( [ @"bggpassword" isEqualToString: [cookie name] ] ) {
				self.authCookies = cookies;
				break;
			} // end if is password cookie
		} // end for 
	} // end if success
	
	[worker release];

}

//! Log a play, with simple params
- (BGGConnectResponse) simpleLogPlayForGameId: (NSInteger) gameId forDate: (NSDate *) date numPlays: (NSInteger) plays {
	
	// see if we have auth key
	if ( authCookies == nil ) {
		[self connectForAuthKey];
	}
	
	// see if we got the auth key
	if ( authCookies == nil ) {
		return AUTH_ERROR;
	}
	
	

	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];
	
	// set the auth cookies
	worker.requestCookies = authCookies;
	
	// the log play URL
	worker.url = @"http://boardgamegeek.com/geekplay.php";
	
	// setup params
	NSMutableDictionary * params= [[NSMutableDictionary alloc] initWithCapacity:2];

	// ajax=1&action=save&version=2&
	// objecttype=thing&objectid=36218&
	// playid=&action=save&playdate=2009-02-07&dateinput=2009-02-07&YUIButton=&location=&quantity=1&length=&incomplete=0&nowinstats=0&comments=
	
	// these do not change
	[params setObject:@"1" forKey:@"ajax"];
	[params setObject:@"save" forKey:@"action"];
	[params setObject:@"2" forKey:@"version"];
	[params setObject:@"thing" forKey:@"objecttype"];
	[params setObject:@"0" forKey:@"incomplete"];
	[params setObject:@"0" forKey:@"nowinstats"];
	
	// set the game id
	[params setObject:[NSString stringWithFormat:@"%d", gameId] forKey:@"objectid"];
	
	// set the quantity
	[params setObject:[NSString stringWithFormat:@"%d", plays] forKey:@"quantity"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd"];
	NSString * datePlayedStr = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	
	// add play date
	[params setObject:datePlayedStr forKey:@"playdate"];
	[params setObject:datePlayedStr forKey:@"dateinput"];
	
	// set the params on request
	worker.params = params;
	[params release];

	
	BOOL success = [worker start];
	
	if ( success ) {
		NSString * responseBody = [[NSString alloc] initWithData:worker.responseData encoding:  NSASCIIStringEncoding];
		if ( responseBody != nil ) {
			NSRange range = [responseBody rangeOfString:@"Plays"];
			if ( range.location != NSNotFound ) {
				return SUCCESS;
			}
		}
	}
	
	return CONNECTION_ERROR;
	
	
	/*
	ajax=1
	&action=save&
	version=2&
	objecttype=boardgame
	&objectid=31260&
	playid=
	&action=save
	&playdate=2009-01-24
	&dateinput=2009-01-24
	&YUIButton=
	&location=
	&quantity=1
	&length=
	&incomplete=0
	&nowinstats=0
	&comments=
	 */
	
	
	
}


- (BGGConnectResponse) createDbGameEntryForGameId:(NSInteger) gameId {
	// see if we have auth key
	if ( authCookies == nil ) {
		[self connectForAuthKey];
	}
	
	// see if we got the auth key
	if ( authCookies == nil ) {
		return AUTH_ERROR;
	}
	
	
	
	
	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];
	
	// set the auth cookies
	worker.requestCookies = authCookies;
	
	// the log play URL
	worker.url = @"http://boardgamegeek.com/geekcollection.php";
	
	
	// setup params
	NSMutableDictionary * params= [[NSMutableDictionary alloc] initWithCapacity:2];
	
	// request an item to be added for this user
	[params setObject:@"1" forKey:@"ajax"];
	[params setObject:@"additem" forKey:@"action"];
	[params setObject:[NSString stringWithFormat: @"%d", gameId] forKey:@"objectid"];
	[params setObject:@"thing" forKey:@"objecttype"];
	
	
	NSLog(@"creating db entry with: %@", [params description]);
	
	worker.params = params;
	[params release];
	
	BOOL success = [worker start];
	[worker release];
	
	if ( success ) {
		return SUCCESS;
	}
	
	return CONNECTION_ERROR;
	
	
}


- (BGGConnectResponse) fetchGameCollectionId:(NSInteger) gameId {
	// see if we have auth key
	if ( authCookies == nil ) {
		[self connectForAuthKey];
	}
	
	// see if we got the auth key
	if ( authCookies == nil ) {
		return AUTH_ERROR;
	}
	
	
	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];
	
	// set the auth cookies
	worker.requestCookies = authCookies;
	
	// the log play URL
	worker.url = @"http://boardgamegeek.com/geekcollection.php";
	
	
	// setup params
	NSMutableDictionary * params= [[NSMutableDictionary alloc] initWithCapacity:2];
	
	// request an item to be added for this user
	[params setObject:@"1" forKey:@"ajax"];
	[params setObject:@"module" forKey:@"action"];
	[params setObject:[NSString stringWithFormat: @"%d", gameId] forKey:@"objectid"];
	[params setObject:@"thing" forKey:@"objecttype"];
	[params setObject:@"24" forKey:@"instanceid"];
	
	worker.params = params;
	[params release];
	
	BOOL success = [worker start];
	
	NSLog(@"fetching collection id with: %@", [params description]);
	
	if ( !success ) {
		return CONNECTION_ERROR;
	}
	
	NSString * data = [[NSString alloc] initWithData: worker.responseData encoding:NSUTF8StringEncoding];
	[worker release];

	NSRange collIdRange = [data rangeOfString:@"collid"];
	if ( collIdRange.location == NSNotFound ) {
		[data release];
		NSLog(@"not able to find collid");
		return BAD_CONTENT;
	}
	
	// now get the collection id
	NSInteger numberIndex = 0;
	unichar lettersForNumber[50];
	NSInteger searchIndex = collIdRange.location;
	
	BOOL isNumber = NO;
	BOOL foundNumber = NO;
	BOOL cleanBreak = NO;
	while( numberIndex < 40 ) {
		isNumber = NO;
		unichar letter = [data characterAtIndex:searchIndex];
		if ( letter == '0' || letter == '1' || letter == '2' || letter == '3' || letter == '4' || letter == '5' || letter == '6' || letter == '7' || letter == '8' || letter == '9' ) {
			isNumber = YES;
			foundNumber = YES;
		}
		
		if ( isNumber ) {
			lettersForNumber[numberIndex] = letter;
			numberIndex++;
		}
		
		// see if we are at the end
		if ( foundNumber == YES && isNumber == NO ) {
			cleanBreak = YES;
			break;
		}
		
		// next letter
		searchIndex++;
		
	}
	
	if ( !cleanBreak ) {
		[data release];
		NSLog(@"unable to fetch collection id");
		return BAD_CONTENT;
	}
	
	gameCollectionId = [[NSString alloc] initWithCharacters:lettersForNumber length:numberIndex];
	
	[data release];

	return SUCCESS;
}


- (BGGConnectResponse) saveCollectionForGameId: (NSInteger) gameId withParams: (NSDictionary*) paramsToSave {
	
	// see if the game already exists in the users collection
	BGGConnectResponse response = [self fetchGameCollectionId: gameId];
	
	if ( response == BAD_CONTENT ) {
		
		// if bad conntent it might not exist
		response = [self createDbGameEntryForGameId:gameId];
		if ( response != SUCCESS ) {
			return response;
		}
		
		// after creating try again
		response = [self fetchGameCollectionId:gameId];
		if ( response != SUCCESS ) {
			return response;
		}
		
	}
	else if ( response != SUCCESS ) {
		return response;
	}
	
	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];
	
	// set the auth cookies
	worker.requestCookies = authCookies;
	
	// the log play URL
	worker.url = @"http://boardgamegeek.com/geekcollection.php";
	
	
	// setup params
	NSMutableDictionary * params= [[NSMutableDictionary alloc] initWithCapacity:50];
	
	///gameCollectionId = @"8488980";

	// request an item to be added for this user
	[params setObject:@"1" forKey:@"ajax"];
	[params setObject:@"savedata" forKey:@"action"];
	[params setObject:gameCollectionId forKey:@"collid"];
	[params setObject:@"status" forKey:@"fieldname"];
	
	// add params based on the contents of the dictionary
	if ( [paramsToSave objectForKey:@"fortrade"] != nil ) {
		[params setObject:@"1" forKey:@"fortrade"];
	}
	
	if ( [paramsToSave objectForKey:@"notifyauction"] != nil ) {
		[params setObject:@"1" forKey:@"notifyauction"];
	}
	
	if ( [paramsToSave objectForKey:@"notifycontent"] != nil ) {
		[params setObject:@"1" forKey:@"notifycontent"];
	}	
	
	if ( [paramsToSave objectForKey:@"notifysale"] != nil ) {
		[params setObject:@"1" forKey:@"notifysale"];
	}		
	
	if ( [paramsToSave objectForKey:@"own"] != nil ) {
		[params setObject:@"1" forKey:@"own"];
	}	
	
	if ( [paramsToSave objectForKey:@"preordered"] != nil ) {
		[params setObject:@"1" forKey:@"preordered"];
	}	
	
	if ( [paramsToSave objectForKey:@"prevowned"] != nil ) {
		[params setObject:@"1" forKey:@"prevowned"];
	}	
	
	if ( [paramsToSave objectForKey:@"want"] != nil ) {
		[params setObject:@"1" forKey:@"want"];
	}	
	
	if ( [paramsToSave objectForKey:@"wanttobuy"] != nil ) {
		[params setObject:@"1" forKey:@"wanttobuy"];
	}		

	if ( [paramsToSave objectForKey:@"wanttoplay"] != nil ) {
		[params setObject:@"1" forKey:@"wanttoplay"];
	}		
	
	if ( [paramsToSave objectForKey:@"wishlist"] != nil ) {
		[params setObject:@"1" forKey:@"wishlist"];
	}		
	
	if ( [paramsToSave objectForKey:@"wishlistpriority"] != nil ) {
		[params setObject:[paramsToSave objectForKey:@"wishlistpriority"] forKey:@"wishlistpriority"];
	}		
			
	
	NSLog(@"going to log with params: %@", [params description] );
	
	worker.params = params;
	[params release];
	
	BOOL success = [worker start];
	[worker release];
	
	if ( success ) {
		return SUCCESS;
	}
	else {
		return CONNECTION_ERROR;
	}
	
	
	
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		authCookies = nil;
	}
	return self;
}

- (void) dealloc
{
	[gameCollectionId release];
	[authCookies release];
	[username release];
	[password release];
	[super dealloc];
}


@end
