//
//  TTVideoTabHuoShanCellView.m
//  Article
//
//  Created by xuzichao on 16/6/12.
//
//

#import "TTVideoTabHuoShanCellView.h"
#import "TTImageView.h"
#import "SSThemed.h"
#import "HuoShan.h"
#import "ExploreCellHelper.h"
#import "TTLabelTextHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTImageView+TrafficSave.h"
#import "ExploreItemActionManager.h"
#import "SSActivityView.h"
#import "TTActivityShareManager.h"
#import "ArticleShareManager.h"
#import "TTRoute.h"
#import "ExploreArticleVideoCellCommentView.h"
#import "NewsLogicSetting.h"
#import "TTAlphaThemedButton.h"
#import "TTVideoCommon.h"
#import "ArticleMomentProfileViewController.h"
#import "TTIndicatorView.h"
#import "TTReportManager.h"
#import "TTVideoTabLiveCellView.h"
#import "LiveRoomPlayerViewController.h"
#import <TTImage/TTWebImageManager.h>
#import "TTUISettingHelper.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "NetworkUtilities.h"
#import "TTThemedAlertController.h"
#import "UIImage+TTThemeExtension.h"
#import "TTActivity.h"
#import "TTThemedAlertController.h"
#import "TTTAttributedLabel.h"
#import "TTVideoCellActionBar.h"

#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import "ExploreOrderedData+TTAd.h"

#define kVideoTitleX 15
#define kVideoTitleY ([TTDeviceHelper isScreenWidthLarge320]?15.0:8.0)
#define kSourceLabelFontSize 12
#define kSourceLabelBottomGap 8
#define kDurationLabelFontSize 10
#define kDurationLabelRight 4.0
#define kDurationLabelBottom 4.0
#define kDurationLabelInsetLeft 6.0
#define kDurationLabelHeight 20.0
#define kDurationLabelMinWidth 44.0
#define kActionButtonBarH ([TTDeviceHelper isScreenWidthLarge320]?48.0:40.0)

#define kTopMaskH 80
#define kBottomMaskH 40

#define kAbstractBottomPadding 8
#define kCommentViewBottomPadding 8
#define kBottomViewH 10


@interface TTVideoTabHuoShanCellView()<SSActivityViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic, strong)SSThemedLabel *videoTitleLabel;

//下面的分割线
@property(nonatomic, strong)UIView *sepLineView;
@property(nonatomic, strong)UIView *bottomView;
@property(nonatomic, strong)UIImageView *topMaskView;
@property(nonatomic, strong)TTImageView *logo;

@property (nonatomic, strong) ExploreItemActionManager * itemActionManager;
@property (nonatomic, strong) TTActivityShareManager *activityActionManager;
@property (nonatomic, strong) SSActivityView * phoneShareView;

@end


@implementation TTVideoTabHuoShanCellView

- (void)dealloc
{
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self reloadThemeUI];
    }
    return self;
}

- (UIView *)infoBarView {
    return nil;
}

- (void)layoutInfoBarSubViews {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.actionBar.backgroundColor = self.backgroundColor;
}

- (TTVideoCellActionBar *)actionBar
{
    if (!_actionBar) {
        _actionBar = [[TTVideoCellActionBar alloc] initWithFrame:CGRectMake(0, self.logo.height, self.width, kActionButtonBarH)];
        _actionBar.schemeType = TTVideoCellActionBarLayoutSchemeLive;
        [self addSubview:_actionBar];
        
        [_actionBar.avatarLabelButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_actionBar.moreButton addTarget:self action:@selector(actionButtonClicked:)];
    }
    return _actionBar;
}

#pragma mark -

+ (float)heightForImageWidth:(float)width height:(float)height constraintWidth:(float)cWidth
{
    return [ExploreCellHelper heightForVideoImageWidth:width height:height constraintWidth:cWidth];
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            if (![TTDeviceHelper isPadDevice] && [orderedData nextCellHasTopPadding]) {
                cacheH -= (kBottomViewH + [TTDeviceHelper ssOnePixel]) ;
            }
            return cacheH;
        }
        
        HuoShan *huoshan = orderedData.huoShan;
        
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:huoshan.nhdImageInfo];
        
        // 根据图片实际宽高设置其在cell中的高度
        BOOL isPad = [TTDeviceHelper isPadDevice];
        float picWidth = isPad ? (width - 2 * kCellLeftPadding) : width;
        
        float imageHeight = [TTVideoTabHuoShanCellView heightForImageWidth:model.width height:model.height constraintWidth:picWidth];
        
        CGFloat height = imageHeight;
        

        if ([TTDeviceHelper isPadDevice]) {
            height += kActionButtonBarH + [TTDeviceHelper ssOnePixel];
        }
        else {
            height += kActionButtonBarH + kBottomViewH + [TTDeviceHelper ssOnePixel];
        }
        
        height = ceilf(height);
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        if (![TTDeviceHelper isPadDevice] && [orderedData nextCellHasTopPadding]) {
            height -= (kBottomViewH + [TTDeviceHelper ssOnePixel]);
        }
        
        return ceilf(height);
        
    }
    
    return 0.f;
}

- (void)updatePic
{
    HuoShan *huoshan = self.orderedData.huoShan;
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:huoshan.nhdImageInfo];
    self.logo.backgroundColorThemeKey = kColorBackground2;
    [self.logo setImageWithModelInTrafficSaveMode:model placeholderImage:nil];
}

- (void)layoutPic
{
    // 根据图片实际宽高设置其在cell中的高度
    BOOL isPad = [TTDeviceHelper isPadDevice];
    float left = isPad ? kCellLeftPadding : 0;
    float picWidth = isPad ? (self.width - 2 * kCellLeftPadding) : self.width;
    
    float imageHeight = [TTVideoTabHuoShanCellView heightForImageWidth:self.logo.model.width height:self.logo.model.height constraintWidth:picWidth];
    self.logo.frame = CGRectMake(left, 0, picWidth, imageHeight);
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    if (self.orderedData && self.orderedData.managedObjectContext) {
        
        [self.actionBar refreshWithData:data];
        
        HuoShan *huoshan = self.orderedData.huoShan;
        
        if (huoshan && huoshan.managedObjectContext) {
            if (!_logo) {
                _logo = [[TTImageView alloc] initWithFrame:CGRectZero];
                _logo.imageContentMode = TTImageViewContentModeScaleAspectFill;
                _logo.dayModeCoverHexString = @"00000026";
                [self addSubview:_logo];
            }
            
            [self updatePic];
            
            if (!_topMaskView) {
                UIImage *topMaskImage = [[UIImage imageNamed:@"thr_shadow_video"] resizableImageWithCapInsets:UIEdgeInsetsZero];
                _topMaskView = [[UIImageView alloc] initWithImage:topMaskImage];
                _topMaskView.frame = CGRectMake(0, 0, self.width, kTopMaskH);
                [self.logo addSubview:_topMaskView];
            }
            
            if (!_videoTitleLabel) {
                _videoTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
                _videoTitleLabel.backgroundColor = [UIColor clearColor];
                CGFloat fontSize = [[self class] settedTitleFontSize];
                _videoTitleLabel.font = [UIFont systemFontOfSize:fontSize];
                _videoTitleLabel.textColorThemeKey = kColorText10;
                [self.logo addSubview:_videoTitleLabel];
                _videoTitleLabel.numberOfLines = 2;
            }
            
            _videoTitleLabel.text = huoshan.title;
            
            if (!_videoRightBottomLabel) {
                _videoRightBottomLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
                //                _videoRightBottomLabel.backgroundColor = [UIColor clearColor];
                _videoRightBottomLabel.backgroundColorThemeKey = kColorBackground15;
                CGFloat fontSize = [[self class] sourceLabelFontSize];
                _videoRightBottomLabel.font = [UIFont systemFontOfSize:fontSize];
                //                _videoRightBottomLabel.textColorThemeKey = kColorVideoCellTitle;
                _videoRightBottomLabel.textColorThemeKey = kColorText8;
                _videoRightBottomLabel.layer.masksToBounds = YES;
                _videoRightBottomLabel.textAlignment = NSTextAlignmentCenter;
                
                self.videoRightBottomLabel.text = @"直播";
                self.redDot = [[UIView alloc] init];
                self.redDot.backgroundColor = [UIColor colorWithHexString:@"f85959"];
                [_videoRightBottomLabel addSubview:self.redDot];
    
                [self.logo addSubview:_videoRightBottomLabel];
                
            }
            
            _videoRightBottomLabel.hidden = YES;
            [_videoRightBottomLabel sizeToFit];
            _videoRightBottomLabel.size = CGSizeMake(_videoRightBottomLabel.width + 16.0, _videoRightBottomLabel.height + 5.0);
            _videoRightBottomLabel.layer.cornerRadius = _videoRightBottomLabel.height * 0.5;
            self.videoRightBottomLabel.contentInset = UIEdgeInsetsMake(0,3, 0, 0);
            self.redDot.layer.cornerRadius = 3;
            self.redDot.frame = CGRectMake(6, self.videoRightBottomLabel.height/2 - 3, 6, 6);
            
            if (!_playButton) {
                self.playButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
                self.playButton.imageName = @"live_video_icon";
                [_playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                [self.logo addSubview:_playButton];
            }
            _playButton.hidden = NO;
            _playButton.userInteractionEnabled = ![self.orderedData isPlayInDetailView];
            
            if (!_sepLineView) {
                _sepLineView = [[UIView alloc] initWithFrame:CGRectZero];
                _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
                [self addSubview:_sepLineView];
            }
            
            if (!_bottomView) {
                _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
                _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
                if ([TTDeviceHelper isPadDevice]) {
                    _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
                }
                [self addSubview:_bottomView];
            }
            
            self.videoTitleLabel.hidden = NO;
            self.topMaskView.hidden = NO;
            //cellTag控制显示与否
            if (![self.orderedData isShowHuoShanTitle]) {
                self.videoTitleLabel.hidden = YES;
                self.topMaskView.hidden = YES;
            }
            else if (isEmptyString(huoshan.title)){
                self.topMaskView.hidden = YES;
            }
        }
    }
}

- (void)fontSizeChanged
{
    CGFloat fontSize = [[self class] settedTitleFontSize];
    _videoTitleLabel.font = [UIFont systemFontOfSize:fontSize];
    
    [super fontSizeChanged];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    if ([TTDeviceHelper isPadDevice]) {
        _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
}

static NSDictionary *fontSizes = nil;

+ (float)settedTitleFontSize {
    if (!fontSizes) {
        fontSizes = @{@"iPad" : @[@19, @22, @24, @29],
                      @"iPhone667": @[@16,@18,@20,@23],
                      @"iPhone736" : @[@16, @18, @20, @23],
                      @"iPhone" : @[@14, @16, @18, @21]};
    }
    
    NSString *key = nil;
    if ([TTDeviceHelper isPadDevice]) {
        key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        key = @"iPhone736";
    } else {
        key = @"iPhone";
    }
    NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];;
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return [fonts[index] floatValue];
}

+ (CGFloat)sourceLabelFontSize
{
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 14.0;
    } else {
        return 12.0;
    }
}

- (void)refreshUI
{
    
    [super refreshUI];
    
    [self layoutPic];
    
    _topMaskView.frame = CGRectMake(0, 0, self.logo.width, kTopMaskH);
    CGFloat height = [TTLabelTextHelper heightOfText:_videoTitleLabel.text fontSize:[[self class] settedTitleFontSize] forWidth:self.logo.width - kVideoTitleX * 2 constraintToMaxNumberOfLines:2];
    CGSize size = CGSizeMake(self.logo.width - kVideoTitleX * 2, height);
    
    _videoTitleLabel.frame = CGRectMake(kVideoTitleX, kVideoTitleY, size.width, size.height);
    _videoRightBottomLabel.right = self.logo.width - kDurationLabelRight;
    _videoRightBottomLabel.bottom = self.logo.height - kSourceLabelBottomGap;
    
    _playButton.frame = self.logo.bounds;
    
    _actionBar.frame = CGRectMake(0, self.logo.height, self.width, kActionButtonBarH);
    [_actionBar layoutSubviewsIfNeeded];
    
    CGPoint origin = CGPointMake(kVideoTitleX, _actionBar.bottom);
    [self layoutAbstractAndCommentView:origin];
    self.hideBottomLine = YES;
    [self layoutBottomLine];
    
    CGFloat y = _actionBar.bottom;
    
    _sepLineView.frame = CGRectMake(self.logo.left, y, self.logo.width, [TTDeviceHelper ssOnePixel]);
    if ([TTDeviceHelper isPadDevice]) {
        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, 0);
    }
    else {
        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, kBottomViewH);
    }
    
    if ([self.orderedData nextCellHasTopPadding]) {
        _sepLineView.hidden = YES;
    } else {
        _sepLineView.hidden = NO;
    }
    [self bringSubviewToFront:_actionBar];
}


+ (CGSize)updateCommentSize:(NSString*)commentContent cellWidth:(CGFloat)cellWidth
{
    CGSize result = CGSizeZero;
    if (!isEmptyString(commentContent)) {
        NSMutableAttributedString *attributedString = [TTLabelTextHelper attributedStringWithString:commentContent fontSize:kCellCommentViewFontSize lineHeight:kCellCommentViewLineHeight];
        
        CGFloat commentWidth = cellWidth - kCellLeftPadding - kCellRightPadding;
        
        result = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString withConstraints:CGSizeMake(commentWidth, 999) limitedToNumberOfLines:kCellCommentViewMaxLine];
        
        result.width = commentWidth;
        result.height = ceil(result.height);
    }
    
    return result;
}

- (void)didEndDisplaying
{
    if (self.phoneShareView) {
        [self.phoneShareView dismissWithAnimation:YES];
        self.phoneShareView = nil;
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if (self.phoneShareView) {
        [self.phoneShareView dismissWithAnimation:YES];
        self.phoneShareView = nil;
    }
}

- (CGRect)logoViewFrame
{
    return self.logo.frame;
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:self.logo.bounds fromView:self.logo];
}

//- (void)playButtonClicked
//{
//    NSString *tagStr = [[NSString alloc] init];
//    if (self.cell.tabType == TTCategoryModelTopTypeVideo) {
//        tagStr = @"click_subv_hotsoon";
//    }
//    else {
//        tagStr = @"click_hotsoon";
//    }
//
//    if (TTNetworkConnected()) {
////        if (TTNetworkWifiConnected() || !huoShanShowConnectionAlertCount) {
//        NSMutableDictionary *params = [NSMutableDictionary dictionary];
//        [params setValue:@(self.orderedData.huoShan.uniqueID) forKey:@"id"];
//        [params setValue:tagStr forKey:@"refer"];
//        LiveRoomPlayerViewController *huoShanVC = [[LiveRoomPlayerViewController alloc] initFromPushService:params];
//        UINavigationController *topMost = [TTUIResponderHelper topNavigationControllerFor: self];
//        [topMost pushViewController:huoShanVC animated:YES];
//        //入口需要发送统计
//        wrapperTrackEventWithCustomKeys(@"go_detail", tagStr, self.orderedData.huoShan.liveId.stringValue, nil, @{@"room_id":self.orderedData.huoShan.liveId,@"user_id":[self.orderedData.huoShan.userInfo objectForKey:@"user_id"]});
////        }
////        else {
////            if (huoShanShowConnectionAlertCount) {
////                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"您当前正在使用移动网络，继续播放将消耗流量", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
////                [alert addActionWithTitle:NSLocalizedString(@"停止播放", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
////
////                }];
////                [alert addActionWithTitle:NSLocalizedString(@"继续播放", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
////                    huoShanShowConnectionAlertCount = NO;
////                    LiveRoomViewController *huoShanVC = [[LiveRoomViewController alloc] initFromPushService:@{@"id":@(self.orderedData.huoShan.uniqueID),@"refer":tagStr}];
////                    UINavigationController *topMost = [TTUIResponderHelper topNavigationControllerFor: self];
////                    [topMost pushViewController:huoShanVC animated:YES];
////
////
////                    //入口需要发送统计
////                    wrapperTrackEventWithCustomKeys(@"go_detail", tagStr, self.orderedData.huoShan.liveId.stringValue, nil, @{@"room_id":self.orderedData.huoShan.liveId,@"user_id":[self.orderedData.huoShan.userInfo objectForKey:@"user_id"]});
////                }];
////                [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
////
////            }
////        }
//    }
//    else {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
//    }
//
//
//}

- (void)actionButtonClicked:(id)sender
{
    HuoShan *huoshan = nil;
    
    if (self.originalData && [self.originalData isKindOfClass:[HuoShan class]]) {
        huoshan = (HuoShan *)(self.originalData);
    }
    
    if (huoshan.managedObjectContext == nil) {
        return;
    }
    
    if (sender == _actionBar.avatarLabelButton) {

        NSNumber *userId = huoshan.userInfo[@"user_id"];
        
        NSString *openPGCURL = nil;
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:[NSString stringWithFormat:@"%lld",huoshan.uniqueID] forKey:@"group_id"];
        [dict setValue:[NSString stringWithFormat:@"%@",[huoshan.userInfo objectForKey:@"user_id"]] forKey:@"user_id"];
        
//        if (self.cell.tabType == TTCategoryModelTopTypeNews) {
//            
//            [TTTrackerWrapper category:@"umeng" event:@"hotsoon" label:@"feed_enter_pgc" dict:dict];
//        }
//        else if (self.cell.tabType == TTCategoryModelTopTypeVideo) {
//            
//            [TTTrackerWrapper category:@"umeng" event:@"hotsoon" label:@"video_enter_pgc" dict:dict];
//        }
        
        [TTTrackerWrapper category:@"umeng" event:@"hotsoon" label:@"feed_enter_pgc" dict:dict];
        
        if (userId) {
            openPGCURL = [NSString stringWithFormat:@"sslocal://profile?uid=%@", userId];
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openPGCURL]];
        }
        
        
        return;
    }
    
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    
    if (sender == _actionBar.moreButton) {
        [self shareButtonDidPress];
        [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton];
    }
}

- (void)shareButtonDidPress {
    
    HuoShan *huoshan = self.orderedData.huoShan;
    
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        [[TTWebImageManager shareManger] downloadImageWithURL:[huoshan.shareInfo objectForKey:@"pic_url"] options:0 progress:nil completed:nil];
    }
    
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setHuoshanCondition:huoshan];
    
    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    
    [_phoneShareView showActivityItems:@[activityItems]];
    
    
    if (self.orderedData.huoShan) {
        wrapperTrackEvent(@"list_content", @"share_channel");
    }
}

#pragma mark - TTActivityShareManagerDelegate

+ (NSString *)labelNameForShareActivityType:(TTActivityType)activityType
{
    return [TTVideoCommon videoListlabelNameForShareActivityType:activityType withCategoryId:@"hotsoon"];
}



#pragma mark -- SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == _phoneShareView) {
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", [self.orderedData.huoShan.liveId longLongValue]];
        [_activityActionManager performActivityActionByType:itemType
                                           inViewController:[TTUIResponderHelper topViewControllerFor: self]
                                           sourceObjectType:TTShareSourceObjectTypeHTSLive
                                                   uniqueId:uniqueID adID:nil
                                                   platform:TTSharePlatformTypeOfHTSLivePlugin
                                                 groupFlags:self.orderedData.huoShan.liveId];
            [self sendVideoShareTrackWithItemType:itemType];
            self.phoneShareView= nil;
    }
}

#pragma mark -- Track
- (NSDictionary *)extraValueDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.orderedData.huoShan.liveId) {
        [dic setObject:self.orderedData.huoShan.liveId forKey:@"item_id"];
    }
    if (self.orderedData.categoryID) {
        [dic setObject:self.orderedData.categoryID forKey:@"category_id"];
    }
    if ([self getRefer]) {
        [dic setObject:[NSNumber numberWithUnsignedInteger:[self getRefer]] forKey:@"location"];
    }
    [dic setObject:@1 forKey:@"gtype"];
    return dic;
}


- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType
{
    NSString *uniqueID = [NSString stringWithFormat:@"%lld", [self.orderedData.huoShan.liveId longLongValue]];
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeVideoList];
    NSString *label = [[self class] labelNameForShareActivityType:itemType];
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionary];
    if (!isEmptyString(self.orderedData.ad_id)) {
        extValueDic[@"ext_value"] = self.orderedData.ad_id;
    }
    wrapperTrackEventWithCustomKeys(tag, label, uniqueID, @"hotsoon", extValueDic);
    //[super sendVideoShareTrackWithItemType:itemType];
}

@end
