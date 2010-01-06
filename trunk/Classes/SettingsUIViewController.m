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
//  SettingsUIViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 10/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsUIViewController.h"
#import "BGGAppDelegate.h"
#import "PlistSettings.h"
#import "XmlSearchReader.h"
#import "DbAccess.h"
#import "PostWorker.h"
#import "BGGConnect.h"

@implementation SettingsUIViewController

@synthesize userNameTextField;
@synthesize passwordTextField;
@synthesize testButton;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self; // sectionIndexTitlesForTableView
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


- (void) saveSettings {
	
	[userNameTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSMutableDictionary * dict = appDelegate.appSettings.dict;
	
	NSString * newUsername = userNameTextField.text;
	if ( newUsername == nil || [newUsername length] == 0 ) {
		[dict removeObjectForKey:@"username"];
		[self clearGameCache];
	}
	else {
		
		NSString * oldUserName = (NSString*) [dict objectForKey:@"username"];
		if ( oldUserName != nil && ![newUsername isEqualToString:oldUserName] ) {
			[self clearGameCache];
		}
		
		[dict setObject:newUsername	forKey:@"username"];	
	}
	
	[dict setObject:userNameTextField.text	forKey:@"username"];
	
	
	if ( passwordTextField.text == nil || [passwordTextField.text length] == 0 ) {
		[dict removeObjectForKey:@"password"];
	}
	else{
		[dict setObject:passwordTextField.text	forKey:@"password"];
	}
	
	
	
}

- (IBAction) clearGameCache {
	// Clear database
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate.dbAccess clearDB];
	
	// Clear caches directory
	NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = [cachePaths objectAtIndex:0];
	for(NSString *itemName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:NULL])
	{
		[[NSFileManager defaultManager] removeItemAtPath:[cacheDirectory stringByAppendingPathComponent:itemName] error:NULL];
	}
	
	[self clearImageCache];
}

- (IBAction) clearImageCache { 
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * tempFilePath = [documentsDirectory stringByAppendingPathComponent:  @"imgs" ];
	
	[[NSFileManager defaultManager] removeItemAtPath:tempFilePath	error:nil];
	
	[[NSFileManager defaultManager]  createDirectoryAtPath:tempFilePath		attributes:nil];
	
}


- (void)viewWillDisappear:(BOOL)animated {
	[self saveSettings];
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    
#ifdef TESTING_ENABLED
	NSLog( @"testing enabled" );
	testButton.hidden = NO;
#endif
	
	userNameTextField.delegate = self;
	passwordTextField.delegate = self;
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSMutableDictionary * dict = appDelegate.appSettings.dict;
	userNameTextField.text = [dict objectForKey:@"username"];
	passwordTextField.text = [dict objectForKey:@"password"];
	
	[super viewDidLoad];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[passwordTextField release];
	[userNameTextField release];
    [super dealloc];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	[self saveSettings];
	
    return YES;
}

+ (SettingsUIViewController*) buildSettingsUIViewController {
	SettingsUIViewController * controller = [[SettingsUIViewController alloc] initWithNibName:@"Settings" bundle:nil];
	controller.title = NSLocalizedString( @"Settings", @"settings title" );
	[controller autorelease];
	return controller;
}


- (IBAction) runTests {
	
#ifdef TESTING_ENABLED
	
	/*
	// post worker test
	PostWorker* worker = [[PostWorker alloc] init];
	worker.url = @"http://boardgamegeek.com/login";
	worker.usePost = YES;
	
	NSMutableDictionary * params= [[NSMutableDictionary alloc] initWithCapacity:5];
	[params setObject:@"ryanch" forKey:@"username"];
	[params setObject:@"ddd" forKey:@"password"];
	
	worker.params = params;
	
	[params release];
	
	[worker start];
	
	
	NSLog(  [[NSString  alloc] initWithData:worker.receivedData	encoding: NSUTF8StringEncoding  ] );
	*/
	BGGConnect * bggConnect = [[BGGConnect alloc] init];
	
	bggConnect.username = @"ryanchtest";
	bggConnect.password = @"go";
	
	BGGConnectResponse response = [bggConnect simpleLogPlayForGameId: 31260 forDate: [NSDate date] numPlays: 1 ];
	NSLog(@"result %d" , response	);
	
	[bggConnect	 release];
	
	
	
#endif
	
}


@end
