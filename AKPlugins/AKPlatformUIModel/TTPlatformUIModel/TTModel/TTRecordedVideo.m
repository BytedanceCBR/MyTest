//
//  TTRecordedVideo.m
//  Article
//
//  Created by xuzichao on 2017/6/13.
//
//

#import "TTRecordedVideo.h"

@implementation TTRecordedVideo;

- (NSString *)description {
    NSString *des = [NSString stringWithFormat:@"TTRecorderVideo %p \ntitle:%@ \nsource:%ld \nvideoURL:%@ \nvideoAsset:%@ \nvideoCoverSource:%ld, \ncoverImage:%@", self, self.title, (long)self.videoSource, self.videoURL, self.videoAsset, (long)self.videoCoverSource, self.coverImage];
    return des;
}

@end
