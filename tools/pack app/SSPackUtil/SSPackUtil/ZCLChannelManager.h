//
//  ZCLChannelManager.h
//  SSPackUtil
//
//  Created by Zhang Leonardo on 14-11-26.
//  Copyright (c) 2014年 leonardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCLChannelModel.h"

@interface ZCLChannelManager : NSObject

+ (NSArray *)channelIDs;

+ (ZCLChannelModel *)modelByChannelID:(NSString *)channelID;

+ (void)save:(NSArray *)models;


@end
