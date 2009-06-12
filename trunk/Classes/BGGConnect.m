//
//  BGGConnect.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 1/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BGGConnect.h"
#import "PostWorker.h"
#import "CollectionItemData.h"
#import "BGGAppDelegate.h"

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

- (CollectionItemData*) fetchGameCollectionItemData:(NSInteger) gameId {

	// see if we have auth key
	if ( authCookies == nil ) {
		[self connectForAuthKey];
	}
	
	// see if we got the auth key
	if ( authCookies == nil ) {
		CollectionItemData * itemData = [[CollectionItemData alloc] init];
		itemData.response = AUTH_ERROR;
		[itemData autorelease];
		return itemData;
	}
	
	
	

	CollectionItemData * itemData = [self _fetchGameCollectionItemDataHelper: gameId];
	

	
	
	
	if ( itemData == nil ) {

		// if bad conntent it might not exist
		BGGConnectResponse response = [self createDbGameEntryForGameId:gameId];
		if ( response != SUCCESS ) {
			return nil;
		}
		
	}
	
	// after creating try again
	return [self _fetchGameCollectionItemDataHelper: gameId];

	
	
}

- (CollectionItemData*) _fetchGameCollectionItemDataHelper:(NSInteger) gameId {

	
	CollectionItemData * itemData = [[CollectionItemData alloc] init];
	
	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];
	
	// set the auth cookies
	worker.requestCookies = authCookies;
	
	// the log play URL
	worker.url = @"http://boardgamegeek.com/geekcollection.php";
	
	
	// http://boardgamegeek.com/geekcollection.php?ajax=1&action=module&objectid=1&objecttype=thing&instanceid=24
	// http://boardgamegeek.com/geekcollection.php?ajax=1&action=module&objectid=25417&objecttype=thing&instanceid=24
	
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
		itemData.response = CONNECTION_ERROR;
		[itemData release];
		return nil;
	}
	
	NSString * data = [[NSString alloc] initWithData: worker.responseData encoding:NSUTF8StringEncoding];
	[worker release];

	// check if the collection id is even in the page
	NSRange collIdRange = [data rangeOfString:@"collid"];
	if ( collIdRange.location == NSNotFound ) {
		
		NSLog(@"collid not found in data: %@", data); 
		
		[data release];
		NSLog(@"not able to find collid");
		[itemData release];
		return nil;
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
		return nil;
	}
	
	// set the collection id
	
	NSString * collIdString = [[NSString alloc] initWithCharacters:lettersForNumber length:numberIndex];
	
	itemData.collId = [collIdString intValue];
	
	[collIdString release];
	
	// check if things are checked
	itemData.own = [self scanForCheckedForm: @"own" fromData: data];
	itemData.prevOwn = [self scanForCheckedForm: @"prevowned" fromData: data];
	itemData.forTrade = [self scanForCheckedForm: @"fortrade" fromData: data];
	itemData.wantInTrade = [self scanForCheckedForm: @"want" fromData: data];
	itemData.wantToBuy = [self scanForCheckedForm: @"wanttobuy" fromData: data];
	itemData.wantToPlay = [self scanForCheckedForm: @"wanttoplay" fromData: data];
	itemData.preOrdered = [self scanForCheckedForm: @"preordered" fromData: data];
	itemData.forTrade = [self scanForCheckedForm: @"fortrade" fromData: data];
	itemData.inWish = [self scanForCheckedForm: @"wishlist" fromData: data];
	
	
	
	
	// set the value of the wish priority
	if ( [data rangeOfString:@"SELECTED>3 - Like to have"].location != NSNotFound ) {
		itemData.wishValue = 2;
	}	
	else if ( [data rangeOfString:@"SELECTED>1 - Must have"].location != NSNotFound ) {
		itemData.wishValue = 0;
	}	
	else if ( [data rangeOfString:@"SELECTED>2 - Love to have"].location != NSNotFound ) {
		itemData.wishValue = 1;
	}

	else if ( [data rangeOfString:@"SELECTED>4 - Thinking about it"].location != NSNotFound ) {
		itemData.wishValue = 3;
	}
	else if ( [data rangeOfString:@"SELECTED>5 - Don't buy this"].location != NSNotFound ) {
		itemData.wishValue = 4;
	}	
	
	
	
	[data release];

	[itemData autorelease];
	return itemData;
}

- (BOOL) scanForCheckedForm: (NSString*) name fromData: (NSString*) data {
	
	
	NSRange range = [data rangeOfString:name];
	if ( range.location == NSNotFound ) {
		return NO;
	}
	
	
	NSInteger bufferIndex = 0;
	unichar searchBuffer[50];
	NSInteger searchIndex = range.location;
	
	while( bufferIndex < 50 ) {
	
		unichar letter = [data characterAtIndex:searchIndex];
		searchIndex++;

		if ( letter == '>' ) {
			break;
		}
		
		searchBuffer[bufferIndex] = letter;
		bufferIndex++;
		
	}	
	
	NSString * buffString = [[NSString alloc] initWithCharacters:searchBuffer length:bufferIndex];
	
	if ( [buffString rangeOfString:@"CHECKED"].location != NSNotFound ) {
		[buffString release];
		return YES;
	}
	
	if ( [buffString rangeOfString:@"checked"].location != NSNotFound ) {
		[buffString release];
		return YES;
	}	
	
	[buffString release];	
	return NO;
}


- (BGGConnectResponse) saveCollectionForGameId: (NSInteger) gameId withParams: (NSDictionary*) paramsToSave withData: (CollectionItemData *) itemData {
	
	// see if we have auth key
	if ( authCookies == nil ) {
		[self connectForAuthKey];
	}
	
	// see if we got the auth key
	if ( authCookies == nil ) {
		return AUTH_ERROR;
	}
	
	
	
	// see if the game already exists in the users collection
	if ( itemData == nil ) {
		itemData = [self fetchGameCollectionItemData: gameId];
	}
	
	if ( itemData == nil ) {
		return BAD_CONTENT;
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
	[params setObject:[NSString stringWithFormat: @"%d",   itemData.collId] forKey:@"collid"];
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

	[authCookies release];
	[username release];
	[password release];
	[super dealloc];
}


@end
