//
//  TTLayOutCellBaseModel.m
//  Article
//
//  Created by 王双华 on 16/10/13.
//
//

#import "TTLayOutCellBaseModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTArticleCellHelper.h"
#import "ExploreCellHelper.h"
#import "TTBusinessManager.h"
#import "ExploreArticleCellView.h"
#import "SSUserSettingManager.h"
#import "TTArticleCellConst.h"
#import "TTLayOutCellDataHelper.h"
#import "TTVerifyIconHelper.h"
#import <TTAccountBusiness.h>
//#import "TTThreadCellHelper.h"

@interface TTLayOutCellBaseModel()
@property (nonatomic, weak, readwrite) ExploreOrderedData * orderedData;
@property (nonatomic, assign, readwrite) ExploreOrderedDataListType listType;
@property (nonatomic, assign, readwrite) CGFloat cellWidth;
@end

@implementation TTLayOutCellBaseModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setAllItemsHidden];
        self.needUpdateAllFrame = YES;
    }
    return self;
}

- (BOOL)needUpdateHeightCacheForWidth:(CGFloat)width {
    BOOL widthUpdated = (self.cellWidth != width);
    if (self.needUpdateAllFrame || widthUpdated) {
        return YES;
    }
    return NO;
}

- (void)updateFrameForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = (ExploreOrderedData *)data;
    }
    else{
        return;
    }
    
    BOOL widthUpdated = (self.cellWidth != width);
    self.cellWidth = width;
    self.listType = listType;
    
//    //debug
//    self.needUpdateAllFrame = YES;
//    //end
    
    if (!self.needUpdateAllFrame && !widthUpdated) {
        //如果不需要强制更新frame且frame已经计算过了
        //显示的时间是变化的，所以需要每次更新
        [self calculateNeedUpdateFrame];
        return;
    }
    else{
        [self setAllItemsHidden];
        [self calculateAllFrame];
        [self finishCalculating];
    }

}

- (void)setAllItemsHidden
{
    self.likeLabelHidden = YES;
    self.subscriptLabelHidden = YES;
    self.entityLabelHidden =  YES;
    self.moreImageViewHidden = YES;
    self.moreButtonHidden = YES;
    self.commentButtonHidden = YES;
    self.digButtonHidden = YES;
    self.forwardButtonHidden = YES;
    self.timeLabelHidden = YES;
    
    self.unInterestedButtonHidden = YES;
    self.infoLabelHidden = YES;
    self.entityWordViewHidden = YES;

    self.sourceImageViewHidden = YES;
    self.sourceLabelHidden = YES;
    self.userVerifiedImgHidden = YES;
    self.titleLabelHidden = YES;
    self.picViewHidden = YES;
    self.liveTextLabelHidden = YES;
    self.typeLabelHidden = YES;
    self.abstractLabelHidden = YES;
    self.commentLabelHidden = YES;
    self.bottomLineViewHidden = YES;
    
    self.adBackgroundViewHidden = YES;
    self.adSubtitleLabelHidden = YES;
    self.separatorViewHidden = YES;
    self.actionButtonHidden = YES;
    self.adLocationIconHidden = YES;
    self.adLocationLabelHidden = YES;
    
    self.playButtonHidden = YES;
    self.adButtonHidden = YES;
    
    self.subscribButtonHidden = YES;
    self.backgroundViewHidden = YES;
    self.newsTitleLabelHidden = YES;
    self.userNameLabelHidden = YES;
    self.userVerifiedLabelHidden = YES;
    self.recommendLabelHidden = YES;
    self.topRectHidden = YES;
    self.bottomRectHidden = YES;
    self.actionSepLineHidden = YES;
    self.verticalLineViewHidden = YES;
    self.wenDaButtonHidden = YES;
    
    self.adInnerLoopPicViewHidden = YES;
    self.motionViewHidden = YES;
}

- (void)calculateAllFrame
{
    //implement in subclass
}

- (void)calculateNeedUpdateFrame
{
    //implement in subclass
}

- (void)finishCalculating
{
    self.needUpdateAllFrame = NO;
}

/**
 *  头像 用户名 v 推荐理由  关注按钮  不感兴趣按钮
 *  头像 已关注 点 认证信息
 */
- (CGFloat)heightForHeaderInfoRegionInTwoLinesWithTop:(CGFloat)top needLayoutDislike:(BOOL)layoutDislike
{
    CGFloat infoRegionHeight = kUFS2SourceViewImageSide() + 7.f;
    
    if (self.orderedData.showFollowButton == nil) {
        NSString * authorUid = [TTLayOutCellDataHelper userIDWithOrderedData:self.orderedData];
        if (![authorUid isEqualToString:[TTAccountManager userID]] && [self.orderedData isU11ShowFollowButton]) {
            self.orderedData.showFollowButton = @(![TTLayOutCellDataHelper isFollowedWithOrderedData:self.orderedData]);
        }
        else{
            self.orderedData.showFollowButton = @(NO);
        }
        [self.orderedData save];
    }
    
    CGFloat left = self.originX;
    self.sourceImageViewFrame = CGRectMake(left, top, kUFS2SourceViewImageSide(), kUFS2SourceViewImageSide());
    self.sourceImageURLStr = [TTLayOutCellDataHelper getSourceImageUrlStringForUFCellWithOrderedData:self.orderedData];
    NSString *sourceName = [TTLayOutCellDataHelper getSourceNameStringForUFCellWithOrderedData:self.orderedData];
    if (sourceName.length >= 1) {
        self.sourceNameFirstWord = [sourceName substringToIndex:1];
    }
    else{
        self.sourceNameFirstWord = @"佚";
    }
    self.sourceImageUserInteractionEnabled = YES;
    self.sourceNameFirstWordFontSize = [TTDeviceUIUtils tt_fontSize:16];
    self.sourceImageViewHidden = NO;
    left += kUFS2SourceViewImageSide() + kUFS2PaddingSourceImageToSource();
    
    CGSize sourceSize = [sourceName sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_boldFontOfSize:kUFSourceLabelFontSize()]}];
    CGFloat sourceHeight = 18.f;
    sourceSize = CGSizeMake(ceilf(sourceSize.width), sourceHeight);
    
    NSString *recommendStr = [TTLayOutCellDataHelper getRecommendReasonStringWithOrderedData:self.orderedData];
    CGSize recommendSize = [recommendStr sizeWithAttributes:@{NSFontAttributeName :[UIFont tt_fontOfSize:kUFSourceLabelFontSize()]}];
    recommendSize = CGSizeMake(ceilf(recommendSize.width), sourceHeight);
    
    NSString *verifiedContentStr = [TTLayOutCellDataHelper getUserVerifiedStringWithOrderedData:self.orderedData];
    CGFloat verifiedContentFontSize = [TTDeviceHelper isScreenWidthLarge320] ? 12.f : 10.f;
    CGFloat verifiedContentHeight = [TTDeviceHelper isScreenWidthLarge320] ? 14.f : 12.f;
    CGSize verifiedContentSize = [verifiedContentStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:verifiedContentFontSize]}];
    verifiedContentSize = CGSizeMake(ceilf(verifiedContentSize.width), verifiedContentHeight);
    
    CGFloat sourceMaxWidth = self.containWidth - kUFS2SourceViewImageSide() - kUFS2PaddingSourceImageToSource();
    CGFloat verifiedContentMaxWidth = sourceMaxWidth;
    
    CGFloat sourceLabelY = ceilf(top + (kUFS2SourceViewImageSide() - sourceSize.height - 3.f - verifiedContentSize.height) / 2);
    CGFloat verifiedContentLabelY = sourceLabelY + sourceSize.height + 3.f;
    
    CGFloat unInterestedBtnX = 0;
    if (layoutDislike) {
        CGFloat unInterestedBtnY = 0;
        CGFloat unInterestedBtnWidth = 60;
        CGFloat unInterestedBtnHeight = 44;
        unInterestedBtnX = ceil(self.originX + self.containWidth - kCellUninterestedButtonWidth / 2 - unInterestedBtnWidth / 2);
        unInterestedBtnY = ceilf(sourceLabelY + (sourceSize.height - unInterestedBtnHeight) / 2);
        CGRect unInterestedBtnFrame = CGRectMake(unInterestedBtnX, unInterestedBtnY, unInterestedBtnWidth, unInterestedBtnHeight);
        self.unInterestedButtonFrame = unInterestedBtnFrame;
        if (self.listType == ExploreOrderedDataListTypeFavorite ||
            self.listType == ExploreOrderedDataListTypePushHistory ||
            self.listType == ExploreOrderedDataListTypeReadHistory ||
            (self.orderedData.showDislike && ![self.orderedData.showDislike boolValue])){
            self.unInterestedButtonHidden = YES;
        }
        else{
            self.unInterestedButtonHidden = NO;
        }
        
        if (!self.unInterestedButtonHidden) {
            sourceMaxWidth -= (kCellUninterestedButtonWidth / 2 + unInterestedBtnWidth / 2);
        }
    }
    
    sourceMaxWidth -= 30.f;//右边留30pi
    
    BOOL showFollowButton = NO;
    showFollowButton = [self.orderedData.showFollowButton boolValue];
    
    if (showFollowButton) {
//        if (self.orderedData.redpacketModel) {
//            sourceMaxWidth -= kRedPacketSubSubscribeButtonWidth();
//        }else {
            sourceMaxWidth -= kUFSubscribeButtonWidth();
//        }
    }
    
    self.userVerifiedImgAuthInfo = [TTLayOutCellDataHelper getUserAuthInfoWithOrderedData:self.orderedData];
    BOOL shouldShowVerifyIcon = [TTVerifyIconHelper shouldShowVerifyIcon:self.userVerifiedImgAuthInfo isFeed:[self.orderedData isFeedCategory]];
    self.userDecoration = [TTLayOutCellDataHelper getUserDecorationWithOrderedData:self.orderedData];
    
    CGFloat recommendMaxWidth = 0;
    if (sourceMaxWidth < sourceSize.width) {
        sourceSize.width = ceilf(sourceMaxWidth);
        recommendMaxWidth = 0;
    }else{
        recommendMaxWidth = sourceMaxWidth - sourceSize.width;
    }
    
    self.userNameLabelFrame = CGRectMake(left, sourceLabelY, sourceSize.width, sourceSize.height);
    self.userNameLabelHidden = NO;
    self.userNameLabelStr = sourceName;
    left += sourceSize.width;
    
    if (shouldShowVerifyIcon) {
        self.userVerifiedImgHidden = NO;
    }
    else{
        self.userVerifiedImgHidden = YES;
    }
    
    if (recommendMaxWidth > 0 && recommendSize.width > 0 && recommendMaxWidth > recommendSize.width) {
        left += kUFRecommendLabelLeftPadding();
        CGFloat recommendY = ceilf(sourceLabelY + (sourceSize.height - recommendSize.height) / 2);
        self.recommendLabelFrame = CGRectMake(left, recommendY, recommendSize.width, recommendSize.height);
        self.recommendLabelHidden = NO;
        self.recommendLabelStr = recommendStr;
        self.recommendLabelFontSize = kUFSourceLabelFontSize();
    }
    
    CGFloat subscribeButtonY = ceilf(sourceLabelY + (sourceSize.height - kUFSubscribeButtonHeight()) / 2);
    self.subscribButtonTop = subscribeButtonY;
    if (showFollowButton && layoutDislike && !self.unInterestedButtonHidden) {
        self.subscribButtonRight = unInterestedBtnX - 1;//微调关注按钮位置
        self.subscribButtonHidden = NO;
    }
    else if (showFollowButton) {
        self.subscribButtonRight = self.cellWidth - kUFSubscribeButtonRightPadding();
        self.subscribButtonHidden = NO;
    }
    
    
    if (!self.unInterestedButtonHidden) {
        verifiedContentMaxWidth -= 30.f; //减掉dislike宽度
    }
    if (showFollowButton) {
//        if (self.orderedData.redpacketModel) {
//            verifiedContentMaxWidth -= kRedPacketSubSubscribeButtonWidth();
//        }else {
            verifiedContentMaxWidth -= 29;
//        }
        verifiedContentMaxWidth -= 20;
    }
    
    self.userVerifiedLabelFrame = CGRectMake(self.userNameLabelFrame.origin.x, verifiedContentLabelY, verifiedContentMaxWidth, verifiedContentSize.height);
    self.userVerifiedLabelHidden = NO;
    self.userVerifiedLabelTextColorThemeKey = kColorText3;
    self.userVerifiedLabelStr = verifiedContentStr;
    self.userVerifiedLabelFontSize = verifiedContentFontSize;
    
    return infoRegionHeight;
}

/**
 *  头像 用户名 | 认证信息 v 推荐理由  关注按钮
 */
- (CGFloat)heightForHeaderInfoRegionWithTop:(CGFloat)top
{
    CGFloat infoRegionHeight = 0;
    
    if (self.orderedData.showFollowButton == nil) {
        NSString * authorUid = [TTLayOutCellDataHelper userIDWithOrderedData:self.orderedData];
        if (![authorUid isEqualToString:[TTAccountManager userID]] && [self.orderedData isU11ShowFollowButton]) {
            self.orderedData.showFollowButton = @(![TTLayOutCellDataHelper isFollowedWithOrderedData:self.orderedData]);
        }
        else{
            self.orderedData.showFollowButton = @(NO);
        }
        [self.orderedData save];
    }
    
    infoRegionHeight = kUFSourceViewImageSide() + kUFSourceViewBottomPadding();
    
    CGFloat left = self.originX;
    self.sourceImageViewFrame = CGRectMake(left, top, kUFSourceViewImageSide(), kUFSourceViewImageSide());
    self.sourceImageURLStr = [TTLayOutCellDataHelper getSourceImageUrlStringForUFCellWithOrderedData:self.orderedData];
    NSString *sourceName = [TTLayOutCellDataHelper getSourceNameStringForUFCellWithOrderedData:self.orderedData];
    if (sourceName.length >= 1) {
        self.sourceNameFirstWord = [sourceName substringToIndex:1];
    }
    else{
        self.sourceNameFirstWord = @"佚";
    }
    self.sourceImageUserInteractionEnabled = YES;
    self.sourceNameFirstWordFontSize = [TTDeviceUIUtils tt_fontSize:16];
    self.sourceImageViewHidden = NO;
    
    CGFloat containWidth = self.containWidth;
    CGFloat sourceMaxWidth = containWidth - kUFSourceViewImageSide() - kUFPaddingSourceImageToSource();
    sourceMaxWidth -= 30.f;//右边留30pi
    
    left += kUFSourceViewImageSide() + kUFPaddingSourceImageToSource();
    CGSize sourceSize = [sourceName sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_boldFontOfSize:kUFSourceLabelFontSize()]}];
    sourceSize = CGSizeMake(ceilf(sourceSize.width), ceilf(sourceSize.height));
    
    NSString *verifiedContentStr = [TTLayOutCellDataHelper getUserVerifiedStringWithOrderedData:self.orderedData];
    CGSize verifiedContentSize = [verifiedContentStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kVerifiedContentLabelFontSize()]}];
    verifiedContentSize = CGSizeMake(ceilf(verifiedContentSize.width), ceilf(verifiedContentSize.height));
    
    self.userVerifiedImgAuthInfo = [TTLayOutCellDataHelper getUserAuthInfoWithOrderedData:self.orderedData];
    BOOL shouldShowVerifyIcon = [TTVerifyIconHelper shouldShowVerifyIcon:self.userVerifiedImgAuthInfo isFeed:[self.orderedData isFeedCategory]];
    self.userDecoration = [TTLayOutCellDataHelper getUserDecorationWithOrderedData:self.orderedData];

    BOOL showFollowButton = NO;
    showFollowButton = [self.orderedData.showFollowButton boolValue];
    
    NSString *recommendStr = [TTLayOutCellDataHelper getRecommendReasonStringWithOrderedData:self.orderedData];
    CGSize recommendSize = [recommendStr sizeWithAttributes:@{NSFontAttributeName :[UIFont tt_fontOfSize:kVerifiedContentLabelFontSize()]}];
    recommendSize = CGSizeMake(ceilf(recommendSize.width), ceilf(recommendSize.height));
    
    if (showFollowButton) {
//        if (self.orderedData.redpacketModel) {
//            sourceMaxWidth -= kRedPacketSubSubscribeButtonWidth();
//        }else {
            sourceMaxWidth -= kUFSubscribeButtonWidth();
//        }
    }
   
    CGFloat verifiedContentMaxWidth = sourceMaxWidth;
    if (sourceSize.width > sourceMaxWidth) {
        sourceSize.width = ceilf(sourceMaxWidth);
        verifiedContentMaxWidth = 0;
    }
    else{
        verifiedContentMaxWidth = sourceMaxWidth - sourceSize.width - kUFSeprateLinePadding() * 2 - [TTDeviceHelper ssOnePixel];
    }
    CGFloat sourceLabelY = ceilf(top + (kUFSourceViewImageSide() - sourceSize.height) / 2);
    self.userNameLabelFrame = CGRectMake(left, sourceLabelY, sourceSize.width, sourceSize.height);
    self.userNameLabelHidden = NO;
    self.userNameLabelStr = sourceName;
    left += sourceSize.width;
    
    if (verifiedContentMaxWidth > 0 && verifiedContentSize.width > 0 && verifiedContentMaxWidth > verifiedContentSize.width) {
        left += kUFSeprateLinePadding();
        CGFloat sepatatopViewY = ceilf(top + (kUFSourceViewImageSide() - kUFSeprateLineHeight()) / 2);
        self.separatorViewFrame = CGRectMake(left, sepatatopViewY, [TTDeviceHelper ssOnePixel], kUFSeprateLineHeight());
        self.separatorViewBackgroundColorThemeKey = kColorLine7;
        self.separatorViewHidden = NO;
        
        left += [TTDeviceHelper ssOnePixel] + kUFSeprateLinePadding();
        
        CGFloat infoLabelY = ceilf(top + (kUFSourceViewImageSide() - verifiedContentSize.height) / 2);
        self.userVerifiedLabelFrame = CGRectMake(left, infoLabelY, verifiedContentSize.width, verifiedContentSize.height);
        self.userVerifiedLabelHidden = NO;
        self.userVerifiedLabelTextColorThemeKey = kColorText1;
        self.userVerifiedLabelStr = verifiedContentStr;
        self.userVerifiedLabelFontSize = kVerifiedContentLabelFontSize();
        
        left += verifiedContentSize.width;
    }
    
    if (shouldShowVerifyIcon) {
        self.userVerifiedImgHidden = NO;
    }
    else{
        self.userVerifiedImgHidden = YES;
    }
    
    CGFloat recommendMaxWidth = verifiedContentMaxWidth - verifiedContentSize.width;
    if (recommendMaxWidth > 0 && recommendSize.width > 0 && recommendMaxWidth > recommendSize.width) {
        left += kUFRecommendLabelLeftPadding();
        CGFloat recommendY = ceilf(top + (kUFSourceViewImageSide() - recommendSize.height) / 2);
        self.recommendLabelFrame = CGRectMake(left, recommendY, recommendSize.width, recommendSize.height);
        self.recommendLabelHidden = NO;
        self.recommendLabelStr = recommendStr;
        self.recommendLabelFontSize = kVerifiedContentLabelFontSize();
    }
    if (showFollowButton) {
        CGFloat subscribeButtonY = ceilf(top + (kUFSourceViewImageSide() - kUFSubscribeButtonHeight()) / 2);
        self.subscribButtonTop = subscribeButtonY;
        self.subscribButtonRight = self.cellWidth - kUFSubscribeButtonRightPadding();
        self.subscribButtonHidden = NO;
    }
    
    return infoRegionHeight;
}

/**
 *  头像 用户名 | 认证信息 v 推荐理由  关注按钮 不感兴趣按钮
 */
- (CGFloat)heightForHeaderInfoRegionWithDislikeWithTop:(CGFloat)top
{
    CGFloat infoRegionHeight = 0;
    
    if (self.orderedData.showFollowButton == nil) {
        NSString * authorUid = [TTLayOutCellDataHelper userIDWithOrderedData:self.orderedData];
        if (![authorUid isEqualToString:[TTAccountManager userID]] && [self.orderedData isU11ShowFollowButton]) {
            self.orderedData.showFollowButton = @(![TTLayOutCellDataHelper isFollowedWithOrderedData:self.orderedData]);
        }
        else{
            self.orderedData.showFollowButton = @(NO);
        }
        [self.orderedData save];
    }
    
    infoRegionHeight = kUFSourceViewImageSide() + kUFSourceViewBottomPadding();
    
    CGFloat left = self.originX;
    self.sourceImageViewFrame = CGRectMake(left, top, kUFSourceViewImageSide(), kUFSourceViewImageSide());
    self.sourceImageURLStr = [TTLayOutCellDataHelper getSourceImageUrlStringForUFCellWithOrderedData:self.orderedData];
    NSString *sourceName = [TTLayOutCellDataHelper getSourceNameStringForUFCellWithOrderedData:self.orderedData];
    if (sourceName.length >= 1) {
        self.sourceNameFirstWord = [sourceName substringToIndex:1];
    }
    else{
        self.sourceNameFirstWord = @"佚";
    }
    self.sourceImageUserInteractionEnabled = YES;
    self.sourceNameFirstWordFontSize = [TTDeviceUIUtils tt_fontSize:16];
    self.sourceImageViewHidden = NO;
    
    CGFloat containWidth = self.containWidth;
    CGFloat sourceMaxWidth = containWidth - kUFSourceViewImageSide() - kUFPaddingSourceImageToSource();
    
    CGFloat unInterestedBtnX = 0,unInterestedBtnY = 0;
    CGFloat unInterestedBtnWidth = 60;
    CGFloat unInterestedBtnHeight = 44;
    unInterestedBtnX = ceil(left + self.containWidth - kCellUninterestedButtonWidth / 2 - unInterestedBtnWidth / 2);
    unInterestedBtnY = ceilf(top + (kUFSourceViewImageSide() - unInterestedBtnHeight) / 2);
    CGRect unInterestedBtnFrame = CGRectMake(unInterestedBtnX, unInterestedBtnY, unInterestedBtnWidth, unInterestedBtnHeight);
    self.unInterestedButtonFrame = unInterestedBtnFrame;
//    if (self.listType == ExploreOrderedDataListTypeFavorite ||
//        self.listType == ExploreOrderedDataListTypeReadHistory ||
//        self.listType == ExploreOrderedDataListTypePushHistory ||
//        (self.orderedData.showDislike && ![self.orderedData.showDislike boolValue])){
//        self.unInterestedButtonHidden = YES;
//    }
//    else{
//        self.unInterestedButtonHidden = NO;
//    }
    self.unInterestedButtonHidden = YES;
    
    if (!self.unInterestedButtonHidden) {
        sourceMaxWidth -= (kCellUninterestedButtonWidth / 2 + unInterestedBtnWidth / 2);
    }
    sourceMaxWidth -= 30.f;//右边留30pi
    
    left += kUFSourceViewImageSide() + kUFPaddingSourceImageToSource();
    CGSize sourceSize = [sourceName sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_boldFontOfSize:kUFSourceLabelFontSize()]}];
    sourceSize = CGSizeMake(ceilf(sourceSize.width), ceilf(sourceSize.height));
    
    NSString *verifiedContentStr = [TTLayOutCellDataHelper getUserVerifiedStringWithOrderedData:self.orderedData];
    CGSize verifiedContentSize = [verifiedContentStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kVerifiedContentLabelFontSize()]}];
    verifiedContentSize = CGSizeMake(ceilf(verifiedContentSize.width), ceilf(verifiedContentSize.height));
    
    self.userVerifiedImgAuthInfo = [TTLayOutCellDataHelper getUserAuthInfoWithOrderedData:self.orderedData];
    BOOL shouldShowVerifyIcon = [TTVerifyIconHelper shouldShowVerifyIcon:self.userVerifiedImgAuthInfo isFeed:[self.orderedData isFeedCategory]];
    self.userDecoration = [TTLayOutCellDataHelper getUserDecorationWithOrderedData:self.orderedData];

    BOOL showFollowButton = NO;
    showFollowButton = [self.orderedData.showFollowButton boolValue];
    
    NSString *recommendStr = [TTLayOutCellDataHelper getRecommendReasonStringWithOrderedData:self.orderedData];
    CGSize recommendSize = [recommendStr sizeWithAttributes:@{NSFontAttributeName :[UIFont tt_fontOfSize:kVerifiedContentLabelFontSize()]}];
    recommendSize = CGSizeMake(ceilf(recommendSize.width), ceilf(recommendSize.height));
    
    if (showFollowButton) {
//        if (self.orderedData.redpacketModel) {
//            sourceMaxWidth -= kRedPacketSubSubscribeButtonWidth();
//        }else {
            sourceMaxWidth -= kUFSubscribeButtonWidth();
//        }
    }
   
    CGFloat verifiedContentMaxWidth = sourceMaxWidth;
    if (sourceSize.width > sourceMaxWidth) {
        sourceSize.width = ceilf(sourceMaxWidth);
        verifiedContentMaxWidth = 0;
    }
    else{
        verifiedContentMaxWidth = sourceMaxWidth - sourceSize.width - kUFSeprateLinePadding() * 2 - [TTDeviceHelper ssOnePixel];
    }
    CGFloat sourceLabelY = ceilf(top + (kUFSourceViewImageSide() - sourceSize.height) / 2);
    self.userNameLabelFrame = CGRectMake(left, sourceLabelY, sourceSize.width, sourceSize.height);
    self.userNameLabelHidden = NO;
    self.userNameLabelStr = sourceName;
    left += sourceSize.width;
    
    if (verifiedContentMaxWidth > 0 && verifiedContentSize.width > 0 && verifiedContentMaxWidth > verifiedContentSize.width) {
        left += kUFSeprateLinePadding();
        CGFloat sepatatopViewY = ceilf(top + (kUFSourceViewImageSide() - kUFSeprateLineHeight()) / 2);
        self.separatorViewFrame = CGRectMake(left, sepatatopViewY, [TTDeviceHelper ssOnePixel], kUFSeprateLineHeight());
        self.separatorViewBackgroundColorThemeKey = kColorLine7;
        self.separatorViewHidden = NO;
        
        left += [TTDeviceHelper ssOnePixel] + kUFSeprateLinePadding();
        
        CGFloat infoLabelY = ceilf(top + (kUFSourceViewImageSide() - verifiedContentSize.height) / 2);
        self.userVerifiedLabelFrame = CGRectMake(left, infoLabelY, verifiedContentSize.width, verifiedContentSize.height);
        self.userVerifiedLabelHidden = NO;
        self.userVerifiedLabelTextColorThemeKey = kColorText1;
        self.userVerifiedLabelStr = verifiedContentStr;
        self.userVerifiedLabelFontSize = kVerifiedContentLabelFontSize();
        
        left += verifiedContentSize.width;
    }
    
    if (shouldShowVerifyIcon) {
        self.userVerifiedImgHidden = NO;
    }
    else{
        self.userVerifiedImgHidden = YES;
    }
    
    CGFloat recommendMaxWidth = verifiedContentMaxWidth - verifiedContentSize.width;
    if (recommendMaxWidth > 0 && recommendSize.width > 0 && recommendMaxWidth > recommendSize.width) {
        left += kUFRecommendLabelLeftPadding();
        CGFloat recommendY = ceilf(top + (kUFSourceViewImageSide() - recommendSize.height) / 2);
        self.recommendLabelFrame = CGRectMake(left, recommendY, recommendSize.width, recommendSize.height);
        self.recommendLabelHidden = NO;
        self.recommendLabelStr = recommendStr;
        self.recommendLabelFontSize = kVerifiedContentLabelFontSize();
    }
    if (showFollowButton) {
        CGFloat subscribeButtonY = ceilf(top + (kUFSourceViewImageSide() - kUFSubscribeButtonHeight()) / 2);
        self.subscribButtonTop = subscribeButtonY;
        self.subscribButtonRight = unInterestedBtnX - 1;//微调关注按钮位置
        self.subscribButtonHidden = NO;
    }
    
    return infoRegionHeight;
}

- (TTFollowThemeButton *)generateFollowButton {
    return [self followButton:self.orderedData];
}

- (TTFollowThemeButton *)followButton:(ExploreOrderedData *)orderedData {
    TTUnfollowedType unFollowType = TTUnfollowedType101;
    TTFollowedType followType = TTFollowedType101;
    TTFollowedMutualType mutualType = TTFollowedMutualType101;
    if ([orderedData.followButtonStyle integerValue] == 1) {
        unFollowType = TTUnfollowedType101;
        followType = TTFollowedType101;
        mutualType = TTFollowedMutualType101;
    } else {
        unFollowType = TTUnfollowedType102;
        followType = TTFollowedType102;
        mutualType = TTFollowedMutualType102;
    }
    TTFollowThemeButton* button = [[TTFollowThemeButton alloc] initWithUnfollowedType:unFollowType followedType:followType followedMutualType:mutualType];
    return button;
}

@end

