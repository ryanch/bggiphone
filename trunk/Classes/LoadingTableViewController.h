/*
 Copyright 2010 Petteri Kamppuri
 
 Licensed under the Apache License, Version 2.0 (the "License"); 
 you may not use this file except in compliance with the License. 
 You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed under the 
 License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
 either express or implied. See the License for the specific 
 language governing permissions and limitations under the License. 
 */ 

//
//  LoadingTableViewController.h
//  BGG
//
//  Created by Petteri Kamppuri on 6.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import "LoadingViewController.h"


@class FullGameInfo;


@interface LoadingTableViewController : LoadingViewController <UITableViewDelegate, UITableViewDataSource>
{
	
}

@property (nonatomic, readonly, retain) UITableView *tableView;


// Protected methods

-(void) tappedAtItemAtIndexPath:(NSIndexPath *)indexPath;

-(UITableViewCellStyle) cellStyle;

-(void) updateCell:(UITableViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

@end
