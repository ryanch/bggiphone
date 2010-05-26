//
//  BGAction.h
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BGCore;

@interface BGAction : NSObject {
	BGCore * bgCore;
}

@property(nonatomic, retain) BGCore * bgCore;

- (void) executeActionAnimated: (BOOL) animated withCore: (BGCore*) core;

- (void) operationMain;


@end
