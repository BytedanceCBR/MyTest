//
//  VideoStatsModel.h
//  Video
//
//  Created by 于 天航 on 12-8-7.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoStatsModel : NSObject

@property (nonatomic, retain) NSNumber *groupID;
@property (nonatomic, retain) NSNumber *userDigg;
@property (nonatomic, retain) NSNumber *userRepin;
@property (nonatomic, retain) NSNumber *userBury;
@property (nonatomic, retain) NSNumber *diggCount;
@property (nonatomic, retain) NSNumber *buryCount;
@property (nonatomic, retain) NSNumber *repinCount;
@property (nonatomic, retain) NSNumber *commentCount;
@property (nonatomic, retain) NSNumber *linkStatus;

- (id)initWithDictionary:(NSDictionary *)data;

@end
