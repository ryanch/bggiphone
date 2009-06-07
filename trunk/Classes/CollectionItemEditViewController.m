//
//  CollectionItemEditViewController.m
//  BGG
//
//  Created by RYAN CHRISTIANSON on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CollectionItemEditViewController.h"
#import "BGGAppDelegate.h"
#import "BGGConnect.h"
#import "SettingsUIViewController.h"
#import "PlistSettings.h"
#import "Beacon.h"

#define OBJECT_ID_OWN 1
#define OBJECT_ID_WANT_TO_PLAY 2
#define OBJECT_ID_FOR_TRADE 3
#define OBJECT_ID_WANT_IN_TRADE 4
#define OBJECT_ID_PREORDERED 5
#define OBJECT_ID_OWNED 7
#define OBJECT_ID_WANT_TO_BUY 8
#define OBJECT_ID_WISHLIST 9

#define OBJECT_ID_NOTIFY_SALES 101
#define OBJECT_ID_NOTIFY_CONTENT 102
#define OBJECT_ID_NOTIFY_AUCTIONS 103

@implementation CollectionItemEditViewController

@synthesize scroller;
@synthesize collectionForm;
@synthesize gameId;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

		
		paramsToSave = [[NSMutableDictionary alloc] initWithCapacity:50];
		[paramsToSave setObject:@"1" forKey:@"wishlistpriority"];
		
		self.title = @"Modify Collection";
	}
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	[scroller setContentSize: collectionForm.frame.size ];
	[scroller addSubview:collectionForm];
		
	UIBarButtonItem * save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target: self action: @selector(saveButtonPressed)];
	
	[save setEnabled:YES];
	self.navigationItem.rightBarButtonItem = save;
	
	[save release];
	
	
	[wishSlider addTarget:self	action:@selector(wishSliderUpdated) forControlEvents:UIControlEventValueChanged];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[paramsToSave release];
	[collectionForm release];
	[scroller release];
    [super dealloc];
}



- (IBAction) saveButtonPressed {
	if ( ![self confirmUserNameAndPassAvailable] ) {
		return;
	}
	
	if ( !savingIndicator.hidden ) {
		return;
	}
	
	disclLabel.hidden = YES;
	savingLabel.hidden = NO;
	savingIndicator.hidden = NO;
	[savingIndicator startAnimating];
	[scroller scrollRectToVisible:CGRectMake(0	, 0, 1, 1) animated:YES];
	
	[[Beacon shared] startSubBeaconWithName:@"modify collection" timeSession:NO];
	

	// start the network thread
	[NSThread detachNewThreadSelector:@selector(doModifyCollection) toTarget:self withObject:nil];
}

- (void) doModifyCollection {
		
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	BGGConnect * bggConnect = [[BGGConnect alloc] init];
	
	
	bggConnect.username = [appDelegate.appSettings.dict objectForKey:@"username"];
	bggConnect.password = [appDelegate.appSettings.dict objectForKey:@"password"];
	
	BGGConnectResponse response = [bggConnect saveCollectionForGameId: gameId withParams: paramsToSave ];
	
	
	if ( response == SUCCESS ) {
		/// TODO UPDATE THE LOCAL DB
	}
	
	if ( response == SUCCESS ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success modification")
														message:NSLocalizedString(@"Your updates were saved.", @"Your updates were saved")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];		
	}
	else if ( response == BAD_CONTENT ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", @"Error moding")
														message:NSLocalizedString(@"Check your password, and network connection. I think the error is that BGG has been updated.", @"No data was returned when logged. Check your password, and network connection.")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
	}	
	else if ( response == CONNECTION_ERROR ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", @"Error moding")
														message:NSLocalizedString(@"Check your password, and network connection. I think the error is your network- or it is possible BGG has been updated.", @"No data was returned when logged. Check your password, and network connection.")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
	}
	else if ( response == AUTH_ERROR ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", @"Error Logging Play title")
														message:NSLocalizedString(@"Check your password, and network connection. I think the error is your password.", @"No data was returned when logged. Check your password, and network connection.")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
	}
	
	
	
	[bggConnect	 release];
	
	

	
	[self performSelectorOnMainThread:@selector(doModifyCollectionComplete) withObject:self waitUntilDone:YES];
	
	[autoreleasepool release];
	
	
}

- (void) doModifyCollectionComplete {
	disclLabel.hidden = NO;
	savingLabel.hidden = YES;
	savingIndicator.hidden = YES;
}


- (BOOL) confirmUserNameAndPassAvailable {
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	NSString * username = [appDelegate.appSettings.dict objectForKey:@"username"];
	NSString * password = [appDelegate.appSettings.dict objectForKey:@"password"];
	
	if ( username == nil || [username length] == 0 || password == nil || [password length] == 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Need Username and Password", @"ask user to provide username and pass title")
														message:NSLocalizedString(@"Please enter your username and password to modify your collection.", @"please give your username and password to modify your collection.")
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];	
		
		
		SettingsUIViewController * settings = [SettingsUIViewController buildSettingsUIViewController];
		
		[appDelegate.navigationController pushViewController:settings		animated:YES];
		
		return NO;
	}
	
	return YES;
	
}

- (void) wishSliderUpdated {
	
	NSString * value;
	
	if( wishSlider.value < 1.5 ) {
		
		[wishListTitle setText: @"Must have" ];
		value =@"1";
	}
	else if( wishSlider.value <2.5 ) {
		[wishListTitle setText: @"Love to have"];
		value =@"2";
	}	
	else if( wishSlider.value  <3.5 ) {
		[wishListTitle setText: @"Like to have"];
		value =@"3";
	}	
	else if( wishSlider.value  <4.5 ) {
		[wishListTitle setText: @"Thinking about it"];
		value =@"4";
	}
	else  {
		[wishListTitle setText: @"Don't buy this"];
		value =@"5";
	}	
	
	[paramsToSave setObject:value forKey:@"wishlistpriority"];
	
	//NSLog( @"slider updated: %@", value );
	
	
	
}

- (IBAction) segControlChanged: (UISegmentedControl *) control {
	
	NSString * name;
	
	
	if( control.tag == OBJECT_ID_OWN ) {
			name = @"own";
	}
	else if( control.tag == OBJECT_ID_WANT_TO_BUY ) {
		name = @"wanttobuy";
	}		
	else if( control.tag == OBJECT_ID_WANT_TO_PLAY ) {
		name = @"wanttoplay";
	}	
	else if( control.tag == OBJECT_ID_FOR_TRADE ) {
		name = @"fortrade";
	}	
	else if( control.tag == OBJECT_ID_WANT_IN_TRADE ) {
		name = @"want";
	}	
	else if( control.tag == OBJECT_ID_PREORDERED ) {
		name = @"preordered";
	}	
	else if( control.tag == OBJECT_ID_WISHLIST ) {
		name = @"wishlist";
	}	
	else if( control.tag == OBJECT_ID_OWNED ) {
		name = @"prevowned";
	}
	else {
		name = @"dont know";
	}
	
	NSLog(@"control changed: %d, name: %@ tag: %d", control.selectedSegmentIndex, name, control.tag );
	
	if ( control.selectedSegmentIndex == 0 ) {
		[paramsToSave setObject:@"1" forKey:name];
	}
	else {
		[paramsToSave removeObjectForKey:name];
	}
	
}

- (IBAction) switchChanged: (UISwitch *) control {
	NSString * name;
	
	
	if( control.tag == OBJECT_ID_NOTIFY_SALES ) {
		name = @"notifysale";
	}
	else if( control.tag == OBJECT_ID_NOTIFY_CONTENT ) {
		name = @"notifycontent";
	}		
	else if( control.tag == OBJECT_ID_NOTIFY_AUCTIONS ) {
		name = @"notifyauction";
	}	
	else {
		name = @"dont know";
	}
	
	NSLog(@"control changed: %d, name: %@ tag: %d", control.on, name, control.tag );
	
	if ( control.on ) {
		[paramsToSave setObject:@"1" forKey:name];
	}
	else {
		[paramsToSave removeObjectForKey:name];
	}	
}


@end
