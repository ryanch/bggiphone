//
//  Top100ImageDownloadOperation.h
//  BGG
//
//  Created by Ryan Christianson on 1/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBGSearchResult.h"
#import "BrowseTop100ViewController.h"
#import "BoardGameSearchResultsTableViewController.h"

@interface Top100ImageDownloadOperation : NSOperation {
	BBGSearchResult * searchResult;
	BrowseTop100ViewController * top100View;
    BoardGameSearchResultsTableViewController * searchView;
}

- (id)initWithResult:(BBGSearchResult*)result forView: (BrowseTop100ViewController*) view;
- (id)initWithResult:(BBGSearchResult*)result forSearchView: (BoardGameSearchResultsTableViewController*) view;


@end
