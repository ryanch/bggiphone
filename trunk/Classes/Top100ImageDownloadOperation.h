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

@interface Top100ImageDownloadOperation : NSOperation {
	BBGSearchResult * searchResult;
	BrowseTop100ViewController * top100View;
}

- (id)initWithResult:(BBGSearchResult*)result forView: (BrowseTop100ViewController*) view;



@end
