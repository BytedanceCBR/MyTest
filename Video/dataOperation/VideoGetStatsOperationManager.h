//
//  VideoGetStatsOperationManager.h
//  Video
//
//  Created by Kimi on 12-10-11.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "ListDataOperationManager.h"

@interface VideoGetStatsOperationManager : ListDataOperationManager

+ (VideoGetStatsOperationManager*)sharedOperation;
@end
