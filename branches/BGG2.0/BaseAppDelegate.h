//
//  BaseAppDelegate.h
//  BGG2.0
//
//  Created by rchristi on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGCore.h"
#import "BGDevice.h"

@interface BaseAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	BGCore * core;
}



@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic,retain, readonly) BGCore * core;

- (BGDevice*) buildBGDevice;

@end
