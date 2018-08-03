//
//  VideoData.m
//  Video
//
//  Created by Tianhang Yu on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoData.h"


@implementation VideoData

@dynamic title;
@dynamic publishTime;
@dynamic source;
@dynamic url;
@dynamic coverImageURL;
@dynamic downloadURL;
@dynamic duration;
@dynamic size;
@dynamic behotTime;
@dynamic shareURL;
@dynamic diggCount;
@dynamic buryCount;
@dynamic commentCount;
@dynamic userDigged;
@dynamic userBuried;
@dynamic format;
@dynamic playCount;
@dynamic rate;
@dynamic tip;
@dynamic socialActionStr;
@dynamic altDownloadURL;
@dynamic altFormat;

@dynamic localURL;
@dynamic localPath;
@dynamic downloadStatus;
@dynamic downloadTime;
@dynamic userDownloaded;
@dynamic downloadDataStatus;
@dynamic downloadProgress;
@dynamic hasRead;
@dynamic totalLength;
@dynamic addHistory;
@dynamic historyTime;

+ (NSString *)entityName
{
    return @"VideoData";
}

+ (NSDictionary *)keyMapping
{
    return [NSDictionary dictionaryWithObjects:
            [NSArray arrayWithObjects:@"tag",
            						  @"group_id",
            						  @"title",
            						  @"publish_time",
            						  @"source",
            						  @"url",
            						  @"cover_image_url",
            						  @"download_url",
            						  @"duration",
            						  @"size",
            						  @"behot_time",
            						  @"share_url",
            						  @"digg_count",
            						  @"bury_count",
            						  @"repin_count",
            						  @"comment_count",
            						  @"user_digg",
            						  @"user_bury",
            						  @"user_repin",
                                      @"user_repin_time",
            						  @"format",
                                     @"play_count",
                                     @"rate",
                                     @"tip",
                                     @"social_action_str",
                                     @"alt_download_url",
                                     @"alt_format",
            						  nil]
                                       forKeys:
            [NSArray arrayWithObjects:@"tag",
            						  @"groupID",
            						  @"title",
            						  @"publishTime",
            						  @"source",
            						  @"url",
            						  @"coverImageURL",
            						  @"downloadURL",
            						  @"duration",
            						  @"size",
            						  @"behotTime",
            						  @"shareURL",
            						  @"diggCount",
            						  @"buryCount",
            						  @"repinCount",
            						  @"commentCount",
            						  @"userDigged",
            						  @"userBuried",
            						  @"userRepined",
                                      @"userRepinTime",
            						  @"format",
                                     @"playCount",
                                     @"rate",
                                     @"tip",
                                     @"socialActionStr",
                                     @"altDownloadURL",
                                     @"altFormat",
            						  nil]];
}

@end
