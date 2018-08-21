//
//  TTArticleTitleLargePicHuoShanCellView.m
//  Article
//
//  Created by xuzichao on 16/6/13.
//
//

#import "TTArticleTitleLargePicHuoShanCellView.h"
#import "TTImageView.h"
#import "TTRoute.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreArticleTitleLargePicCellView.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTImageView+TrafficSave.h"
#import "NetworkUtilities.h"
#import "HuoShan.h"
#import "LiveRoomPlayerViewController.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTActionPopView.h"
#import "NSString-Extension.h"
#import "TTArticleCellHelper.h"
#import "ExploreMixListDefine.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"


#define kDurationRightPadding 5
#define kDurationBottomPadding 3

@interface TTArticleTitleLargePicHuoShanCellView()<TTDislikePopViewDelegate>
@property(nonatomic, strong)SSThemedImageView * videoIconView;
@property(nonatomic, strong)SSThemedLabel * videoDurationLabel;
@end

@implementation TTArticleTitleLargePicHuoShanCellView
{
    LargePicViewType type;
    SSThemedView *bottomSeperatorView;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    if (self.orderedData && self.orderedData.managedObjectContext) {
        HuoShan *huoshan = self.orderedData.huoShan;
        if (huoshan && huoshan.managedObjectContext) {
            [self updateTitleLabel];
            [self updatePic];
            [self updateTypeLabel];
        }
        else {
            self.typeLabel.height = 0;
            self.titleLabel.height = 0;
        }
    }
    
    if (!_videoIconView) {
        self.videoIconView = [[SSThemedImageView alloc] initWithImage:[UIImage themedImageNamed:@"palyicon_video_textpage.png"]];
        _videoIconView.imageName = @"palyicon_video_textpage.png";
        [self.timeInfoBgView addSubview:_videoIconView];
    }
    if (!_videoDurationLabel) {
        self.videoDurationLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _videoDurationLabel.backgroundColor = [UIColor clearColor];
        _videoDurationLabel.textColorThemeKey = kCellPicLabelTextColor;
        _videoDurationLabel.font = [UIFont systemFontOfSize:kCellPicLabelFontSize];
        [self.timeInfoBgView addSubview:_videoDurationLabel];
    }
    [_videoDurationLabel sizeToFit];
    _videoDurationLabel.frame = CGRectIntegral(_videoDurationLabel.frame);
    
    if (!_playButton) {
        self.playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.playButton.imageName = @"live_video_icon";
        [_playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.pic addSubview:_playButton];
    }
    _playButton.userInteractionEnabled = YES;
    
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    bottomSeperatorView.backgroundColorThemeKey = kCellBottomLineBackgroundColor;
    bottomSeperatorView.layer.borderColor = [SSGetThemedColorWithKey(kCellBottomLineColor) CGColor];
    bottomSeperatorView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    [self updatePic];
}

- (void)refreshUI
{
    CGFloat x = kCellLeftPadding;
    CGFloat y = kCellTopPadding;
    CGFloat containWidth = self.width - kCellLeftPadding - kCellRightPadding;
    
    if (self.orderedData.huoShan.title) {
        [self.titleLabel sizeToFit:containWidth];
        self.titleLabel.origin = CGPointMake(x, y);
        y += self.titleLabel.height;
    }
    
    [self layoutPic];
    
    y = self.pic.bottom + kCellInfoBarTopPadding;
    
    self.infoBarView.frame = CGRectMake(kCellLeftPadding, ceilf(y), self.width - kCellLeftPadding - kCellRightPadding, kCellInfoBarHeight);
    
    [self layoutInfoBarSubViews];
    
    if (type == LargePicViewTypeNormal) {
        [self layoutBottomLine];
    }
    
    self.videoIconView.hidden = YES;
    self.videoDurationLabel.hidden = YES;
    _timeInfoBgView.hidden = YES;
    _playButton.frame = self.pic.bounds;
}

- (void)playButtonClicked
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(self.orderedData.huoShan.uniqueID) forKey:@"id"];
    [params setValue:@"click_headline" forKey:@"refer"];
    LiveRoomPlayerViewController *huoShanVC = [[LiveRoomPlayerViewController alloc] initFromPushService:params];
    UINavigationController *topMost = [TTUIResponderHelper topNavigationControllerFor: self];
    [topMost pushViewController:huoShanVC animated:YES];
    //入口需要发送统计
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        wrapperTrackEventWithCustomKeys(@"go_detail", @"click_headline", self.orderedData.huoShan.liveId.stringValue, nil, @{@"room_id":self.orderedData.huoShan.liveId,@"user_id":[self.orderedData.huoShan.userInfo objectForKey:@"user_id"]});
    }
    
    //log3.0 doubleSending
    NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:4];
    [logv3Dic setValue:self.orderedData.huoShan.liveId.stringValue forKey:@"room_id"];
    [logv3Dic setValue:[self.orderedData.huoShan.userInfo objectForKey:@"user_id"] forKey:@"user_id"];
    [logv3Dic setValue:@"click_headline" forKey:@"enter_from"];
    [logv3Dic setValue:self.orderedData.logPb forKey:@"log_pb"];
    [TTTrackerWrapper eventV3:@"go_detail" params:logv3Dic isDoubleSending:YES];
}

- (void)didEndDisplaying
{

}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{

}


- (void)layoutInfoLabel
{
    self.sourceLabel.hidden = NO;
    HuoShan *huoShan = self.orderedData.huoShan;
    
    NSString *paddingStr = [TTDeviceHelper isPadDevice] ? @"   " : @"  ";
    
    NSMutableString *sourceStr = [NSMutableString stringWithCapacity:30];
    NSMutableString *infoStr = [NSMutableString stringWithCapacity:30];
    
    int count = [huoShan.viewCount intValue];
    count = MAX(0, count);
    
    if (count > 0  && [self.orderedData isShowHuoShanViewCount]) {
        NSString *liveStr = [NSString stringWithFormat:@"%@人正在看", [TTBusinessManager formatCommentCount:count]];
        [infoStr appendString:liveStr];
        [infoStr appendString:paddingStr];
    }
    
    NSString *source = [huoShan.mediaInfo objectForKey:@"name"];
    if (isEmptyString(source)) {
        source = [huoShan.userInfo objectForKey:@"screen_name"];
    }
    
    if (!isEmptyString(source)  && [self.orderedData isShowHuoShanUserInfo]) {
        [sourceStr appendString:source];
        [sourceStr appendString:paddingStr];
    }
    
    self.infoLabel.text = [infoStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.infoLabel sizeToFit];
    
    CGFloat logoWidth = 0.0;
    if (self.logoIcon.width > 0) {
        logoWidth = self.logoIcon.width + kCellTypelabelRightPaddingToInfoLabel;
    }
    else if (!isEmptyString(self.typeLabel.text)) {
        logoWidth = self.typeLabel.width + kCellTypelabelRightPaddingToInfoLabel;
    }
    
    CGFloat sourceMaxWidth = self.infoBarView.width - kCellUninterestedButtonWidth - 4;
    if (logoWidth > 0.0) {
        sourceMaxWidth -= (logoWidth + 4);
    }
    sourceMaxWidth -= self.infoLabel.width;
    
    self.sourceLabel.text = sourceStr;
    [self.sourceLabel sizeToFit];
    
    CGFloat x;
    
    if (self.typeLabel.width > 0) {
        x = self.typeLabel.right + kCellTypelabelRightPaddingToInfoLabel;
    }
    else if (self.logoIcon.width > 0) {
        x = self.logoIcon.right + kCellTypelabelRightPaddingToInfoLabel;
    }
    else {
        x = 0;
    }
    
    CGRect rect;
    if (self.sourceLabel.width <= sourceMaxWidth) {
        rect = CGRectMake(x, floor((self.infoBarView.height - kCellTypeLabelHeight) / 2), ceil(self.sourceLabel.width), kCellTypeLabelHeight);
    } else {
        rect = CGRectMake(x, floor((self.infoBarView.height - kCellTypeLabelHeight) / 2), MAX(0,ceil(sourceMaxWidth)), kCellTypeLabelHeight);
    }
    self.sourceLabel.frame = rect;
    
    if (sourceMaxWidth < 0) {
        self.infoLabel.frame = CGRectMake(self.sourceLabel.right, floor((self.infoBarView.height - kCellTypeLabelHeight) / 2), ceil(self.infoLabel.width + sourceMaxWidth), kCellTypeLabelHeight);
    } else {
        self.infoLabel.frame = CGRectMake(self.sourceLabel.right, floor((self.infoBarView.height - kCellTypeLabelHeight) / 2), ceil(self.infoLabel.width), kCellTypeLabelHeight);
    }
}

- (void)updateTypeLabel
{
    self.logoIcon.size = CGSizeZero;
    [self.logoIcon setImageWithURLString:nil];
    
    // 标签
    self.typeLabel.text = nil;
    if (!isEmptyString(self.orderedData.huoShan.label)) {
        self.typeLabel.text = self.orderedData.huoShan.label;
    } else {
        self.typeLabel.text = self.orderedData.displayLabel;
    }
    [ExploreCellHelper colorTypeLabel:self.typeLabel orderedData:self.orderedData];
}

- (void)updateTitleLabel
{
    if (self.titleLabel)
    {
        [self updateContentColor];
        
        if (!isEmptyString(self.orderedData.huoShan.title) && [self.orderedData isShowHuoShanTitle]) {
            BOOL isBoldFont = [TTDeviceHelper isPadDevice];
            self.titleLabel.font = isBoldFont ? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] : [UIFont tt_fontOfSize:kCellTitleLabelFontSize];
            self.titleLabel.lineHeight = kCellTitleLineHeight;
            self.titleLabel.text = self.orderedData.huoShan.title;
        } else {
            self.titleLabel.text = nil;
            self.titleLabel.height = 0;
        }
    }
}

- (TTImageView *)pic
{
    if (!_pic) {
        _pic = [[TTImageView alloc] initWithFrame:CGRectZero];
        _pic.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _pic.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _pic.borderColorThemeKey = kCellGroupPicBorderColor;
        [self addSubview:_pic];
    }
    return _pic;
}

- (void)updatePic
{
    HuoShan *huoShan = self.orderedData.huoShan;
    type = LargePicViewTypeNormal;
    NSDictionary *imageInfo = [NSDictionary dictionary];
    imageInfo = huoShan.nhdImageInfo;
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
    self.pic.backgroundColor = [UIColor tt_themedColorForKey:kCellGroupPicBackgroundColor];
    
    [self.pic setImageWithModelInTrafficSaveMode:model placeholderImage:nil];
    
    if (type == LargePicViewTypeNormal) {
        _pic.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    } else {
        _pic.layer.borderWidth = 0;
    }
}

- (void)layoutPic
{
    // 根据图片实际宽高设置其在cell中的高度
    BOOL isPad = [TTDeviceHelper isPadDevice];
    CGFloat galleryWidth = isPad ? [ExploreCellHelper largeImageWidth:self.width] : self.width;
    CGFloat galleryLeftPadding = isPad  ? kCellLeftPadding : 0;
    
    
    float imageHeight = (type == LargePicViewTypeGallary || !self.pic.model) ? galleryWidth * 9.f / 16.f : ([ExploreCellHelper heightForImageWidth:self.pic.model.width height:self.pic.model.height constraintWidth:[ExploreCellHelper largeImageWidth:self.width]]);
    CGFloat leftPadding = type == LargePicViewTypeGallary ? galleryLeftPadding : kCellLeftPadding;
    CGFloat picWidth = type == LargePicViewTypeGallary ? galleryWidth : [ExploreCellHelper largeImageWidth:self.width];
    
    self.pic.frame = CGRectMake(leftPadding, self.titleLabel.bottom + kCellGroupPicTopPadding, picWidth, imageHeight);
}


- (void)layoutBottomSeperatorView
{
    if (![TTDeviceHelper isPadDevice]) {
        if (!bottomSeperatorView) {
            bottomSeperatorView = [SSThemedView new];
            bottomSeperatorView.backgroundColorThemeKey = kCellBottomLineBackgroundColor;
            bottomSeperatorView.layer.borderColor = [SSGetThemedColorWithKey(kCellBottomLineColor) CGColor];
            bottomSeperatorView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
            [self addSubview:bottomSeperatorView];
        }
        bottomSeperatorView.hidden = NO;
        bottomSeperatorView.frame = CGRectMake(0, self.height - kCellBottomLineHeight, self.width, kCellBottomLineHeight);
    }
}

- (NSDictionary *)extraValueDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@(self.orderedData.huoShan.uniqueID) forKey:@"group_id"];
    [dic setObject:self.orderedData.categoryID forKey:@"category_id"];
    if ([self getRefer]) {
        [dic setObject:[NSNumber numberWithUnsignedInteger:[self getRefer]] forKey:@"location"];
    }
    [dic setObject:@1 forKey:@"gtype"];
    return dic;
}

- (void)unInterestButtonClicked:(id)sender
{
    wrapperTrackEventWithCustomKeys(@"dislike", @"menu_with_reason", [TTActionPopView.shareGroupId stringValue], nil, [self extraValueDic]);
    
    //不感兴趣
    HuoShan *huoShan = self.orderedData.huoShan;
    if (self.orderedData.huoShan.actionList.count <= 0 ) {
        return;
    }
    
    NSDictionary *dislikeAction = [[NSDictionary alloc] init];
    NSMutableArray *actionItem = [[NSMutableArray alloc] init];
    for (NSDictionary *action in self.orderedData.huoShan.actionList) {
        NSInteger actiontType = [action[@"action"] integerValue];
        if (actiontType == 1) {
            dislikeAction = action;
        }
    }
    
    if (dislikeAction.allKeys.count <= 0) {
        return;
    }
    
    NSString *descrip = @"不感兴趣";
    NSString *iconName = @"ugc_icon_not_interested";
    NSString *desc = [dislikeAction objectForKey:@"desc"];
    if (![desc isEqualToString:@""]) {
        descrip = [dislikeAction[@"desc"] stringValue];
    }
    NSMutableArray *dislikeWords = [[NSMutableArray alloc] init];
    NSNumber *groupId = huoShan.uniqueID == 0 ? @(self.orderedData.article.uniqueID) : @(huoShan.uniqueID);
    if (groupId  == nil) {
        return;
    }
    
    //不感兴趣的原因word
    for (NSDictionary *words in huoShan.filterWords) {
        TTFeedDislikeWord *word = [[TTFeedDislikeWord alloc] initWithDict:words];
        [dislikeWords addObject:word];
    }
    
    __weak typeof(self) wself = self;
    TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:descrip iconName:iconName hasSub:NO action:^{
        [[TTActionPopView shareView] showDislikeView:wself.orderedData dislikeWords:dislikeWords groupID:groupId];
        [wself dislikeButtonClicked:[[NSArray<NSString *> alloc] init] onlyOne:NO];
    }];
    [actionItem addObject:item];
    
    TTActionPopView *popupView = [[TTActionPopView alloc] initWithActionItems:actionItem width:self.width];
    popupView.delegate = self;
    
    CGPoint p = self.unInterestedButton.center;
    [popupView showAtPoint:p fromView:self.unInterestedButton animation:NO completeBock:^{
        [[TTActionPopView shareView] showDislikeView:wself.orderedData dislikeWords:dislikeWords groupID:groupId transformAnimation:YES];
    }];

    
}


+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        HuoShan *huoShan = orderedData.huoShan;
        LargePicViewType type = LargePicViewTypeNormal;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            if (![TTDeviceHelper isPadDevice] && type == LargePicViewTypeGallary &&
                ([orderedData nextCellHasTopPadding])) {
                cacheH -= kCellBottomViewHeight;
            }
            return cacheH;
        }
        
        CGFloat containWidth = width - kCellLeftPadding - kCellRightPadding;
        
        CGFloat titleHeight = 0;
        // 计算基本高度(titleLabel、infoBar)
        if (huoShan.title) {
            titleHeight = [huoShan.title tt_sizeWithMaxWidth:containWidth font:[UIFont tt_fontOfSize:kCellTitleLabelFontSize] lineHeight:kCellTitleLineHeight numberOfLines:kCellTitleLabelMaxLine].height;
        }
        CGFloat sourceLabelHeight = kCellInfoBarHeight;
        
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:huoShan.nhdImageInfo];
        // 根据图片实际宽高设置其在cell中的高度
        BOOL isPad = [TTDeviceHelper isPadDevice];
        
        ///...
        BOOL isNotGallaryChannel = (orderedData.gallaryStyle == 1);
        CGFloat galleryWidth = (isPad || isNotGallaryChannel) ? [ExploreCellHelper largeImageWidth:width] : width;
        
        float imageHeight = type == LargePicViewTypeGallary ? galleryWidth * 9.f/16.f : [ExploreCellHelper heightForImageWidth:model.width height:model.height constraintWidth:[ExploreCellHelper largeImageWidth:width]];
        
        CGFloat height;
        
        //标题、大图、infoBar
        if (type == LargePicViewTypeGallary && !isNotGallaryChannel && ![TTDeviceHelper isPadDevice]) {
            height = kCellBottomPaddingWithPic + kCellBottomLineHeight + imageHeight + kCellGroupPicTopPadding + titleHeight + kCellTitleBottomPaddingToInfo + sourceLabelHeight;
        } else {
            height = kCellTopPadding + kCellBottomPaddingWithPic + titleHeight + kCellGroupPicTopPadding + imageHeight + kCellInfoBarTopPadding + sourceLabelHeight;
        }
        
        height = ceilf(height);
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        if (![TTDeviceHelper isPadDevice] && type == LargePicViewTypeGallary && ([orderedData nextCellHasTopPadding])) {
            height -= kCellBottomLineHeight;
        }
        
        return height;
    }
    
    return 0.f;
}

#pragma mark - TTDislikePopViewDelegate

- (void)dislikeButtonClicked:(NSArray<NSString *> *)selectedWords onlyOne:(BOOL)onlyOne {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (selectedWords.count > 0) {
        [userInfo setValue:selectedWords forKey:kExploreMixListNotInterestWordsKey];
        if (onlyOne) {
            wrapperTrackEventWithCustomKeys(@"new_list", @"confirm_dislike_only_reason", [TTActionPopView.shareGroupId stringValue], nil, [self extraValueDic]);
        } else {
            wrapperTrackEventWithCustomKeys(@"new_list", @"confirm_dislike_with_reason", [TTActionPopView.shareGroupId stringValue], nil, [self extraValueDic]);
        }
    } else {
        wrapperTrackEventWithCustomKeys(@"new_list", @"confirm_dislike_no_reason", [TTActionPopView.shareGroupId stringValue], nil, [self extraValueDic]);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

@end

