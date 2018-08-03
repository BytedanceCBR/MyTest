//
//  ZCLChannelModel.h
//  SSPackUtil
//
//  Created by Zhang Leonardo on 14-11-26.
//  Copyright (c) 2014年 leonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCLChannelModel : NSObject<NSCoding>

@property(nonatomic, retain)NSString * channelID;
@property(nonatomic, assign)BOOL checked;
@end
