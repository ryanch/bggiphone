//
//  PlistSettings.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PlistSettings.h"

/*
 Copyright 2008 Ryan Christianson
 
 Licensed under the Apache License, Version 2.0 (the "License"); 
 you may not use this file except in compliance with the License. 
 You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed under the 
 License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
 either express or implied. See the License for the specific 
 language governing permissions and limitations under the License. 
 */ 

@implementation PlistSettings

@synthesize dict;

-(id) initWithSettingsNamed: (NSString *) plistName {

	
	// look in the documents directory for an existing plist
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	myPlistPath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.plist", plistName] ];
	
	NSFileManager *fileManger = [NSFileManager defaultManager];
	if ( ![fileManger fileExistsAtPath:myPlistPath] ) {
		// if not found, then copy from nib
		NSString *pathToSettingsInBundle = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
		
		if ( ![fileManger copyItemAtPath:pathToSettingsInBundle	toPath:myPlistPath error:nil] ) {
			NSLog( @"unable to copy settings file to documents." );
		}
	}
	
	
	// now load
	dict = [NSMutableDictionary dictionaryWithContentsOfFile: myPlistPath];
	
	return self;
	
	
}

-(void) saveSettings {
	[dict writeToFile:myPlistPath		atomically:YES];
}





@end
