//
//  TTVideoPasterADModel.m
//  Article
//
//  Created by Dai Dongpeng on 5/25/16.
//
//

#import "TTVideoPasterADModel.h"
#import "ExploreVideoModel.h"
#import "NSDictionary+TTAdditions.h"    

@implementation TTVideoPasterADModel

@end

@implementation TTVideoPasterADInfoModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"ad_id" : NSStringFromSelector(@selector(adID)),
                                                       @"type" : NSStringFromSelector(@selector(type)),
                                                       @"log_extra" : NSStringFromSelector(@selector(logExtra)),
                                                       @"open_url" : NSStringFromSelector(@selector(openURL)),
                                                       @"web_url" : NSStringFromSelector(@selector(webURL)),
                                                       @"web_title" : NSStringFromSelector(@selector(webTitle)),
                                                       @"appleid" : NSStringFromSelector(@selector(appleID)),
                                                       @"app_name" : NSStringFromSelector(@selector(appName)),
                                                       @"download_url" : NSStringFromSelector(@selector(downloadURL)),
                                                       @"button_text" : NSStringFromSelector(@selector(buttonText)),
                                                       @"display_time" : NSStringFromSelector(@selector(duration)),
                                                       @"enable_click" : NSStringFromSelector(@selector(enableClick)),
                                                       @"track_url_list" : NSStringFromSelector(@selector(trackURLList)),
                                                       @"click_track_url_list" : NSStringFromSelector(@selector(clickTrackURLList)),
                                                       @"predownload" : NSStringFromSelector(@selector(preDownload)),
                                                       @"video_info" : NSStringFromSelector(@selector(videoInfo)),
                                                       @"image_list" : NSStringFromSelector(@selector(imageList)),
                                                       @"title" : NSStringFromSelector(@selector(title)),
                                                       @"title_display_time" : NSStringFromSelector(@selector(titleTime))
                                                      }];
}

- (NSArray *)allURLWithtransformedURL:(BOOL)transformed
{
//    return [self.videoInfo allURLForVideoID:[self.adID stringValue] transformedURL:transformed];
    return nil;
}
@end

@implementation TTVideoPasterADVideoInfoModel

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"video_id" : NSStringFromSelector(@selector(videoID)),
                                                       @"video_group_id" : NSStringFromSelector(@selector(videoGroupID)),
                                                       @"play_track_url_list" : NSStringFromSelector(@selector(playTrackURLList)),
                                                       @"playover_track_url_list" : NSStringFromSelector(@selector(playOverTrackURLList)),
                                                       @"effective_play_time" : NSStringFromSelector(@selector(effectivePlayTime)),
                                                       @"effective_play_track_url_list" : NSStringFromSelector(@selector(effectivePlayTrackURLList)),
                                                       }];
}

@end
