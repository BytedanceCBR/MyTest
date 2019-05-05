            //
//  TTADBaseCell.m
//  Article
//
//  Created by 杨心雨 on 16/8/24.
//
//

#import "TTADBaseCell.h"

#import "Article+TTADComputedProperties.h"
#import "ArticleShareManager.h"
#import "ExploreCellViewBase.h"
#import "ExploreMixListDefine.h"
#import "SSADEventTracker.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSWebViewController.h"
#import "TTActionSheetController.h"
#import "TTAdAction.h"
#import "TTAdAppointAlertView.h"
#import "TTAdFeedModel.h"
#import "TTAdImpressionTracker.h"
#import "TTAdManagerProtocol.h"
#import "TTAdMonitorManager.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "TTDeviceHelper.h"
#import "TTFeedDislikeView.h"
#import "TTIndicatorView.h"
#import "TTLabelTextHelper.h"
#import "TTLayOutCellDataHelper.h"
#import "TTNavigationController.h"
#import "TTPlatformSwitcher.h"
#import "TTReportManager.h"
#import "TTRoute.h"
#import "TTStringHelper.h"
#import "TTUISettingHelper.h"
#import <TTServiceKit/TTServiceCenter.h>
#import <TTTracker/TTTrackerProxy.h>

// MARK: - TTADBaseCell
/** 广告类型基类 */

@interface TTADBaseCell ()
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@end

@implementation TTADBaseCell
/** 功能区控件 */
- (TTArticleFunctionView *)functionView {
    if (_functionView == nil) {
        _functionView = [[TTArticleFunctionView alloc] init];
        _functionView.delegate = self;
        [self.cellView addSubview:_functionView];
    }
    return _functionView;
}
    
/** 更多控件 */
- (SSThemedButton *)moreView {
    if (_moreView == nil) {
        _moreView = [[SSThemedButton alloc] init];
        _moreView.imageName = @"function_icon";
        CGFloat side = kMoreViewSide() + kMoreViewExpand() * 2;
        _moreView.frame = CGRectMake(0, 0, side, side);
        [_moreView addTarget:self action:@selector(moreViewClick) forControlEvents:UIControlEventTouchUpInside];
        [self.cellView addSubview:_moreView];
    }
    return _moreView;
}

/** 标题控件 */
- (TTLabel *)titleView {
    if (_titleView == nil) {
        _titleView = [[TTLabel alloc] init];
        _titleView.textColor = [TTUISettingHelper cellViewTitleColor];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.numberOfLines = kTitleViewLineNumber();
        _titleView.lineHeight = kTitleViewLineHeight();
        _titleView.font = [UIFont tt_fontOfSize:kTitleViewFontSize()];
        _titleView.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.cellView addSubview:_titleView];
    }
    return _titleView;
}

/// 图片(视频)控件
- (TTArticlePicView *)picView {
    if (_picView == nil) {
        _picView = [[TTArticlePicView alloc] initWithStyle:TTArticlePicViewStyleNone];
        [self.cellView addSubview:_picView];
    }
    return _picView;
}

/** 相关信息 */
- (SSThemedLabel *)sourceName {
    if (_sourceName == nil) {
        _sourceName = [[SSThemedLabel alloc] init];
        _sourceName.textColorThemeKey = kColorText9;
        _sourceName.font = [UIFont tt_fontOfSize:15];
        [self.cellView addSubview:_sourceName];
    }
    return _sourceName;
}

/** 下载按钮 */
- (ExploreActionButton *)actionButton {
    if (_actionButton == nil) {
        _actionButton = [[ExploreActionButton alloc] init];
        [_actionButton addTarget:self action:@selector(downloadButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
        _actionButton.titleLabel.font = [UIFont tt_fontOfSize:12];
        _actionButton.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText6];
        _actionButton.frame = CGRectMake(0, 0, 72, 30);
        [self.cellView addSubview:_actionButton];
    }
    return _actionButton;
}

/** 信息栏控件 */
- (TTArticleInfoView *)infoView {
    if (_infoView == nil) {
        _infoView = [[TTArticleInfoView alloc] init];
        _infoView.delegate = self;
        [self.cellView addSubview:_infoView];
    }
    return _infoView;
}

/** 广告信息栏控件 */
- (TTADInfoView *)adInfoView {
    if (_adInfoView == nil) {
        _adInfoView = [[TTADInfoView alloc] init];
        
        _adInfoView.locationLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *adlocationLabelGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adLocationLabelClick:)];
        [_adInfoView.locationLabel addGestureRecognizer:adlocationLabelGestureRecognizer];
        
        _adInfoView.locationIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *adLocationIconTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adLocationLabelClick:)];
        [_adInfoView.locationIcon addGestureRecognizer:adLocationIconTapGestureRecognizer];
        
        [self.cellView addSubview:_adInfoView];
    }
    return _adInfoView;
}

/** 创意广告不感兴趣按钮*/
- (TTAlphaThemedButton *)accessoryButton {
    if (_accessoryButton == nil) {
        _accessoryButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 30, 25)];
        _accessoryButton.imageName = @"add_textpage";
        [_accessoryButton addTarget:self action:@selector(accessoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellView addSubview:_accessoryButton];
    }
    return _accessoryButton;
}

/** 创意广告Action控件 */
- (TTADActionView *)adActionView {
    if (_adActionView == nil) {
        _adActionView = [[TTADActionView alloc] init];
        
        _adActionView.sourceLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *adSourceTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adLocationLabelClick:)];
        [_adActionView.sourceLabel addGestureRecognizer:adSourceTapGestureRecognizer];
        
        [self.cellView addSubview:_adActionView];
    }
    return _adActionView;
}

/// 底部分割线
- (SSThemedView *)bottomLineView {
    if (_bottomLineView == nil) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kBottomLineViewBackgroundColor();
        [self.cellView addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

/** 视频频道10px底部分割线 */
- (SSThemedView *)bottomSepView {
    if (!_bottomSepView) {
        _bottomSepView = [[SSThemedView alloc] init];
        _bottomSepView.backgroundColorThemeKey = kColorBackground3;
        if ([TTDeviceHelper isPadDevice]) {
            _bottomSepView.backgroundColorThemeKey = kColorBackground4;
        }
        [self.cellView addSubview:_bottomSepView];
    }
    return _bottomSepView;
}

/** 视频频道大图广告标题 */
- (SSThemedLabel *)videoTitleLabel
{
    if (!_videoTitleLabel) {
        _videoTitleLabel = [[SSThemedLabel alloc] init];
        _videoTitleLabel.textColorThemeKey = kColorText10;
        _videoTitleLabel.backgroundColor = [UIColor clearColor];
        _videoTitleLabel.numberOfLines = 2;
        _videoTitleLabel.font = [UIFont tt_fontOfSize:kVideoCellTitleFontSize()];
        _videoTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.picView addSubview:_videoTitleLabel];
    }
    return _videoTitleLabel;
}

- (UIImageView *)topMaskView
{
    if (!_topMaskView) {
        UIImage *topMaskImage = [[UIImage imageNamed:@"thr_shadow_video"] resizableImageWithCapInsets:UIEdgeInsetsZero];
        _topMaskView = [[UIImageView alloc] initWithImage:topMaskImage];
        [self.picView addSubview:_topMaskView];
    }
    return _topMaskView;
}

/** 视频频道大图广告下工具栏 */
- (TTVideoCellActionBar *)actionBar
{
    if (!_actionBar) {
        _actionBar = [[TTVideoCellActionBar alloc] init];
        [_actionBar.adActionButton addTarget:self action:@selector(actionBarAdActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _actionBar.shareController.cellView = self.cellView;
        [self.cellView addSubview:_actionBar];
    }
    return _actionBar;
}

/** 视图是否高亮 */
- (void)setIsViewHighlighted:(BOOL)isViewHighlighted {
    _isViewHighlighted = isViewHighlighted;
    if (_isViewHighlighted) {
        self.backgroundColor = [TTUISettingHelper cellViewHighlightedBackgroundColor];
    } else {
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    }
    _actionBar.backgroundColor = self.backgroundColor;
    _actionBar.adActionButton.backgroundColor = self.backgroundColor;
    self.contentView.backgroundColor = self.backgroundColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.isViewHighlighted = highlighted;
}

- (ExploreItemActionManager *)itemActionManager {
    if (_itemActionManager == nil) {
        _itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    return _itemActionManager;
}

- (TTActivityShareManager *)activityActionManager {
    if (_activityActionManager == nil) {
        _activityActionManager = [[TTActivityShareManager alloc] init];
    }
    return _activityActionManager;
}

- (void)setOrderedData:(ExploreOrderedData *)orderedData {
    _extraDic = nil;
    _orderedData = orderedData;
    self.originalData = [_orderedData originalData];
}

- (void)setReadPersistAD:(BOOL)readPersistAD {
    _readPersistAD = readPersistAD;
    self.titleView.highlighted = _readPersistAD;
    [self.functionView updateReadState:_readPersistAD];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        self.contentView.backgroundColor = self.backgroundColor;
    }
    return self;
}

- (void)dealloc {
    self.orderedData = nil;
    self.originalData = nil;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    if (self.isViewHighlighted) {
        self.backgroundColor = [TTUISettingHelper cellViewHighlightedBackgroundColor];
    } else {
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    }
    self.contentView.backgroundColor = self.backgroundColor;
    self.titleView.textColor = [TTUISettingHelper cellViewTitleColor];
}

- (id)cellData {
    return self.orderedData;
}

- (NSDictionary *)extraDic {
    if (_extraDic == nil) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if ([self.orderedData originalData]) {
            if (self.originalData.uniqueID > 0) {
                dic[@"item_id"] = @(self.originalData.uniqueID);
            }
            if ([self.orderedData categoryID]) {
                dic[@"category_id"] = [self.orderedData categoryID];
            }
            if ([self.orderedData concernID]) {
                dic[@"concern_id"] = [self.orderedData concernID];
            }
            dic[@"refer"] = [NSNumber numberWithInteger:[self refer]];
            dic[@"gtype"] = @1;
        }
        _extraDic = dic;
    }
    return _extraDic;
}

// MARK: 控件更新
/** 更新功能区 */
- (void)updateFunctionView {
    if (self.orderedData) {
        [self.functionView updateADFunction:self.orderedData];
    }
}

/** 更新标题 */
- (void)updateTitleView:(CGFloat)fontSize isAction:(BOOL)isAction {
    if (self.orderedData) {
        //拨打电话的大标题用title，app下载用description字段
        NSString *title = [TTLayOutCellDataHelper getTitleStyle2WithOrderedData:self.orderedData];
        if (!isEmptyString(title)) {
            self.titleView.font = [UIFont tt_fontOfSize:fontSize];
            self.titleView.lineHeight = kTitleViewLineHeight();
            self.titleView.text = title;
            self.titleView.highlighted = [[[self.orderedData article] hasRead] boolValue];
        } else {
            self.titleView.text = nil;
        }
    }
}

- (void)updateTitleViewWithAction:(BOOL)isAction {
    [self updateTitleView:kTitleViewFontSize() isAction:isAction];
}

- (void)updateTitleView {
    [self updateTitleView:kTitleViewFontSize() isAction:NO];
}

/** 更新图片(视频) */
- (void)updatePicView {
    if (self.orderedData) {
        [self.picView updateADPics:self.orderedData];
    }
}

/** 更新相关信息 */
- (void)updateSourceView {
    if (self.orderedData) {
        NSString *source = [TTLayOutCellDataHelper getADSourceStringWithOrderedDada:self.orderedData];
        if (isEmptyString(source)) {
            self.sourceName.text = nil;
        } else {
            self.sourceName.text = source;
        }
    }
}

/** 更新下载按钮 */
- (void)updateActionView {
    if (self.orderedData) {
        self.actionButton.actionModel = self.orderedData;
        id<TTAdFeedModel> adModel = self.orderedData.adModel;
        if ([adModel isCreativeAd]) {
            self.actionButton.adModel = adModel;
            BOOL call2Action = ([[adModel type] isEqualToString:@"action"]);
            [self.actionButton setIconImageNamed:(call2Action ? @"callicon_ad_textpage" : nil)];
        }
    }
}

/** 更新信息栏 */
- (void)updateInfoView {
    if (self.orderedData) {
        [self.infoView updateInfoView:self.orderedData];
    }
}

/** 更新广告信息栏 */
- (void)updateADInfoView {
    if (self.orderedData) {
        [self.adInfoView updateInfoView:self.orderedData];
    }
}

/** 更新广告信息栏 */
- (void)updateADActionView {
    if (self.orderedData) {
        [self.adActionView updateADActionView:self.orderedData];
    }
}

/** 更新底部分割线 */
- (void)updateBottomLineView {}

/** 更新视频cell标题 */
- (void)updateVideoTitleLabel {
    if (self.orderedData) {
        NSString *title = [TTLayOutCellDataHelper getTitleStyle2WithOrderedData:self.orderedData];
        if (!isEmptyString(title)) {
            self.videoTitleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:title fontSize:kVideoCellTitleFontSize() lineHeight:[UIFont systemFontOfSize:kVideoCellTitleFontSize()].lineHeight lineBreakMode:NSLineBreakByWordWrapping isBoldFontStyle:YES];
        } else {
            self.videoTitleLabel.text = nil;
        }
    }
}

/** 更新视频频道大图遮罩 */
- (void)updateTopMaskView {}

/** 更新actionbar */
- (void)updateActionBar {
    self.actionBar.schemeType = TTVideoCellActionBarLayoutSchemeAD;
    [self.actionBar refreshWithData:self.orderedData];
}

/** 布局更多控件 */
- (void)layoutMoreView {
    self.moreView.right = self.cellView.width - kPaddingRight() + kMoreViewExpand();
    self.moreView.centerY = self.functionView.centerY;
    if ([[self.orderedData actionList] count] > 0) {
        self.moreView.hidden = NO;
    } else {
        self.moreView.hidden = YES;
    }
}

+ (CGFloat)preferredContentTextSize {
    return kTitleViewFontSize();
}


- (void)actionBarAdActionButtonClicked:(id)sender {
    if (self.orderedData) {
        id<TTAdFeedModel> adModel = self.orderedData.adModel;
        if ([adModel isCreativeAd]) {
            if ([adModel adType] == ExploreActionTypeApp) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click" eventName:@"embeded_ad" extra:@{@"has_v3":@"1"} duration:0];
                [[self class] trackRealTime:self.orderedData extraData:nil];
            }
            else
            {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click" eventName:@"embeded_ad"];
            }
            
            NSString *ad_id = adModel.ad_id;
            NSTimeInterval duration = [[SSADEventTracker sharedManager] durationForAdThisTime:ad_id];
           
            NSString *trackInfo = [[TTAdImpressionTracker sharedImpressionTracker] endTrack:ad_id];
            NSMutableDictionary *adTrackExtra = [NSMutableDictionary dictionaryWithCapacity:1];
            [adTrackExtra setValue:trackInfo forKey:@"ad_extra_data"];
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"show_over" eventName:@"embeded_ad" extra:adTrackExtra duration:duration];
            
            if ([adModel adType] == ExploreActionTypeAction) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_call" eventName:@"feed_call" clickTrackUrl:NO];
                [self listenCall:adModel];
            }
            else if ([adModel adType] == ExploreActionTypeApp) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_start" eventName:@"feed_download_ad" clickTrackUrl:NO];
            }
            else if (adModel.adType == ExploreActionTypeForm){
                [self showForm:self.orderedData];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionBar.adActionButton.actionModel label:@"click_button" eventName:@"feed_form" clickTrackUrl:NO];
            }
            else if (adModel.adType == ExploreActionTypeCounsel) {
                 [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_counsel" eventName:@"feed_counsel" clickTrackUrl:NO];
            }
            
            [self.actionBar.adActionButton actionButtonClicked:sender showAlert:(sender != nil)];
        }
    }
}



//监听电话状态
- (void)listenCall:(id<TTAdFeedModel>)adModel
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:adModel.ad_id forKey:@"ad_id"];
    [dict setValue:adModel.log_extra forKey:@"log_extra"];
    [dict setValue:[NSDate date] forKey:@"dailTime"];
    [dict setValue:adModel.dialActionType forKey:@"dailActionType"];
    if (adModel && adModel.adType == ExploreActionTypeLocationAction) {
        [dict setValue:@"lbs_ad" forKey:@"position"];
    }
    else {
        [dict setValue:@"feed_call" forKey:@"position"];
    }
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance call_callAdDict:dict];
}

// MARK: 不感兴趣按钮
- (void)accessoryButtonClicked:(id)sender {
    UIButton *accessoryButton = (UIButton *)sender;
    if (accessoryButton) {
        CGPoint p = accessoryButton.origin;
        p.x += 8;
        p.y += 6;

        TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
        TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
        viewModel.keywords = self.orderedData.article.filterWords;
        viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
        viewModel.logExtra = self.orderedData.log_extra;
        [dislikeView refreshWithModel:viewModel];
        CGPoint point = accessoryButton.center;
        [dislikeView showAtPoint:point
                        fromView:accessoryButton
                 didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                     [self exploreDislikeViewOKBtnClicked:view];
                 }];
        [self trackAdDislikeClick];
    }
    
}

- (void)trackAdDislikeClick
{
    if (self.orderedData.adIDStr.longLongValue > 0) {
        [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"dislike" eventName:@"embeded_ad"];
    }
}

- (void)trackAdDislikeConfirm:(NSArray *)filterWords
{
    if (self.orderedData.adIDStr.longLongValue > 0) {
        NSMutableDictionary *extra = [@{} mutableCopy];
        [extra setValue:filterWords forKey:@"filter_words"];
        [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"final_dislike" eventName:@"embeded_ad" extra:@{@"ad_extra_data": [extra JSONRepresentation]} duration:0];
    }
}

// MARK: 下载按钮协议
- (void)downloadButtonActionFired:(ExploreActionButton *)sender {
    if (self.orderedData) {
        id<TTAdFeedModel> adModel = self.orderedData.adModel;
        if ([adModel isCreativeAd]) {
            TTTouchContext *touchContext = [sender.lastTouchContext toView:self.cellView];
            NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:2];
            NSMutableDictionary *ad_extra_data = [NSMutableDictionary dictionaryWithCapacity:8];
            NSDictionary *adCellLayoutInfo = [self adCellLayoutInfo];
            if (adCellLayoutInfo) {
                [ad_extra_data addEntriesFromDictionary:adCellLayoutInfo];
            }
            NSDictionary *touchInfo = [touchContext touchInfo];
            if (touchInfo) {
                [ad_extra_data addEntriesFromDictionary:touchInfo];
            }
            [extrData setValue:[TTTouchContext format2JSON:ad_extra_data] forKey:@"ad_extra_data"];
            [extrData setValue:@"2" forKey:@"ext_value"];
            if ([adModel adType] == ExploreActionTypeApp) {
                [extrData setValue:@"1" forKey:@"has_v3"];
                [[self class] trackRealTime:self.orderedData extraData:extrData];
            
            }

            NSString *adID = self.orderedData.ad_id;
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click" eventName:@"embeded_ad" extra:extrData duration:0];
            NSTimeInterval duration = [[SSADEventTracker sharedManager] durationForAdThisTime:adID];

            NSString *trackInfo = [[TTAdImpressionTracker sharedImpressionTracker] endTrack:adID];
            NSMutableDictionary *adTrackExtra = [NSMutableDictionary dictionaryWithCapacity:1];
            [adTrackExtra setValue:trackInfo forKey:@"ad_extra_data"];
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"show_over" eventName:@"embeded_ad" extra:adTrackExtra duration:duration];
            
            if ([adModel adType] == ExploreActionTypeAction) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_call" eventName:@"feed_call" extra:@"2" clickTrackUrl:NO];
                [self listenCall:self.actionButton.adModel];
            }
            else if ([adModel adType] == ExploreActionTypeApp){
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_start" eventName:@"feed_download_ad" clickTrackUrl:NO];
                
            }
            else if ([adModel adType] == ExploreActionTypeForm){
                [self showForm:self.orderedData];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_button" eventName:@"feed_form" clickTrackUrl:NO];
            }
            else if ([adModel adType] == ExploreActionTypeCounsel) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_counsel" eventName:@"feed_counsel" clickTrackUrl:NO];
            }
            else if ([adModel adType] == ExploreActionTypeLocationAction){
                
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_call" eventName:@"lbs_ad" clickTrackUrl:NO];
                [self listenCall:self.actionButton.adModel];
                
            }
            else if ([adModel adType] == ExploreActionTypeLocationForm){
                [self showForm:self.orderedData];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_button" eventName:@"lbs_ad" clickTrackUrl:NO];
                
            }
            else if ([adModel adType] == ExploreActionTypeLocationcounsel){
                
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_counsel" eventName:@"lbs_ad" clickTrackUrl:NO];
                
            }
            
            [self.actionButton actionButtonClicked:sender showAlert:(sender != nil)];
        }
    }
}


- (void)showForm:(ExploreOrderedData *)orderdata
{
    id<TTAdFeedModel> adModel = orderdata.adModel;
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra formUrl:adModel.form_url width:adModel.form_width height:adModel.form_height sizeValid:adModel.use_size_validation];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceFeed completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeCloseForm) {
            if (adModel.adType == ExploreActionTypeLocationForm) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"click_cancel" eventName:@"lbs_ad"];
            }
            else {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"click_cancel" eventName:@"feed_form"];
            }
        }
        else if (type == TTAdApointCompleteTypeLoadFail){
            if (adModel.adType == ExploreActionTypeLocationForm) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"load_fail" eventName:@"lbs_ad"];
            }
            else {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"load_fail" eventName:@"feed_form"];
            }
        }
    }];
}


+ (void)trackRealTime:(ExploreOrderedData*)orderData extraData:(NSDictionary *)extraData
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:orderData.ad_id forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:orderData.log_extra forKey:@"log_extra"];
    [params setValue:@"2" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [params addEntriesFromDictionary:[orderData realTimeAdExtraData:@"embeded_ad" label:@"click" extraData:extraData]];
    [TTTracker eventV3:@"realtime_click" params:params];
}


- (void)adLocationLabelClick:(UITapGestureRecognizer *)gesture{
    
    id<TTAdFeedModel> admodel = self.orderedData.adModel;
    if (self.orderedData && [admodel isCreativeAd]) {
        if (admodel.adType == ExploreActionTypeLocationForm || admodel.adType == ExploreActionTypeLocationAction || admodel.adType == ExploreActionTypeLocationcounsel) {
            
            NSString *locationUrl = admodel.location_url;
            if (!isEmptyString(locationUrl)) {
    
                NSMutableString *webUrlString = [NSMutableString stringWithString:locationUrl];
                SSWebViewController * controller = [[SSWebViewController alloc] initWithSupportIPhoneRotate:YES];
                controller.adID = admodel.ad_id;
                controller.logExtra = admodel.log_extra;
                [controller requestWithURL:[TTStringHelper URLWithURLString:webUrlString]];
                UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
                [topController.navigationController pushViewController:controller animated:YES];
                [controller setTitleText:admodel.webTitle];
            }
            
            NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:2];
            if (gesture && [gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                
                CGPoint tapPoint = [gesture locationInView:self];
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
                [dict setValue:@(self.width) forKey:@"width"];
                [dict setValue:@(self.height) forKey:@"height"];
                [dict setValue:@(tapPoint.x) forKey:@"click_x"];
                [dict setValue:@(tapPoint.y) forKey:@"click_y"];
                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
                NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                if (!isEmptyString(json)) {
                    [extrData setValue:json forKey:@"ad_extra_data"];
                }
                
                [extrData setValue:@"2" forKey:@"ext_value"];
            }
            
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click" eventName:@"embeded_ad" extra:extrData duration:0];
            
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_shop" eventName:@"lbs_ad"];
            
        }
        
    }
    
}


// MARK: 更多控件协议
- (void)moreViewClick {
    [self showMenu];
    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_more" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:[self extraDic]];
}

- (void)showMenu {
    ExploreOrderedData *orderedData = self.orderedData;
    if (!orderedData) {
        return;
    }
    
    NSArray<NSDictionary *> *actionList = [orderedData actionList];
    if ([actionList count] <= 0) {
        return;
    }
    NSMutableArray<TTActionListItem *> *actionItem = [[NSMutableArray<TTActionListItem *> alloc] init];
    for (NSDictionary *action in actionList) {
        NSNumber *type = action[@"action"];
        if (type) {
            NSInteger typeNum = [type integerValue];
            switch (typeNum) {
                // 不感兴趣
                case 1:
                {
                    NSString *description = @"不感兴趣";
                    NSString *iconName = @"ugc_icon_not_interested";
                    if (!isEmptyString([action stringValueForKey:@"desc" defaultValue:nil])) {
                        description = [action stringValueForKey:@"desc" defaultValue:nil];
                    }
                    NSMutableArray<TTFeedDislikeWord *> *dislikeWords = [[NSMutableArray<TTFeedDislikeWord *> alloc] init];
                    NSNumber *groupId = nil;
                    NSArray<NSDictionary *> *filterWords = nil;
                    if ([orderedData article]) {
                        groupId = @([[orderedData article] uniqueID]);
                        filterWords = [[orderedData article] filterWords];
                    }
                    if (groupId == nil) {
                        break;
                    }
                    if (filterWords) {
                        for (NSDictionary *words in filterWords) {
                            TTFeedDislikeWord *word = [[TTFeedDislikeWord alloc] initWithDict:words];
                            [dislikeWords addObject:word];
                        }
                    }
                    
                    NSMutableDictionary *extraValueDic = [[NSMutableDictionary alloc] init];
                    extraValueDic[@"log_extra"] = self.orderedData.log_extra;
                
                    
                    if ([dislikeWords count] > 0) {
                        WeakSelf;
                        TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName hasSub:YES action:^{
                            StrongSelf;
                            if (self.orderedData) {
                                [[TTActionPopView shareView] showDislikeView:self.orderedData dislikeWords:dislikeWords groupID:groupId];
                            }
                            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"show_dislike_with_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
                        }];
                        [actionItem addObject:item];
                    } else {
                        WeakSelf;
                        TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName hasSub:NO action:^{
                            StrongSelf;
                            if (self.orderedData) {
                                [[TTActionPopView shareView] showDislikeView:self.orderedData dislikeWords:dislikeWords groupID:groupId];
                            }
                            [self dislikeButtonClicked:[[NSArray<NSString *> alloc] init]];
                        }];
                        [actionItem addObject:item];
                    }
                }
                    break;
                // 不喜欢某一项
                case 2:
                {
                    NSString *iconName = @"ugc_icon_dislike";
                    NSString *desc = action[@"desc"];
                    NSDictionary *filterWord = action[@"extra"];
                    if (!isEmptyString(desc) && filterWord) {
                        NSString *dislikeId = [[[TTFeedDislikeWord alloc] initWithDict:filterWord] ID];
                        if (!isEmptyString(dislikeId)) {
                            WeakSelf;
                            TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:desc iconName:iconName action:^{
                                StrongSelf;
                                [self dislikeButtonClicked:@[dislikeId] onlyOne:YES];
                            }];
                            [actionItem addObject:item];
                        }
                    }
                }
                    break;
                // 分享
                case 7:
                {
                    Article *article = [orderedData article];
                    if (!article) {
                        break;
                    }
                    NSString *iconName = @"ugc_icon_share";
                    NSString *description = @"分享";
                    if (!isEmptyString([action stringValueForKey:@"desc" defaultValue:nil])) {
                        description = [action stringValueForKey:@"desc" defaultValue:nil];
                    }
                    WeakSelf;
                    TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName action:^{
                        StrongSelf;
                        
                        NSNumber *adID = isEmptyString(orderedData.ad_id) ? nil : @(orderedData.ad_id.longLongValue);
                        NSArray *activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:article adID:adID   showReport:NO];
                        NSMutableArray<TTActivity *> *group1 = [[NSMutableArray<TTActivity *> alloc] init];
                        for (id activity in activityItems) {
                            TTActivity *acti = (TTActivity *)activity;
                            if (acti) {
                                [group1 addObject:acti];
                            }
                        }
                        self.phoneShareView = [[SSActivityView alloc] init];
                        self.phoneShareView.delegate = self;
                        [self.phoneShareView showActivityItems:@[group1]];
                        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"list_share" label:@"share_button" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:self.extraDic];
                    }];
                    [actionItem addObject:item];
                }
                    break;
                // 举报
                case 9:
                {
                    Article *article = [orderedData article];
                    if (!article) {
                        break;
                    }
                    NSString *iconName = @"ugc_icon_report";
                    NSString *description = @"举报";
                    if (!isEmptyString([action stringValueForKey:@"desc" defaultValue:nil])) {
                        description = [action stringValueForKey:@"desc" defaultValue:nil];
                    }
                    WeakSelf;
                    TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName action:^{
                        StrongSelf;
                        self.actionSheetController = [[TTActionSheetController alloc] init];
                        [self.actionSheetController insertReportArray:[TTReportManager fetchReportArticleOptions]];
                        WeakSelf;
                        [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
                            StrongSelf;
                            TTGroupModel *groupModel = self.orderedData.article.groupModel;
                            TTReportContentModel *model = [[TTReportContentModel alloc] init];
                            model.groupID = groupModel.groupID;
                            model.itemID = groupModel.itemID;
                            model.aggrType = @(groupModel.aggrType);
                            [[TTReportManager shareInstance] startReportContentWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeAD reportFrom:TTReportFromByEnterFromAndCategory(nil, self.orderedData.categoryID) contentModel:model extraDic:nil animated:YES];
                        }];
                        
                        
                        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"report" value:[@([[self.orderedData article] uniqueID]) stringValue] source:nil extraDic:self.extraDic];
                    }];
                    [actionItem addObject:item];
                }
                    break;
                default:
                    break;
            }
        } else {
            continue;
        }
    }

    if ([actionItem count] <= 0) {
        return;
    }
    
    TTActionPopView *popupView = [[TTActionPopView alloc] initWithActionItems:actionItem width:self.cellView.width];
    popupView.delegate = self;
    CGPoint p = self.moreView.center;
    [popupView showAtPoint:p fromView:self.moreView];
}

- (void)dislikeButtonClicked:(NSArray<NSString *> *)selectedWords onlyOne:(BOOL)onlyOne {
    if (!self.orderedData) {
        return;
    }
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[kExploreMixListNotInterestItemKey] = self.orderedData;
    
    NSMutableDictionary *extraValueDic = [[NSMutableDictionary alloc] init];
    extraValueDic[@"log_extra"] = self.orderedData.log_extra;
    
    if ([selectedWords count] > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = selectedWords;
        if (onlyOne) {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"confirm_dislike_only_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
        } else {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"confirm_dislike_with_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
        }
    } else {
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"confirm_dislike_no_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

- (void)dislikeButtonClicked:(NSArray<NSString *> *)selectedWords {
    [self dislikeButtonClicked:selectedWords onlyOne:NO];
}

// MARK: 功能区协议
- (void)functionViewLikeViewClick {
    NSString *recommendUrl = [self.orderedData recommendUrl];
    if (!isEmptyString(recommendUrl)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:recommendUrl]];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_reason" value:[@([[self.orderedData article] uniqueID]) stringValue] source:nil extraDic:self.extraDic];
    }
}

- (void)functionViewPGCClick {
    NSString *sourceUrl = [[self.orderedData article] sourceOpenUrl];
    if (!isEmptyString(sourceUrl)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:sourceUrl]];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_source" value:[@([[self.orderedData article] uniqueID]) stringValue] source:nil extraDic:self.extraDic];
    }
}

// MARK: 信息栏协议
- (void)digButtonClick:(TTDiggButton *)button {
    if (self.originalData == nil) {
        return;
    }
    if ([self.originalData userDigg]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经赞过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    [self.originalData setUserDigg:YES];
    int diggCount = [self.originalData diggCount];
    diggCount = diggCount + 1;
    [[self.orderedData originalData] setDiggCount:diggCount];
    [button setDiggCount:diggCount];
    CGFloat centerY = button.centerY;
    [button sizeToFit];
    button.centerY = centerY;

    @try {
        [self.orderedData.originalData save];
    } @catch (NSException *exception) {
        NSLog(@"save fail with error");
    }
    
    [self.itemActionManager sendActionForOriginalData:self.originalData adID:nil actionType:DetailActionTypeDig finishBlock:^(id userInfo, NSError *error) {
    }];
    
    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"like" value:[@([[self.orderedData article] uniqueID]) stringValue] source:nil extraDic:self.extraDic];
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType {
    if (view == self.phoneShareView) {
        NSString *uniqueID = [@([[self.orderedData article] uniqueID]) stringValue];
        BOOL hasVideo = ([[[self.orderedData article] hasVideo] boolValue] || [[self.orderedData article] isVideoSubject]);
        [self.activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor:self] sourceObjectType:(hasVideo ? TTShareSourceObjectTypeVideoList : TTShareSourceObjectTypeUGCFeed) uniqueId:uniqueID adID:nil platform:TTSharePlatformTypeOfMain groupFlags:[[self.orderedData article] groupFlags]];
        self.phoneShareView = nil;
        
        NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
        if (label) {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"list_share" label:label value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:self.extraDic];
        }
    }
}

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView {
    if (self.orderedData == nil) {
        return;
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[kExploreMixListNotInterestItemKey] = self.orderedData;

    NSArray<NSString *> *filterWords = (NSArray<NSString *> *)[dislikeView selectedWords];
    if ([filterWords count] > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = filterWords;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
    [self trackAdDislikeConfirm:filterWords];
}

#pragma mark - didSelect

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel{
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    if (self.orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
        if ([self.actionButton isKindOfClass:[ExploreActionButton class]]) {
            [self.actionButton actionButtonClicked:nil showAlert:YES];
        }
    }
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    [super didSelectWithContext:context];
    if (self.orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
        if([self.actionButton isKindOfClass:[ExploreActionButton class]]) {
            [self.actionButton actionButtonClicked:nil showAlert:YES];
        }
    }
}


@end

@implementation TTADBaseCell (TTAdCellLayoutInfo)

- (nonnull NSDictionary *)adCellLayoutInfo {
    NSMutableDictionary *layoutInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    
    if (_accessoryButton) {// not use self.accessoryButton. getter auto add to superView
        CGRect dislikeFrame = _accessoryButton.bounds;
        dislikeFrame = [self convertRect:dislikeFrame fromView:_accessoryButton];
        [layoutInfo setValue:@(CGRectGetMinX(dislikeFrame)) forKey:@"lu_x"];
        [layoutInfo setValue:@(CGRectGetMinY(dislikeFrame)) forKey:@"lu_y"];
        [layoutInfo setValue:@(CGRectGetMaxX(dislikeFrame)) forKey:@"rd_x"];
        [layoutInfo setValue:@(CGRectGetMaxY(dislikeFrame)) forKey:@"rd_y"];
    }
    [layoutInfo setValue:@(CGRectGetWidth(self.frame)) forKey:@"width"];
    [layoutInfo setValue:@(CGRectGetHeight(self.frame)) forKey:@"height"];
    return layoutInfo;
}

@end
