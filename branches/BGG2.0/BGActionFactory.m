//
//  BGActionFactory.m
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BGActionFactory.h"
#import "BGMainMenuListAction.h"

@implementation BGActionFactory

@synthesize device;

- (BGAction*) fetchBGAction:(NSString*) actionURL {
	
	/// main menu match
	if ( [actionURL isEqualToString:ACTION_URL_MAIN_MENU ] ) {
		BGMainMenuListAction * mainMenu = [[BGMainMenuListAction alloc] init];
		[mainMenu autorelease];
		return mainMenu;
	}
	
	[NSException raise:@"dont know action" format:@"unknown action: %@", actionURL];
	
	return nil;
}

- (void) dealloc
{
	[device release];
	[super dealloc];
}



@end
