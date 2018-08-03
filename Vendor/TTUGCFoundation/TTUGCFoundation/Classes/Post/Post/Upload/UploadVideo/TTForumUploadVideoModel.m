//
//  TTForumUploadVideoModel.m
//  Article
//
//  Created by 徐霜晴 on 16/10/12.
//
//

#import "TTForumUploadVideoModel.h"

@implementation TTForumUploadVideoModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.coverImage = [aDecoder decodeObjectForKey:@"coverImage"];
        self.videoId = [aDecoder decodeObjectForKey:@"videoId"];
        self.videoName = [aDecoder decodeObjectForKey:@"videoName"];
        self.videoPath = [aDecoder decodeObjectForKey:@"videoPath"];
        self.videoDuration = [aDecoder decodeIntegerForKey:@"videoDuration"];
        self.videoSourceType = [aDecoder decodeIntegerForKey:@"videoSourceType"];
        self.isUploaded = [aDecoder decodeIntegerForKey:@"isUploaded"];
        self.timeConsume = [aDecoder decodeInt64ForKey:@"timeConsume"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.videoCoverSourceType = [aDecoder decodeIntegerForKey:@"videoCoverSourceType"];
        self.coverImageTimestamp = [aDecoder decodeFloatForKey:@"coverImageTimestamp"];
        self.musicID = [aDecoder decodeObjectForKey:@"musicID"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_coverImage forKey:@"coverImage"];
    [aCoder encodeObject:_videoId forKey:@"videoId"];
    [aCoder encodeObject:_videoName forKey:@"videoName"];
    [aCoder encodeObject:_videoPath forKey:@"videoPath"];
    [aCoder encodeInteger:_videoDuration forKey:@"videoDuration"];
    [aCoder encodeInteger:_videoSourceType forKey:@"videoSourceType"];
    [aCoder encodeInteger:_isUploaded forKey:@"isUploaded"];
    [aCoder encodeInt64:_timeConsume forKey:@"timeConsume"];
    [aCoder encodeFloat:_height forKey:@"height"];
    [aCoder encodeFloat:_width forKey:@"width"];
    [aCoder encodeInteger:_videoCoverSourceType forKey:@"videoCoverSourceType"];
    [aCoder encodeFloat:_coverImageTimestamp forKey:@"coverImageTimestamp"];
    [aCoder encodeObject:_musicID forKey:@"musicID"];
}

@end
