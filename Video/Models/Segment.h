//
//  Segment.h
//  Video
//
//  Created by Dianwei on 12-7-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSEntityBase.h"


typedef enum SegmentDownloadStatus
{
    SegmentDownloadStatusNotStarted,
    SegmentDownloadStatusDownloading,
    SegmentDownloadStatusFinished
}SegmentDownloadStatus;

@interface Segment : SSEntityBase

@property (nonatomic, retain) NSString * localPath;
@property (nonatomic, retain) NSString * localURLString;
@property (nonatomic, retain) NSString * remoteURLString;
@property (nonatomic, retain) NSNumber * groupID;
@property (nonatomic, retain) NSNumber * segmentID;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSNumber * downloadStatus;

// only used by single file, such as mp4 downloads
@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) NSNumber * end;
@end
