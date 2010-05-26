//
//  BGActionOperation.h
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGAction.h"

@interface BGActionOperation : NSOperation {
	BGAction * bgAction;
}

@property( nonatomic,retain) BGAction * bgAction;

@end
