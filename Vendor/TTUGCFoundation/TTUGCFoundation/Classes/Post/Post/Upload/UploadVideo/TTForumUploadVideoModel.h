//
//  TTForumUploadVideoModel.h
//  Article
//
//  Created by 徐霜晴 on 16/10/12.
//
//

#import <Foundation/Foundation.h>
#import "FRUploadImageModel.h"
#import "TTRecordedVideo.h"

@interface TTForumUploadVideoModel : NSObject<NSCoding>

@property (nonatomic, strong) FRUploadImageModel *coverImage;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, assign) NSInteger videoDuration;
@property (nonatomic, copy) NSString *videoName;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) TTPostVideoSource videoSourceType;
@property (nonatomic, assign) NSTimeInterval coverImageTimestamp;
@property (nonatomic, assign) BOOL isUploaded;
@property (nonatomic, assign) uint64_t timeConsume;
@property (nonatomic, assign) TTVideoCoverSourceType videoCoverSourceType;
@property (nonatomic, copy) NSString *musicID;

@end
