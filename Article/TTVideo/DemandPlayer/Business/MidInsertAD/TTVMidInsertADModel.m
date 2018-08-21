//
//  TTVMidInsertADModel.m
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import "TTVMidInsertADModel.h"

@implementation TTVMidInsertADModel

@end

@implementation TTVMidInsertADInfoModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"ad_id" : @keypath(TTVMidInsertADInfoModel.new, adID),
                                                       @"type" : @keypath(TTVMidInsertADInfoModel.new, type),
                                                       @"skip_time" : @keypath(TTVMidInsertADInfoModel.new, skipTime),
                                                       @"display_type": @keypath(TTVMidInsertADInfoModel.new, displayType),
                                                       @"display_time": @keypath(TTVMidInsertADInfoModel.new, displayTime),
                                                       @"log_extra" : @keypath(TTVMidInsertADInfoModel.new, logExtra),
                                                       @"guide_start_time": @keypath(TTVMidInsertADInfoModel.new, guideStartTime),
                                                       @"ad_start_time": @keypath(TTVMidInsertADInfoModel.new, adStartTime),
                                                       @"enable_close" : @keypath(TTVMidInsertADInfoModel.new, enableClose),
                                                       @"open_url" : @keypath(TTVMidInsertADInfoModel.new, openURL),
                                                       @"web_url" : @keypath(TTVMidInsertADInfoModel.new, webURL),
                                                       @"web_title" : @keypath(TTVMidInsertADInfoModel.new, webTitle),
                                                       @"appleid" : @keypath(TTVMidInsertADInfoModel.new, appleID),
                                                       @"app_name" : @keypath(TTVMidInsertADInfoModel.new, appName),
                                                       @"download_url" : @keypath(TTVMidInsertADInfoModel.new, downloadURL),
                                                       @"button_text" : @keypath(TTVMidInsertADInfoModel.new, buttonText),
                                                       @"track_url_list" : @keypath(TTVMidInsertADInfoModel.new, trackURLList),
                                                       @"click_track_url_list" : @keypath(TTVMidInsertADInfoModel.new, clickTrackURLList),
                                                       @"video_info" : @keypath(TTVMidInsertADInfoModel.new, videoInfo),
                                                       @"guide_video_info" : @keypath(TTVMidInsertADInfoModel.new, guideVideoInfo),
                                                       @"image_list" : @keypath(TTVMidInsertADInfoModel.new, imageList),
                                                       @"guide_words" : @keypath(TTVMidInsertADInfoModel.new, guideWords),
                                                       @"guide_time" : @keypath(TTVMidInsertADInfoModel.new, guideTime),
                                                       }];
}
@end
