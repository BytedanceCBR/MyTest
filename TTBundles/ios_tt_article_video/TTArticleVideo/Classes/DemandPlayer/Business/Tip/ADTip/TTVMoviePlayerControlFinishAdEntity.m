//
//  TTVMoviePlayerControlFinishAdEntity.m
//  Article
//
//  Created by panxiang on 2017/7/20.
//
//

#import "TTVMoviePlayerControlFinishAdEntity.h"
#import "TTADEventTrackerEntity.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "TTVADCellApp+ComputedProperties.h"
#import "TTVADInfo+ActionTitle.h"
#import "TTVAdActionButtonCreation.h"
#import "TTVADCell+ADInfo.h"
#import "TTVFeedItem+Extension.h"
#import "Common.pbobjc.h"
@implementation TTVMoviePlayerControlFinishAdEntity

+ (TTVMoviePlayerControlFinishAdEntity *)entityWithData:(TTVFeedItem *)data
{
    if ([data isKindOfClass:[TTVFeedItem class]]) {
        TTVFeedItem *item = data;
        TTVADCell *adCell = item.adCell;
        TTVMoviePlayerControlFinishAdEntity *entity = [[TTVMoviePlayerControlFinishAdEntity alloc] init];
        entity.title = item.article.source;
        entity.webUrl = item.adInfo.webURL;
        entity.actionTitle = [adCell actionButtonTitle];
        entity.openURL = [adCell openUrl];
        if (!isEmptyString(entity.openURL) && adCell.hasPhone) {
            entity.openURL = item.article.articleURL;
        }
        entity.avatarUrl = [item videoUserInfo].avatarURL;
        entity.trackerEntity = [TTADEventTrackerEntity entityWithData:item];
        entity.ttv_command = getCommandInstance(item.videoBusinessType);
        entity.ttv_command.feedItem = item;
        return entity;
    }
    return nil;
}

@end


