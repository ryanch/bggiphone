//
//  RecordedPlaysViewController.h
//  BGG
//
//  Created by Steve Moak on 9/24/14.
//
//

#import <Foundation/Foundation.h>
#import "LoadingTableViewController.h"

@interface RecordedPlaysViewController : LoadingTableViewController

@property (nonatomic,strong) NSString * gameId;
@property (nonatomic,strong) NSString * origTitle;

@end
