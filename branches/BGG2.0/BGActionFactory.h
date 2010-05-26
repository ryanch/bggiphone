//
//  BGActionFactory.h
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGDevice.h"
#import "BGAction.h"


@interface BGActionFactory : NSObject {
	BGDevice * device;
}

@property (nonatomic, retain) BGDevice * device;

- (BGAction*) fetchBGAction:(NSString*) actionURL;

@end
