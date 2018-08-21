//
//  M3U8Parser.h
//  Video
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoData.h"

#define kM3U8ErrorDomain            @"kM3U8ErrorDomain"
#define kM3U8FileFormatErrorCode    1001

#define kM3U8SegmentVersionKey  @"kM3U8SegmentVersionKey"

@interface M3U8Segment : NSObject

@property(nonatomic, assign)int duration;
@property(nonatomic, copy)NSString *localUrlString;
@property(nonatomic, copy)NSString *originalURLString;
@property(nonatomic, copy)NSString *localPath;
- (NSDictionary*)dictionaryPresentation;

@end


@interface M3U8Parser : NSObject
- (id)initWithVideo:(VideoData*)video;

- (void)parse:(NSString*)content sourceURL:(NSURL*)sourceURL;
- (void)clearResult;

@property(nonatomic, retain, readonly)NSString *localContent;
@property(nonatomic, retain, readonly)NSError *error;
@property(nonatomic, readonly)NSArray *segments;
@property(nonatomic, readonly)NSDictionary *metaData;

@end
