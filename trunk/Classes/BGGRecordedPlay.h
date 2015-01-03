//
//  BGGRecordedPlay.h
//  BGG
//
//  Created by Steve Moak on 9/24/14.
//
//

#import <Foundation/Foundation.h>

@interface BGGRecordedPlay : NSObject

@property (nonatomic, readwrite, strong) NSDate *date;
@property (nonatomic) NSInteger numPlays;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *comments;

@end
