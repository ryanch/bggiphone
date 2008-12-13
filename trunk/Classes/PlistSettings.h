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

//
//  PlistSettings.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlistSettings : NSObject {
	NSString * myPlistPath;
	NSMutableDictionary * dict;
}

@property (nonatomic, retain) NSMutableDictionary * dict;

/**
 this method installs the default plist if not already installed
 if already installed, then it will load the existing
 */
-(id) initWithSettingsNamed: (NSString *) plistName;

/**
 call this when your app is shutting down, and the settings will be saved.
 */
-(void) saveSettings;


@end
