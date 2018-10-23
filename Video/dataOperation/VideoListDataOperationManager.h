//
//  VideoListDataOperation.h
//  Essay
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListDataOperationManager.h"

@interface VideoListDataOperationManager : ListDataOperationManager
+ (VideoListDataOperationManager*)sharedOperation;
@end
