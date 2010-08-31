/*
 Copyright 2010 Petteri Kamppuri
 
 Licensed under the Apache License, Version 2.0 (the "License"); 
 you may not use this file except in compliance with the License. 
 You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed under the 
 License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
 either express or implied. See the License for the specific 
 language governing permissions and limitations under the License. 
 */ 

//
//  BGGHTMLScraper.m
//  BGG
//
//  Created by Petteri Kamppuri on 3.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import "BGGHTMLScraper.h"
#import "BBGSearchResult.h"
#import "BGGForum.h"
#import "BGGThread.h"
#import "BGGMessage.h"


@implementation BGGHTMLScraper

#pragma mark Private

- (NSString *) contentsOfTagWithStart:(NSString *)tagStart startTagEnd:(NSString *)startTagEnd endTag:(NSString *)endTag inRange:(NSRange)searchRange foundRange:(NSRange *)foundRange inSource:(NSString *)source
{
	// Find start tag

	NSRange tagStartRange = [source rangeOfString:tagStart options:0 range:searchRange];
	
	if(tagStartRange.location == NSNotFound)
		return nil;
	
	// Find end of startTag
	NSRange tagEndRange;
	if(startTagEnd != nil)
	{
		tagEndRange = [source rangeOfString:startTagEnd options:0 range:NSMakeRange(NSMaxRange(tagStartRange), [source length] - NSMaxRange(tagStartRange))];
		
		if(tagEndRange.location == NSNotFound)
			return nil;
	}
	else
		tagEndRange = tagStartRange;
	
	// Find end tag
	NSRange contentEndRange = [source rangeOfString:endTag options:0 range:NSMakeRange(NSMaxRange(tagEndRange), [source length] - NSMaxRange(tagEndRange))];
	
	if(contentEndRange.location == NSNotFound)
		return nil;
	
	NSRange contentsRange = NSMakeRange(NSMaxRange(tagEndRange), contentEndRange.location - NSMaxRange(tagEndRange));
	NSString *contents = [source substringWithRange:contentsRange];
	
	if(foundRange != NULL)
		*foundRange = contentsRange;
	
	return contents;
}

#pragma mark Public

-(NSArray *) scrapeMessagesFromThread:(NSString *)document
{
	if(cancelled)
		return nil;
	
	NSMutableArray *results = [NSMutableArray array];
	
	NSRange nameEnd = NSMakeRange(0, 0);
	while(nameEnd.location != NSNotFound && NSMaxRange(nameEnd) < [document length])
	{
		if(cancelled)
			return nil;
		
		// Find end of username
		NSRange nameEndSearchRange = NSMakeRange(nameEnd.location, [document length] - nameEnd.location);
		NSString *nameEndSearchString = @"</div>\n\t<div style='white-space:nowrap;'>(<a href=\"/user/";
		nameEnd = [document rangeOfString:nameEndSearchString options:0 range:nameEndSearchRange];
		
		if(nameEnd.location == NSNotFound)
			break;
		
		// Find start of username, backwards from end location
		NSRange nameStartRange = [document rangeOfString:@"<div>" options:NSBackwardsSearch range:NSMakeRange(0, nameEnd.location)];
		
		if(nameStartRange.location == NSNotFound)
		{
			NSLog(@"ERROR: Name start not found.");
			break;
		}
		
		// Get username
		NSString *username = [document substringWithRange:NSMakeRange(NSMaxRange(nameStartRange), nameEnd.location - NSMaxRange(nameStartRange))];
		
		// Find nickname (URL encoded version) end
		NSRange nickSearchRange = NSMakeRange(NSMaxRange(nameEnd), [document length] - NSMaxRange(nameEnd));
		NSRange nickEndRange = [document rangeOfString:@"\"" options:0 range:nickSearchRange];
		
		// Get nickname (URL encoded version) from name end max range to nickname end
		// <a href="/user/<nickname>"
		NSString *nickname = [document substringWithRange:NSMakeRange(NSMaxRange(nameEnd), nickEndRange.location - NSMaxRange(nameEnd))];
		
		NSRange messageRange;
		NSString *messageContents = [self contentsOfTagWithStart:@"<dd class=\"right\"" startTagEnd:@">" endTag:@"</dd>" inRange:NSMakeRange(NSMaxRange(nameEnd), [document length] - NSMaxRange(nameEnd)) foundRange:&messageRange inSource:document];
		
		NSRange dateRange;
		NSString *postedDate = [self contentsOfTagWithStart:@"http://geekdo-images.com/images/pixel.gif' /> Posted " startTagEnd:nil endTag:@"</a>" inRange:NSMakeRange(NSMaxRange(messageRange), [document length] - NSMaxRange(messageRange)) foundRange:&dateRange inSource:document];
		postedDate = [postedDate stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		
		// Advance
		nameEnd.location = NSMaxRange(nameEnd);
		nameEnd.length = 0;
		
		
		
		BGGMessage *message = [[[BGGMessage alloc] init] autorelease];
		
		message.username = username;
		message.nickname = [nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		message.contents = messageContents;
		message.postDate = postedDate;
		
		[results addObject:message];
	}
	
	if(cancelled)
		return nil;
	
	return results;
}

-(NSArray *) scrapeThreadsFromForum:(NSString *)document
{
	if(cancelled)
		return nil;
	
	NSMutableArray *results = [NSMutableArray array];
	
	NSRange urlStart = NSMakeRange(0, 0);
	while(urlStart.location != NSNotFound && NSMaxRange(urlStart) < [document length])
	{
		if(cancelled)
			return nil;
		
		// Find url start
		NSRange urlStartSearchRange = NSMakeRange(urlStart.location, [document length] - urlStart.location);
		urlStart = [document rangeOfString:@"<span class='forum_index_subject'><a href=\"" options:0 range:urlStartSearchRange];
		
		if(urlStart.location == NSNotFound)
			break;
		
		// Find url end
		NSRange urlEnd = [document rangeOfString:@"\">" options:0 range:NSMakeRange(NSMaxRange(urlStart), [document length] - NSMaxRange(urlStart))];
		
		// Get thread URL
		NSString *threadURL = [document substringWithRange:NSMakeRange(NSMaxRange(urlStart), urlEnd.location - NSMaxRange(urlStart))];
		
		// Find title end from url end
		NSRange titleEnd = [document rangeOfString:@"</a>" options:0 range:NSMakeRange(NSMaxRange(urlEnd), [document length] - NSMaxRange(urlEnd))];
		
		// Get thread title
		NSString *threadTitle = [document substringWithRange:NSMakeRange(NSMaxRange(urlEnd), titleEnd.location - NSMaxRange(urlEnd))];
		
		// Get last post date
		NSRange lastPostDateRange;
		NSString *lastPostDate = [self contentsOfTagWithStart:@"<div class='sf' style='line-height:16px; white-space:nowrap;'>\n\t\t\t\t\t<div>\n\t\t\t\t\t\t<a href=\"/article/" startTagEnd:@">" endTag:@"\n" inRange:NSMakeRange(NSMaxRange(titleEnd), [document length] - NSMaxRange(titleEnd)) foundRange:&lastPostDateRange inSource:document];
		lastPostDate = [lastPostDate stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		
		// Get last poster
		NSRange lastPosterRange;
		NSString *lastPoster = [self contentsOfTagWithStart:@"<div>\n\t\t\t\t\t\tby <a href=\"/user/" startTagEnd:@">" endTag:@"</a>" inRange:NSMakeRange(NSMaxRange(lastPostDateRange), [document length] - NSMaxRange(lastPostDateRange)) foundRange:&lastPosterRange inSource:document];
		lastPostDate = [lastPostDate stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		
		// Advance
		urlStart.location = NSMaxRange(lastPosterRange);
		urlStart.length = 0;
		
		
		// Get threadId
		NSString *threadId = nil;
		NSArray *threadURLComponents = [threadURL componentsSeparatedByString:@"/"];
		if([threadURLComponents count] >= 3)
			threadId = [threadURLComponents objectAtIndex:2];
		
		BGGThread *thread = [[[BGGThread alloc] init] autorelease];
		
		thread.title = threadTitle;
		thread.threadURL = threadURL;
		thread.threadId = threadId;
		thread.lastPoster = lastPoster;
		thread.lastPostDate = lastPostDate;
		
		[results addObject:thread];
	}
	
	return results;
}

-(NSArray *) scrapeForumsFromList:(NSString *)document
{
	if(cancelled)
		return nil;
	
	NSMutableArray *results = [NSMutableArray array];
	
	NSRange urlStart = NSMakeRange(0, 0);
	while(urlStart.location != NSNotFound && NSMaxRange(urlStart) < [document length])
	{
		if(cancelled)
			return nil;
		
		// Find url start
		NSRange urlStartSearchRange = NSMakeRange(urlStart.location, [document length] - urlStart.location);
		urlStart = [document rangeOfString:@"<span class='forum_title'><a href=\"" options:0 range:urlStartSearchRange];
		
		if(urlStart.location == NSNotFound)
			break;
		
		// Find url end
		NSRange urlEnd = [document rangeOfString:@"\">" options:0 range:NSMakeRange(NSMaxRange(urlStart), [document length] - NSMaxRange(urlStart))];
		
		// Get forum URL
		NSString *forumURL = [document substringWithRange:NSMakeRange(NSMaxRange(urlStart), urlEnd.location - NSMaxRange(urlStart))];
		
		// Find name end from url end
		NSRange nameEnd = [document rangeOfString:@"</a>" options:0 range:NSMakeRange(NSMaxRange(urlEnd), [document length] - NSMaxRange(urlEnd))];
		
		// Get forum name
		NSString *forumName = [document substringWithRange:NSMakeRange(NSMaxRange(urlEnd), nameEnd.location - NSMaxRange(urlEnd))];
		
		// Advance
		urlStart.location = NSMaxRange(urlEnd);
		urlStart.length = 0;
		
		
		// Get forumId
		NSString *forumId = nil;
		NSArray *forumURLComponents = [forumURL componentsSeparatedByString:@"/"];
		if([forumURLComponents count] >= 3)
			forumId = [forumURLComponents objectAtIndex:2];
		
		BGGForum *forum = [[[BGGForum alloc] init] autorelease];
		
		forum.name = forumName;
		forum.forumURL = forumURL;
		forum.forumId = forumId;
		
		[results addObject:forum];
	}
	
	return results;
}

-(NSArray *) scrapeGamesFromTop100:(NSString *)document
{
	// Find start of table of top 100 games
	NSRange tableStart = [document rangeOfString:@"id='collectionitems"];
	
	if(tableStart.location == NSNotFound)
	{
		NSLog(@"Invalid data, missing table start");
		return nil;
	}
	
	// Find end of the top 100 games table, use it to stop searches.
	NSRange tableEnd = [document rangeOfString:@"</table" options:0 range:NSMakeRange(NSMaxRange(tableStart), [document length] - NSMaxRange(tableStart))];
	
	if(tableStart.location == NSNotFound)
	{
		NSLog(@"Invalid data, missing table end");
		return nil;
	}
	
	if(cancelled)
		return nil;
	
	// <a  href="/boardgame/17226/descent-journeys-in-the-dark"   >Descent: Journeys in the Dark</a>
	
	NSMutableArray *results = [NSMutableArray array];
	
	NSRange ahrefStart = NSMakeRange(NSMaxRange(tableStart), 0);
	while(ahrefStart.location != NSNotFound && ahrefStart.location < tableEnd.location)
	{
		if(cancelled)
			return nil;
		
		// Find start of game id url link.
		NSRange ahrefSearchRange = NSMakeRange(ahrefStart.location, [document length] - ahrefStart.location);
		NSString *ahrefSearchString = @"<a  href=\"/boardgame/";
		ahrefStart = [document rangeOfString:ahrefSearchString options:0 range:ahrefSearchRange];
		
		if(ahrefStart.location == NSNotFound)
			break;
		
		// Find end of game id url link.
		NSRange ahrefEndSearchRange = NSMakeRange(NSMaxRange(ahrefStart), [document length] - NSMaxRange(ahrefStart));
		NSRange ahrefURLEnd = [document rangeOfString:@"\"" options:0 range:ahrefEndSearchRange];
		
		if(ahrefURLEnd.location == NSNotFound)
		{
			NSLog(@"ERROR: a href end not found.");
			break;
		}
		
		// Find game id end from url (url is "<id>/<encoded name>").
		NSRange urlRange = NSMakeRange(NSMaxRange(ahrefStart), ahrefURLEnd.location - NSMaxRange(ahrefStart));
		NSRange gameIDEndRange = [document rangeOfString:@"/" options:0 range:urlRange];
		
		if(gameIDEndRange.location == NSNotFound)
		{
			NSLog(@"ERROR: game ID '/' separator not found.");
			break;
		}
		
		// Get game id
		NSRange gameIdRange = NSMakeRange(urlRange.location, gameIDEndRange.location - urlRange.location);
		NSString *gameId = [document substringWithRange:gameIdRange];
		
		// Find game name start
		NSRange nameStart = [document rangeOfString:@">" options:0 range:NSMakeRange(ahrefURLEnd.location, [document length] - ahrefURLEnd.location)];
		
		if(nameStart.location == NSNotFound)
		{
			NSLog(@"ERROR: Name start not found.");
			break;
		}
		
		// Find name end
		NSRange nameEnd = [document rangeOfString:@"<" options:0 range:NSMakeRange(nameStart.location, [document length] - nameStart.location)];
		
		// Get game name
		NSRange nameRange = NSMakeRange(NSMaxRange(nameStart), nameEnd.location - NSMaxRange(nameStart));
		NSString *name = [document substringWithRange:nameRange];
		
		// Find thumbnail image url start, backwards from game id url start
		NSString *imageURLStartString = [NSString stringWithFormat:@"<a   href=\"/boardgame/%@\" ><img border=0  src=\"", [document substringWithRange:urlRange]];
		NSRange imageURLStartRange = [document rangeOfString:imageURLStartString options:NSBackwardsSearch range:NSMakeRange(0, ahrefStart.location)];
		
		NSString *imageURL = nil;
		if(imageURLStartRange.location != NSNotFound)
		{
			// Find thumbnail image url end
			NSRange imageURLEndRange = [document rangeOfString:@"\"" options:0 range:NSMakeRange(NSMaxRange(imageURLStartRange), [document length] - NSMaxRange(imageURLStartRange))];
			
			if(imageURLEndRange.location != NSNotFound)
			{
				// Get thumbnail image url
				NSRange imageURLRange = NSMakeRange(NSMaxRange(imageURLStartRange), imageURLEndRange.location - NSMaxRange(imageURLStartRange));
				imageURL = [document substringWithRange:imageURLRange];
			}
		}
		
		// Advance
		ahrefStart.location = NSMaxRange(ahrefURLEnd);
		
		
		BBGSearchResult *result = [[[BBGSearchResult alloc] init] autorelease];
		
		result.gameId = gameId;
		result.primaryTitle = name;
		result.imageURL = imageURL;
		
		[results addObject:result];
	}
	
	if(cancelled)
		return nil;
	
	return results;
}

-(void) cancel
{
	cancelled = YES;
}

@end
