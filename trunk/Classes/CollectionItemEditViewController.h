//
//  CollectionItemEditViewController.h
//  BGG
//
//  Created by RYAN CHRISTIANSON on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WishListPicker;
@class CollectionItemData;

@interface CollectionItemEditViewController : UIViewController {
	IBOutlet UIScrollView * scroller;
	IBOutlet UIView * collectionForm;

	IBOutlet UILabel * disclLabel;
	IBOutlet UILabel * savingLabel;
	IBOutlet UILabel * loadingLabel;
	
	IBOutlet UIActivityIndicatorView * savingIndicator;
	IBOutlet UILabel * wishListTitle;
	IBOutlet UISlider * wishSlider;
	
	NSInteger gameId;
	NSMutableDictionary *paramsToSave;
	CollectionItemData* itemData;
	NSArray * wishTexts;
	NSString * gameTitle;
}

@property( nonatomic,retain) NSString * gameTitle;
@property (nonatomic ) NSInteger gameId;

@property (nonatomic, retain ) UIScrollView * scroller;
@property (nonatomic, retain ) UIView * collectionForm;

- (IBAction) saveButtonPressed;

- (BOOL) confirmUserNameAndPassAvailable;

- (void) doModifyCollection;

- (void) doModifyCollectionComplete;


- (void) wishSliderUpdated;

- (IBAction) segControlChanged: (UISegmentedControl *) control;
- (IBAction) switchChanged: (UISwitch *) control;

- (void) loadCurrentData;
- (void) threadLoadCurrentData;
- (void) loadCurrentDataComplete;

@end
