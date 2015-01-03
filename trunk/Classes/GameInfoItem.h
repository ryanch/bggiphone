//
//  GameInfoItem.h
//  BGG
//
//  Created by Christianson, Ryan on 3/2/13.
//
//

#import <Foundation/Foundation.h>

@interface GameInfoItem : NSObject

@property NSString * name;
@property NSString * value;
@property NSString * idValue;

+ (NSString*) displayNameForType:(NSString*)name;

@end
