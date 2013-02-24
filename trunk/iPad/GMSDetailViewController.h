//
//  GMSDetailViewController.h
//  ipadTest
//
//  Created by Christianson, Ryan on 2/24/13.
//  Copyright (c) 2013 Christianson, Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMSDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
