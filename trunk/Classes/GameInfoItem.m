//
//  GameInfoItem.m
//  BGG
//
//  Created by Christianson, Ryan on 3/2/13.
//
//

#import "GameInfoItem.h"

@implementation GameInfoItem



+ (NSString*) displayNameForType:(NSString*)name {
    
    /*
     
     [elementName isEqualToString:@"boardgamehonor" ] ||
     [elementName isEqualToString:@"boardgamemechanic" ] ||
     [elementName isEqualToString:@"boardgamecategory" ] ||
     [elementName isEqualToString:@"boardgamedesigner" ] ||
     [elementName isEqualToString:@"boardgameartist" ] ||
     [elementName isEqualToString:@"boardgamepublisher" ] ||
     [elementName isEqualToString:@"boardgameversion" ] ||
     [elementName isEqualToString:@"boardgameexpansion" ] ||
     [elementName isEqualToString:@"boardgamefamily" ]
     
     */
    
    
    if ( [name compare:@"boardgamehonor" ] == NSOrderedSame ) {
        return NSLocalizedString(@"Honors", @"honors");
    }
    else if ( [name compare:@"boardgamemechanic" ]  == NSOrderedSame  ) {
        return NSLocalizedString(@"Mechanic", @"Mechanic");
    }
    else if ( [name compare:@"boardgamecategory" ]  == NSOrderedSame  ) {
        return NSLocalizedString(@"Category", @"Category");
    }
    else if ( [name compare:@"boardgamedesigner" ]  == NSOrderedSame  ) {
        return NSLocalizedString(@"Designer", @"Designer");
    }
    else if ( [name compare:@"boardgameartist" ]  == NSOrderedSame  ) {
        return NSLocalizedString(@"Artist", @"artist");
    }
    else if ( [name compare:@"boardgamepublisher" ]  == NSOrderedSame  ) {
        return NSLocalizedString(@"Publisher", @"Publisher");
    }
    else if ( [name compare:@"boardgameversion" ]  == NSOrderedSame  ) {
        return NSLocalizedString(@"Versions", @"versions");
    }
    else if ( [name compare:@"boardgameexpansion" ]  == NSOrderedSame  ) {
        return NSLocalizedString(@"Expansion", @"Expansion");
    }
    else if ( [name compare:@"boardgamefamily" ]  == NSOrderedSame  ) {
        return NSLocalizedString(@"Family", @"Family");
    }
    
    
    
    
     return NSLocalizedString(@"Info", @"info");
}

@end
