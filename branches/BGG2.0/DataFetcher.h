//
//  DataFetcher.h
//  TestApp
//
//  Created by rchristi on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDiscCache.h"

@interface DataFetcher : NSObject {

	ImageDiscCache * imageCache;
	
}

@property( nonatomic,retain) ImageDiscCache * imageCache;



@end
