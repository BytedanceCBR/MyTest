//
//  VideoStatsModel.m
//  Video
//
//  Created by 于 天航 on 12-8-7.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoStatsModel.h"

@implementation VideoStatsModel

@synthesize groupID;
@synthesize userDigg;
@synthesize userRepin;
@synthesize userBury;
@synthesize diggCount;
@synthesize buryCount;
@synthesize repinCount;
@synthesize commentCount;
@synthesize linkStatus;

- (void)dealloc
{
	self.groupID      = nil;
	self.userDigg     = nil;
	self.userRepin    = nil;
	self.userBury     = nil;
	self.diggCount    = nil;
	self.buryCount    = nil;
	self.repinCount   = nil;
	self.commentCount = nil;
	self.linkStatus   = nil;
	[super dealloc];
}

- (id)initWithDictionary:(NSDictionary *)data
{
	self = [super init];
	if (self) {
        
		self.groupID      = [data objectForKey:@"group_id"];
		self.userDigg     = [data objectForKey:@"user_digg"];
		self.userRepin    = [data objectForKey:@"user_bury"];
		self.userBury     = [data objectForKey:@"user_repin"];
		self.diggCount    = [data objectForKey:@"digg_count"];
		self.buryCount    = [data objectForKey:@"bury_count"];
		self.repinCount   = [data objectForKey:@"repin_count"];
		self.commentCount = [data objectForKey:@"comment_count"];
        self.linkStatus   = [data objectForKey:@"status"];
	}
	return self;
}

@end
