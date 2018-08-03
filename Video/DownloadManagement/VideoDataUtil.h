//
//  VideoDataUtil.h
//  Video
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoDataUtil : NSObject

+ (NSString*)localBasePath;
+ (NSString*)localBaseURLString;
+ (NSString*)localBaseTempPath;
+ (NSString*)destinationBasePathForGroupID:(int)groupID;
+ (NSString*)temporaryBasePathForGroupID:(int)groupID;
@end
