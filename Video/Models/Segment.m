//
//  Segment.m
//  Video
//
//  Created by Dianwei on 12-7-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "Segment.h"


@implementation Segment

@dynamic localPath;
@dynamic localURLString;
@dynamic remoteURLString;
@dynamic groupID;
@dynamic segmentID;
@dynamic length;
@dynamic downloadStatus;
@dynamic start;
@dynamic end;

+ (NSString*)entityName
{
    return @"Segment";
}

+ (NSArray*)primaryKeys
{
    return [NSArray arrayWithArray:[NSArray arrayWithObjects:@"groupID", @"segmentID", nil]];
}

+ (NSDictionary*)keyMapping
{
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"group_id", @"segment_id", @"local_path", @"local_url", @"original_url", @"length", @"download_status", @"start", @"end", nil]
                                       forKeys:[NSArray arrayWithObjects:@"groupID", @"segmentID", @"localPath", @"localURLString", @"remoteURLString", @"length", @"downloadStatus", @"start", @"end",  nil]];
}



@end
