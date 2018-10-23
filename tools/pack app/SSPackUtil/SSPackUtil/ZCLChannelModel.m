//
//  ZCLChannelModel.m
//  SSPackUtil
//
//  Created by Zhang Leonardo on 14-11-26.
//  Copyright (c) 2014年 leonardo. All rights reserved.
//

#import "ZCLChannelModel.h"

@implementation ZCLChannelModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.channelID = [aDecoder decodeObjectForKey:@"channelID"];
        self.checked = [aDecoder decodeBoolForKey:@"checked"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_channelID forKey:@"channelID"];
    [aCoder encodeBool:_checked forKey:@"checked"];
    
}

@end
