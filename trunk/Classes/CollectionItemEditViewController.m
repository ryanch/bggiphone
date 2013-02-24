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
#import "CollectionItemData.h"
#import "DbAccess.h"

#define OBJECT_ID_OWN 1
#define OBJECT_ID_WANT_TO_PLAY 2
#define OBJECT_ID_FOR_TRADE 3
#define OBJECT_ID_WANT_IN_TRADE 4
#define OBJECT_ID_PREORDERED 5
#define OBJECT_ID_OWNED 7
#define OBJECT_ID_WANT_TO_BUY 8
#define OBJECT_ID_WISHLIST 9



@implementation CollectionItemEditViewController

@synthesize gameTitle;
@synthesize scroller;
@synthesize collectionForm;
@synthesize gameId;

- (void) loadCurrentData {
	
	if ( ![self confirmUserNameAndPassAvailable] ) {
		return;
	}
	
	if ( disclLabel.hidden == YES ) {
		return;
	}
	
	disclLabel.hidden = YES;
	savingLabel.hidden = YES;
	loadingLabel.hidden = NO;
	savingIndicator.hidden = NO;
	[savingIndicator startAnimating];
	[scroller scrollRectToVisible:CGRectMake(0	, 0, 1, 1) animated:YES];	
	
	[NSThread detachNewThreadSelector:@selector(threadLoadCurrentData) toTarget:self withObject:nil];
	
}

- (void) threadLoadCurrentData {
    
        BGGConnect * connect = [[BGGConnect alloc]init];
        itemData = [connect handleFetchOfCollectionDataOfGameId:gameId];
		
		[self performSelectorOnMainThread:@selector(loadCurrentDataComplete) withObject:self waitUntilDone:YES];
	
	
}

- (void) loadCurrentDataComplete {
	disclLabel.hidden = NO;
	savingIndicator.hidden = YES;
	loadingLabel.hidden = YES;
	
	
    BGGConnect * connect = [[BGGConnect alloc]init];
    [connect showErrorForBadCollectionDataRead:itemData];
    
	if ( itemData == nil ) {
		return;
	}
    
    itemData.gameId = gameId;
	
	UISegmentedControl * segControl;
	BOOL chooseOne = NO;
	
	
	segControl = (UISegmentedControl *)[collectionForm viewWithTag:OBJECT_ID_OWN];
	chooseOne = itemData.own;
	segControl.selectedSegmentIndex = chooseOne ? 0 : 1;
	
	segControl =  (UISegmentedControl *)[collectionForm viewWithTag:OBJECT_ID_WANT_TO_PLAY];
	chooseOne = itemData.wantToPlay;
	segControl.selectedSegmentIndex = chooseOne ? 0 : 1;	
	
	segControl =  (UISegmentedControl *)[collectionForm viewWithTag:OBJECT_ID_FOR_TRADE];
	chooseOne = itemData.forTrade;
	segControl.selectedSegmentIndex = chooseOne ? 0 : 1;		
	
	segControl =  (UISegmentedControl *)[collectionForm viewWithTag:OBJECT_ID_WANT_IN_TRADE];
	chooseOne = itemData.wantInTrade;
	segControl.selectedSegmentIndex = chooseOne ? 0 : 1;			
	
	segControl =  (UISegmentedControl *)[collectionForm viewWithTag:OBJECT_ID_PREORDERED];
	chooseOne = itemData.preOrdered;
	segControl.selectedSegmentIndex = chooseOne ? 0 : 1;			
	
	segControl =  (UISegmentedControl *)[collectionForm viewWithTag:OBJECT_ID_OWNED];
	chooseOne = itemData.prevOwn;
	segControl.selectedSegmentIndex = chooseOne ? 0 : 1;			
	
	segControl =  (UISegmentedControl *)[collectionForm viewWithTag:OBJECT_ID_WANT_TO_BUY];
	chooseOne = itemData.wantToBuy;
	segControl.selectedSegmentIndex = chooseOne ? 0 : 1;
	
	segControl =  (UISegmentedControl *)[collectionForm viewWithTag:OBJECT_ID_WISHLIST];
	chooseOne = itemData.inWish;
	segControl.selectedSegmentIndex = chooseOne ? 0 : 1;	
	
	NSInteger wishChoiceValue = itemData.wishValue;
	[wishSlider setValue:wishChoiceValue+1];	
	
	[wishListTitle	setText: [wishTexts objectAtIndex:wishChoiceValue] ];
	
	
	UIBarButtonItem * save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target: self action: @selector(saveButtonPressed)];
	
	[save setEnabled:YES];
	self.navigationItem.rightBarButtonItem = save;
	
	
}


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

		wishTexts = [[NSArray alloc] initWithObjects: 
					 @"Must have",@"Love to have",@"Like to have",@"Thinking about it",@"Don't buy this",nil
		];
		
		
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
		

	
	
	[wishSlider addTarget:self	action:@selector(wishSliderUpdated) forControlEvents:UIControlEventValueChanged];
	
	[self loadCurrentData];
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
	
#ifdef PINCH_ENABLED	
	[[Beacon shared] startSubBeaconWithName:@"modify collection" timeSession:NO];
#endif	

	// start the network thread
	[NSThread detachNewThreadSelector:@selector(doModifyCollection) toTarget:self withObject:nil];
}

- (void) doModifyCollection {
		
    BGGConnect * connect = [[BGGConnect alloc ] init];
    

    saveResponse = [connect handleSaveCollectionForGameId:gameId withParams:paramsToSave withData:itemData];
    
    [self performSelectorOnMainThread:@selector(doModifyCollectionComplete) withObject:self waitUntilDone:YES];
	

	
	
}

- (void) doModifyCollectionComplete {
	
    
    BGGConnect * connect = [[BGGConnect alloc] init];
    [connect showErrorForBadCollectionDataWrite:saveResponse];
    
    
	// update lists
	//- (void) saveGameForListGameId: (NSInteger) gameId title: (NSString*) title list: (NSInteger) listType {
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	DbAccess * dbAccess = appDelegate.dbAccess;
	
	[dbAccess saveGameForListGameId:itemData.gameId title:gameTitle list:LIST_TYPE_OWN isInList: itemData.own];
	[dbAccess saveGameForListGameId:itemData.gameId title:gameTitle list:LIST_TYPE_WISH isInList: itemData.inWish];
	[dbAccess saveGameForListGameId:itemData.gameId title:gameTitle list:LIST_TYPE_TOPLAY isInList: itemData.wantToPlay];
	

	
	
	disclLabel.hidden = NO;
	savingLabel.hidden = YES;
	savingIndicator.hidden = YES;
}


- (BOOL) confirmUserNameAndPassAvailable {
	
	
	
	BGGAppDelegate *appDelegate = (BGGAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	return [appDelegate confirmUserNameAndPassAvailable];
	
	
	
}

- (void) wishSliderUpdated {
	
	NSString * value;
	
	if( wishSlider.value < 1.5 ) {
		
		[wishListTitle setText: [wishTexts objectAtIndex:0] ];
		value =@"1";
	}
	else if( wishSlider.value <2.5 ) {
		[wishListTitle setText: [wishTexts objectAtIndex:1]];
		value =@"2";
	}	
	else if( wishSlider.value  <3.5 ) {
		[wishListTitle setText: [wishTexts objectAtIndex:2]];
		value =@"3";
	}	
	else if( wishSlider.value  <4.5 ) {
		[wishListTitle setText: [wishTexts objectAtIndex:3]];
		value =@"4";
	}
	else  {
		[wishListTitle setText: [wishTexts objectAtIndex:4]];
		value =@"5";
	}	
	
	
	
	
	[paramsToSave setObject:value forKey:@"wishlistpriority"];
	
	NSLog( @"slider updated: %@", value );
	
	
	
}

- (IBAction) segControlChanged: (UISegmentedControl *) control {
	
	NSString * name;
	
	BOOL segOneActive = (control.selectedSegmentIndex == 0);
	
	if( control.tag == OBJECT_ID_OWN ) {
		itemData.own = segOneActive;
		name = @"own";
	}
	else if( control.tag == OBJECT_ID_WANT_TO_BUY ) {
		itemData.wantToBuy = segOneActive;
		name = @"wanttobuy";
	}		
	else if( control.tag == OBJECT_ID_WANT_TO_PLAY ) {
		itemData.wantToPlay = segOneActive;
		name = @"wanttoplay";
	}	
	else if( control.tag == OBJECT_ID_FOR_TRADE ) {
		itemData.forTrade = segOneActive;
		name = @"fortrade";
	}	
	else if( control.tag == OBJECT_ID_WANT_IN_TRADE ) {
		itemData.wantInTrade = segOneActive;
		name = @"want";
	}	
	else if( control.tag == OBJECT_ID_PREORDERED ) {
		itemData.preOrdered = segOneActive;
		name = @"preordered";
	}	
	else if( control.tag == OBJECT_ID_WISHLIST ) {
		itemData.inWish = segOneActive;
		name = @"wishlist";
	}	
	else if( control.tag == OBJECT_ID_OWNED ) {
		itemData.prevOwn = segOneActive;
		name = @"prevowned";
	}
	else {
		name = @"dont know";
	}
	
	NSLog(@"control changed: %d, name: %@ tag: %d", control.selectedSegmentIndex, name, control.tag );
	
	
	
	if ( segOneActive ) {
		[paramsToSave setObject:@"1" forKey:name];
	}
	else {
		[paramsToSave removeObjectForKey:name];
	}
	

	
}

- (IBAction) switchChanged: (UISwitch *) control {
	NSString * name;
	
	
		name = @"dont know";
	
	
	NSLog(@"control changed: %d, name: %@ tag: %d", control.on, name, control.tag );
	
	if ( control.on ) {
		[paramsToSave setObject:@"1" forKey:name];
	}
	else {
		[paramsToSave removeObjectForKey:name];
	}	
}


@end
