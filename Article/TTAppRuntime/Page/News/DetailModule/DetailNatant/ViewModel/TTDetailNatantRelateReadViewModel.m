//
//  TTDetailNatantRelateReadViewModel.m
//  Article
//
//  Created by Ray on 16/4/7.
//
//

#import "TTDetailNatantRelateReadViewModel.h"
#import "TTRoute.h"
#import "SSUserSettingManager.h"
#import "ArticleDetailHeader.h"
#import "SSThemed.h"
#import "TTDetailContainerViewController.h"
#import "NewsDetailConstant.h"
#import "TTVideoAlbumView.h"
#import "TTVVideoDetailAlbumView.h"
#import "ArticleInfoManager.h"
#import "TTStringHelper.h"
 
#import "TTLabelTextHelper.h"
#import <Crashlytics/Crashlytics.h>
#import "SSURLTracker.h"
#import "TTURLTracker.h"
#import "TTAdVideoRelateAdModel.h"



#define kTitleFontSize [SSUserSettingManager detailRelateReadFontSize]



@implementation TTDetailNatantRelatedItemModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"title"             : @"title",
                           @"open_page_url"     : @"schema",
                           @"type_name"         : @"typeName",
                           @"type_color"        : @"typeDayColor",
                           @"type_color_night"  : @"typeNightColor",
                           @"group_id"          : @"groupId",
                           @"item_id"           : @"itemId",
                           @"item_id"           : @"aggrType",
                           @"impr_id"           : @"impressionID"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end

@implementation TTDetailNatantRelateReadViewModel

- (float)titleHeightForArticle:(Article *)article cellWidth:(float)width
{
    return 0;
}

- (void)bgButtonClickedBaseViewController:(nonnull UIViewController *)baseController{}

+ (CGSize)imgSizeForViewWidth:(CGFloat)width
{
    static float w = 0;
    static float h = 0;
    static float cellW = 0;
    if (h < 1 || cellW != width) {
        cellW = width;
        float picOffsetX = 4.f;
        w = (width - kLeftPadding - kRightPadding - picOffsetX * 2)/3;
        h = w * (9.f / 16.f);
        w = ceilf(w);
        h = ceilf(h);
    }
    return CGSizeMake(w, h);
}

@end

@implementation TTDetailNatantRelateReadPureTitleViewModel

- (void)bgButtonClickedBaseViewController:(nonnull UIViewController *)baseController
{
    if (self.didSelectVideoAlbum) {
        self.didSelectVideoAlbum(self.article);
        return;
    }
    
    if ([self.actions count] > 0) {
        NSString * schema = [self.actions objectForKey:@"outer_schema"];
        if ([[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:schema]]) {
            [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:schema]];
            if ([[self.article groupFlags] intValue] & kArticleGroupFlagsHasVideo) {
                wrapperTrackEvent(@"detail", @"enter_youku");
            }
            return;
        }
        
        NSString * openPageURL = [self.actions objectForKey:@"open_page_url"];
        if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openPageURL]]) {
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openPageURL]];
            return;
        }
    }
    NewsGoDetailFromSource fromSource = NewsGoDetailFromSourceRelateReading;
    if (self.isSubVideoAlbum) {
        fromSource = NewsGoDetailFromSourceVideoAlbum;
    }

    if ([TTVideoAlbumHolder holder].albumView) {
        if ([TTVideoAlbumHolder holder].albumView.currentPlayingArticle != self.article) {
            [TTVideoAlbumHolder holder].albumView.currentPlayingArticle = self.article;
            [[TTUIResponderHelper mainWindow] addSubview:[TTVideoAlbumHolder holder].albumView];
        } else {
            return;
        }
    }

    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];

    if (self.isSubVideoAlbum) {
        [condition setValue:@(self.fromArticle.uniqueID) forKey:kNewsDetailViewConditionRelateReadFromAlbumKey];
    }
    else
    {
        [condition setValue:@(self.fromArticle.uniqueID) forKey:kNewsDetailViewConditionRelateReadFromGID];
    }

    [condition setValue:self.logPb forKey:@"logPb"];
    TTDetailContainerViewController *detailController = [[TTDetailContainerViewController alloc] initWithArticle:self.article
                                                                                                          source:fromSource
                                                                                                       condition:condition];
    
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor: baseController];
    [nav pushViewController:detailController animated:self.pushAnimation];
    
    [self sendClickTrack];
}

- (void)sendClickTrack
{
    if (self.isSubVideoAlbum) {
        if (self.videoAlbumID) {
            wrapperTrackEventWithCustomKeys(@"video", @"click_album", [@(self.article.uniqueID) stringValue], nil, @{@"ext_value" : self.videoAlbumID});
        } else if ([self.fromArticle hasVideoSubjectID]) {
            wrapperTrackEventWithCustomKeys(@"video", @"click_album", [@(self.article.uniqueID) stringValue], nil, @{@"video_subject_id" : self.fromArticle.videoSubjectID});
        }
        return;
    }
    NSString *label;
    if ([[self.article groupFlags] intValue] & kArticleGroupFlagsHasVideo) {
        label = @"click_related_video";
    }
    else {
        label = @"click_related";
    }
    
    if (!isEmptyString(self.fromArticle.groupModel.groupID)) {
        [TTTrackerWrapper category:@"umeng"
                      event:@"detail"
                      label:label
                       dict:@{@"value":self.fromArticle.groupModel.groupID}];
    }
    else {
        wrapperTrackEvent(@"detail", label);
    }
    CLS_LOG(@"didReceiveMemoryWarning");

    if ([self.article relatedVideoType] == ArticleRelatedVideoTypeAd) {
        NSString *logExtra = [self.article relatedLogExtra];
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:0];
        if (!isEmptyString(logExtra)) {
            extra[@"log_extra"] = logExtra;
        }
        
        NSString *value = nil;
        if ([self.article relatedAdId]) {
            value = [[self.article relatedAdId] stringValue];
        }
        [extra setValue:@"1" forKey:@"is_ad_event"];
        wrapperTrackEventWithCustomKeys(@"detail_ad_list", @"click", value, nil, extra);
        if (!SSIsEmptyArray(self.article.videoAdExtra.click_track_url_list)) {
//            TTAdBaseModel *adBaseModel = [[TTAdBaseModel alloc] init];
//            adBaseModel.ad_id = self.article.videoAdExtra.ad_id;
//            adBaseModel.log_extra = self.article.videoAdExtra.log_extra;
//            [[SSURLTracker shareURLTracker] trackURLs:self.article.videoAdExtra.click_track_url_list model:adBaseModel];
            TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:self.article.videoAdExtra.ad_id logExtra:self.article.videoAdExtra.log_extra];
            ttTrackURLsModel(self.article.videoAdExtra.click_track_url_list, trackModel);
        }
    }
}

- (float)titleHeightForArticle:(Article *)article cellWidth:(float)width
{
    if (isEmptyString(article.title)) {
        return kTitleFontSize;
    }
    float height = [TTLabelTextHelper heightOfText:article.title fontSize:kTitleFontSize forWidth:width - kLeftPadding - kRightPadding constraintToMaxNumberOfLines:1];
    return height;
}

+ (NSAttributedString *)showTitleForTitle:(NSString *)title tags:(NSArray *)tags
{
    if (!tags.count) {
        return [[NSAttributedString alloc] initWithString:title];
    }
    else {
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        for (NSString * tag in tags) {
            NSRange range = [title rangeOfString:tag];
            if (range.location != NSNotFound) {
                [attrTitle addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kColorText5) range:range];
            }
        }
        return attrTitle;
    }
}

@end

@implementation TTDetailNatantRelateReadRightImgViewModel

+ (CGSize)imgSizeForViewWidth:(CGFloat)width
{
    return [self videoDetailRelateVideoImageSizeWithWidth:width];
}

- (CGFloat)titleLabelFontSize
{
    CGFloat videoDetailFontSize;
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        videoDetailFontSize = 17.f;
    }
    else {
        videoDetailFontSize = 15.f;
    }
    
    return self.useForVideoDetail ? videoDetailFontSize : kTitleFontSize;
}

+ (CGSize)videoDetailRelateVideoImageSizeWithWidth:(CGFloat)width
{
    CGFloat iPhone6ScreenWidth = 375.f;
    CGFloat cellW = MIN(width, iPhone6ScreenWidth);
    float picOffsetX = 4.f;
    CGFloat w = (cellW - kLeftPadding - kRightPadding - picOffsetX * 2)/3;
    CGFloat h = w * (9.f / 16.f);
    w = ceilf(w);
    h = ceilf(h);
    return CGSizeMake(w, h);
}

@end
