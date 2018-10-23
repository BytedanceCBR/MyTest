//
//  ExploreCellBase.m
//  Article
//
//  Created by Chen Hong on 14-9-10.
//
//

#import "ExploreCellBase.h"
#import "ExploreCellViewBase.h"
#import "SSThemed.h"
#import "SSUserSettingManager.h"
#import "TTDeviceHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "TTAdFeedModel.h"
#import "ExploreArticleCellView.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSWebViewController.h"
#import "ArticleDetailHeader.h"
#import "TTFeedContainerViewModel.h"
#import "NewsDetailConstant.h"
#import "TTAppLinkManager.h"
#import "ExploreMovieView.h"
#import "Card+CoreDataClass.h"
#import "ExploreArticleCardCellView.h"
#import "HuoShan.h"
#import "NetworkUtilities.h"
//#import "TTVideoTabHuoShanCellView.h"
//#import "LiveRoomPlayerViewController.h"
#import "TTThemedAlertController.h"
#import "TTIndicatorView.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTVideoShareMovie.h"
//#import "Thread.h"
//#import "TTForumCellHelper.h"
#import "TTRoute.h"
#import "TSVShortVideoOriginalData.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTLayOutCellViewBase.h"
#import "HTSVideoPageParamHeader.h"
#import <TSVDebugInfoConfig.h>

NSInteger const kCustomEditControlWidth = 53.f;

@interface ExploreCellBase ()
@property (nonatomic, assign) UITableViewCellStateMask willChangeToCellState;
@property (nonatomic, assign) BOOL isfakeEditting;
@property (nonatomic, strong) UIControl *customEditControl;
@property (nonatomic, strong) UILabel *debugInfoLabel;
@end

@implementation ExploreCellBase

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithTableView:(UITableView *)view reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tableView = view;
        self.width = view.width;
        [self initSubViews];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.backgroundColor = self.contentView.backgroundColor;
    self.contentView.backgroundColor = self.backgroundColor;
    
    self.contentView.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged) name:kSettingFontSizeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    self.cellView = [self createCellView];
    self.cellView.cell = self;
    self.cellView.tableView = self.tableView;
    self.cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.cellView];
    self.refer = 1;
    
    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        self.debugInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 25)];
        self.debugInfoLabel.backgroundColor = [[UIColor alloc] initWithWhite:0.9 alpha:0.5];
        self.debugInfoLabel.textColor = [UIColor colorWithHexString:@"0x1E90FF"];
        self.debugInfoLabel.font = [UIFont systemFontOfSize:10];
        self.debugInfoLabel.numberOfLines = 0;
        self.debugInfoLabel.hidden = YES;
        [self.contentView addSubview:self.debugInfoLabel];
    }
}

- (void)setDelegate:(id<CustomTableViewCellEditDelegate>)delegate {
    if (delegate && _delegate != delegate) {
        _delegate = delegate;
        [self addCustomEditControl];
    }
}

- (void)addCustomEditControl {
    if (self.delegate && [self.delegate respondsToSelector:@selector(isFakeEditing)]
        && [self.delegate respondsToSelector:@selector(customEditControl)]
        && [self.delegate respondsToSelector:@selector(customEditIndent)] ) {
        if (self.delegate.isFakeEditing && self.delegate.customEditControl && self.delegate.customEditIndent > 0) {
            self.customEditControl = self.delegate.customEditControl;
            [self.contentView addSubview:self.customEditControl];
            [self.contentView sendSubviewToBack:self.customEditControl];
            WeakSelf;
            [self.customEditControl mas_makeConstraints:^(MASConstraintMaker *make) {
                StrongSelf;
                make.left.top.height.equalTo(self.cellView);
                make.width.equalTo(@(self.delegate.customEditIndent));
            }];
            self.customEditControl.userInteractionEnabled = NO;
        }
    }
}

+ (Class)cellViewClass
{
    return [ExploreCellViewBase class];
}

- (ExploreCellViewBase *)createCellView
{
    Class cellViewCls = [[self class] cellViewClass];
    return [[cellViewCls alloc] initWithFrame:[TTUIResponderHelper splitViewFrameForView:self]];
}

- (void)refreshUI
{
    [self.cellView refreshUI];
    
    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        if (!self.debugInfoLabel) {
            self.debugInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 25)];
            self.debugInfoLabel.backgroundColor = [[UIColor alloc] initWithWhite:0.9 alpha:0.5];
            self.debugInfoLabel.textColor = [UIColor colorWithHexString:@"0x1E90FF"];
            self.debugInfoLabel.font = [UIFont systemFontOfSize:10];
            self.debugInfoLabel.numberOfLines = 0;
            self.debugInfoLabel.hidden = YES;
            [self.contentView addSubview:self.debugInfoLabel];
        }
        
        if([[self cellData] isKindOfClass:[ExploreOrderedData class]]){
            ExploreOrderedData *orderedData = (ExploreOrderedData *)[self cellData];
            self.debugInfoLabel.text = orderedData.debugInfo;
            if (orderedData.debugInfo && orderedData.debugInfo.length > 0) {
                self.debugInfoLabel.hidden = NO;
            } else {
                self.debugInfoLabel.hidden = YES;
            }
        }
    } else {
        self.debugInfoLabel.hidden = YES;
    }
}

- (void)setUmengEvent:(NSString *)umengEvent {
    _umengEvent = umengEvent;
    _cellView.umengEvent = umengEvent;
}

// iPad上cellView需要根据屏幕尺寸做留白
- (CGFloat)paddingForCellView {
    return [TTUIResponderHelper paddingForViewWidth:0];
}

- (CGFloat)paddingTopBottomForCellView {
    return 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = [TTUIResponderHelper splitViewFrameForView:self];
    CGFloat topPadding = [self paddingTopBottomForCellView];
    self.cellView.frame = CGRectMake(0, topPadding, rect.size.width, rect.size.height - topPadding * 2);
    
    if ([TTDeviceHelper isPadDevice])
    {
        CGFloat padding = [self paddingForCellView];
        self.cellView.frame = CGRectMake(padding, topPadding, self.bounds.size.width - 2*padding, self.bounds.size.height-2*topPadding);

//#warning TO BE Checked -- nick
        // for cell编辑状态
        if (self.cellView.width < 500)
        {
            if (self.willChangeToCellState == UITableViewCellStateDefaultMask) {
            }
            else if ((self.willChangeToCellState & UITableViewCellStateShowingDeleteConfirmationMask) != 0) {
                self.cellView.frame = CGRectMake(-30, 0, [TTUIResponderHelper splitViewFrameForView:self].size.width, [TTUIResponderHelper splitViewFrameForView:self].size.height);
            }
            else if ((self.willChangeToCellState & UITableViewCellStateShowingEditControlMask) != 0) {
                self.cellView.frame = CGRectMake(CGRectGetMinX(self.cellView.frame), 0, [TTUIResponderHelper splitViewFrameForView:self].size.width, [TTUIResponderHelper splitViewFrameForView:self].size.height);

            }
        }
        else if (self.width >= 1024)//全屏
        {
            if (self.willChangeToCellState == UITableViewCellStateDefaultMask) {
            }
            else if ((self.willChangeToCellState & UITableViewCellStateShowingDeleteConfirmationMask) != 0) {
                self.cellView.left = 82.5;
            }
            else if ((self.willChangeToCellState & UITableViewCellStateShowingEditControlMask) != 0) {
                self.cellView.left = 82.5;
            }
        }
    }else{
        if (self.willChangeToCellState==3) {
            self.cellView.left = -30;
            self.willChangeToCellState = 0;//如果cell被delete后，貌似本cell是被复用的 但本变量未被重置，这样是有问题的，手动把变量状态清0. 是改动最小的办法
        }else{
            self.cellView.left = 0;
        }
    }
    
    if (self.cellData) {
//        if ([self.cellData isKindOfClass:[ExploreOrderedData class]]) {
//            ((ExploreOrderedData *)self.cellData).cellLayOut.needUpdateAllFrame = YES;
//        }
        [self refreshUI];
    }
    
    if (self.isfakeEditting) {
        self.cellView.left = self.cellView.left + [self.delegate customEditIndent] - kCellLeftPadding;//要减去标题与屏幕左侧的间隙
    }
    
    [self updateCustomEditControlIsDeleting:self.isfakeEditting];
}

// 收藏列表支持编辑模式
- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    self.willChangeToCellState = state;
}

- (void)willDisplay
{
    //donothing ...
}

- (void)didEndDisplaying
{
    //donothing ...
}

- (void)willAppear
{
    //donothing ...
}

- (void)resumeDisplay
{
    //donothing ...
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    // donothing...
}

- (void)refreshWithData:(id)data
{
    [self.cellView refreshWithData:data];
    [self.cellView refreshDone];
}

- (id)cellData
{
    return [self.cellView cellData];
}

- (void)fontSizeChanged
{
    [self.cellView fontSizeChanged];
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)cellType
{
    return [[self cellViewClass] heightForData:data cellWidth:width listType:cellType];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (!self.isfakeEditting) {
        [_cellView setHighlighted:selected animated:animated];
    }
}

- (void)setCustomControlSelected:(BOOL)isSelected {
    self.customEditControl.selected = isSelected;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    BOOL wasEditting = self.isfakeEditting;
    if ([self.delegate isFakeEditing]) {
        self.isfakeEditting = editing;
        if (wasEditting != self.isfakeEditting) {
            [self beginEditMode];
        }
    } else {
        [super setEditing:editing animated:animated];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (!self.isfakeEditting && ![SSCommonLogic transitionAnimationEnable]) {
        [_cellView setHighlighted:highlighted animated:animated];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.contentView.backgroundColor = self.backgroundColor;
}

- (void)setDataListType:(ExploreOrderedDataListType)listType
{
    _cellView.listType = listType;
}

- (void)setTableView:(UITableView *)tableView
{
    if (_tableView != tableView) {
        _tableView = tableView;
        self.cellView.tableView = tableView;
    }
}

- (BOOL)shouldRefesh {
    return [_cellView shouldRefresh];
}

//- (UIView *)animationFromView
//{
//    return [self.cellView animationFromView];
//}
//
//- (UIImage *)animationFromImage
//{
//    return [self.cellView animationFromImage];
//}


- (ExploreCellStyle)cellStyle {
    //统计需求：如果文章是广告类型的话，不上传
    if([self isCellForShowAD]){
        return ExploreCellStyleUnknown;//当返回的类型是ExploreCellStyleUnknown,impression里面不会带有style字段
    }
    return [_cellView cellStyle];
}

- (ExploreCellSubStyle)cellSubStyle {
    //统计需求：如果文章是广告类型的话，不上传
    if([self isCellForShowAD]){
        return ExploreCellSubStyleUnknown;//当返回的类型是ExploreCellSubStyleUnknown,impression里面不会带有sub_style字段
    }
    return [_cellView cellSubStyle];
}

//判断cell是否用来展示广告
- (BOOL)isCellForShowAD {
    if([[self cellData] isKindOfClass:[ExploreOrderedData class]]){
        ExploreOrderedData *orderedData = (ExploreOrderedData *)[self cellData];
        return !isEmptyString(orderedData.ad_id);
    }
    return NO;
}

- (NewsGoDetailFromSource)goDetailFromSouceFromViewModel:(TTFeedContainerViewModel *)viewModel
{
    if (!isEmptyString(viewModel.categoryID) && [viewModel.categoryID isEqualToString:kTTMainCategoryID]) {
        return NewsGoDetailFromSourceHeadline;
    }
    else if (viewModel.listType == ExploreOrderedDataListTypeCategory) {
        return NewsGoDetailFromSourceCategory;
    }
    else if (viewModel.listType == ExploreOrderedDataListTypeFavorite) {
        return NewsGoDetailFromSourceFavorite;
    }
    else if (viewModel.listType == ExploreOrderedDataListTypeReadHistory) {
        return NewsGoDetailFromSourceReadHistory;
    }
    else if (viewModel.listType == ExploreOrderedDataListTypePushHistory) {
        return NewsGoDetailFromSourcePushHistory;
    }
    return NewsGoDetailFromSourceUnknow;
}

// 首页列表cell点击处理
- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    [self.cellView didSelectWithContext:context];
    [self.cellView postSelectWithContext:context];
}

// 收藏/历史列表cell点击处理
- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel {
    ExploreOrderedData *orderedData = self.cellData;
    
    BOOL isCard = NO;
    NSInteger cardIndex = -1;
    NSString *cardId = nil;
    
    // 卡片 - obj为卡片内选中的文章
    if ([orderedData.originalData isKindOfClass:[Card class]]) {
        isCard = YES;
        ExploreArticleCardCellView *cellView = (ExploreArticleCardCellView *)self.cellView;
        cardIndex = cellView.selectedSubCellIndex;
        cardId = cellView.cardId;
    }
    
    UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
    if ([((ExploreOrderedData *)self.cellData).originalData isKindOfClass:[Article class]])
    {
        Article * article = (Article *)((ExploreOrderedData *)self.cellData).originalData;
        NSString *ad_id = orderedData.ad_id;

        if (([article.groupFlags longLongValue] & kArticleGroupFlagsOpenUseWebViewInList) > 0 && !isEmptyString(article.articleURLString)) {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
            [parameters setValue:ad_id forKey:SSViewControllerBaseConditionADIDKey];
            [parameters setValue:orderedData.log_extra forKey:@"log_extra"];
            ssOpenWebView([TTStringHelper URLWithURLString:article.articleURLString], nil, topController.navigationController, !!(ad_id), parameters);
        }
        else {
            NewsGoDetailFromSource fromSource = [self goDetailFromSouceFromViewModel:viewModel];
            NSMutableDictionary *statParams = [NSMutableDictionary dictionary];
            [statParams setValue:viewModel.categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
            [statParams setValue:@(fromSource) forKey:kNewsGoDetailFromSourceKey];
            
            if (!isEmptyString(cardId)) {
                NSDictionary *cardParam = @{@"card_id":cardId, @"card_position":@(cardIndex)};
                [statParams setValue:cardParam forKey:@"stat_params"];
            }
            [statParams setValue:@(article.uniqueID) forKey:@"groupid"];
            [statParams setValue:@(article.uniqueID) forKey:@"group_id"];
            [statParams setValue:article.itemID forKey:@"item_id"];
            [statParams setValue:article.aggrType forKey:@"aggr_type"];
            [statParams setValue:orderedData forKey:@"ordered_data"];
            
            //打开详情页：优先判断openURL是否可以用外部schema打开，否则判断内部schema
            
            BOOL canOpenURL = NO;
            
            //好害怕...不敢动这的逻辑... @by zengruihuan
            NSMutableDictionary *applinkParams = [NSMutableDictionary dictionary];
            [applinkParams setValue:orderedData.log_extra forKey:@"log_extra"];
            //视频广告被点击不尝试吊起淘宝、京东SDK
            BOOL isVideo = orderedData.article.hasVideo.integerValue;
            if (ad_id && isVideo == NO) {
                if ([TTAppLinkManager dealWithWebURL:article.articleURLString openURL:article.openURL sourceTag:@"embeded_ad" value:ad_id extraDic:applinkParams]) {
                    //针对广告并且能够通过sdk打开的情况
                    canOpenURL = YES;
                }
            }
            else if (!isEmptyString(article.openURL)) {
                NSURL *url = [TTStringHelper URLWithURLString:article.openURL];
                
                
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    canOpenURL = YES;
                    [[UIApplication sharedApplication] openURL:url];
                }
                else if ([[TTRoute sharedRoute] canOpenURL:url]) {
                    
                    canOpenURL = YES;
                    
                    if ([article isImageSubject] && ![SSCommonLogic appGalleryTileSwitchOn] && [SSCommonLogic appGallerySlideOutSwitchOn]) {
                        
                        [statParams setValue:@(0) forKey:@"animated"];
                    }
                    
                    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(statParams)];
                    //针对广告不能通过sdk打开，但是传的有内部schema的情况
                    if(!isEmptyString(orderedData.ad_id)){
                        wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", ad_id, nil, applinkParams);
                    }
                }
            }
            
            if(!canOpenURL) {
                NSString *detailURL = [NSString stringWithFormat:@"sslocal://detail?groupid=%lld", orderedData.article.uniqueID];
                if (!isEmptyString(ad_id)) {
                    detailURL = [detailURL stringByAppendingFormat:@"&ad_id=%@", ad_id];
                    //针对不能通过sdk和openurl打开的情况
                    if (!isEmptyString(article.openURL)) { //open_url存在,没有成功唤起app @muhuai
                        wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", ad_id, nil, applinkParams);
                    }
                }
                
                //5.7详情页图集特殊
                if ([article isImageSubject] && ![SSCommonLogic appGalleryTileSwitchOn] && [SSCommonLogic appGallerySlideOutSwitchOn]) {
                    
                    [statParams setValue:@(0) forKey:@"animated"];
                    CGRect picViewFrame = CGRectZero;
                    TTArticlePicViewStyle picViewStyle = TTArticlePicViewStyleNone;
                    TTArticlePicView *picView = nil;
                    ExploreCellViewBase *cellView = self.cellView;
                    if ([cellView isKindOfClass:[ExploreArticleCellView class]]) {
                        picView = ((ExploreArticleCellView *)cellView).picView;
                    }
                    else if ([cellView isKindOfClass:[TTLayOutCellViewBase class]]) {
                        picView = ((TTLayOutCellViewBase *)cellView).picView;
                    }
                    if (picView && picView.superview) {
                        picViewFrame = [picView convertRect:picView.bounds toView:self.cellView];
                        picViewStyle = picView.style;
                    }
                    [statParams setValue:NSStringFromCGRect(picViewFrame) forKey:@"picViewFrame"];
                    [statParams setValue:@(picViewStyle) forKey:@"picViewStyle"];
                    [statParams setValue:self.cellView forKey:@"targetView"];
                    statParams[@"ordered_data"] = orderedData;
                }
                
                
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:detailURL] userInfo:TTRouteUserInfoWithDict(statParams)];
            }
        }
        
        article.hasRead = [NSNumber numberWithBool:YES];
        [article save];
        
        if (!isEmptyString(ad_id)) {
            if (orderedData.adModel.displayType == TTAdFeedCellDisplayTypeLarge_VideoChannel) {//大图广告停掉视频播放
                [ExploreMovieView removeAllExploreMovieView];
            }
        }
    }
//    else if ([((ExploreOrderedData *)self.cellData).originalData isKindOfClass:[HuoShan class]])
//    {
//
//        HuoShan * huoShanModel = (HuoShan *)((ExploreOrderedData *)self.cellData).originalData;
//
//        //入口需要发送统计
//        NSString *labelStr = @"";
//        if ([((ExploreOrderedData *)self.cellData).categoryID isEqualToString:@"__all__"]) {
//            labelStr = @"click_headline";
//        }
//        //统计代码先注掉
////        else if ([((ExploreOrderedData *)self.cellData).categoryID isEqualToString:@"hotsoon"]) {
////            NSNumber *tab = [self.externalRequestCondtion objectForKey:kExploreFetchListConditionListFromTabKey];
////            if (tab.integerValue == TTCategoryModelTopTypeVideo) {
////
////                labelStr = @"click_subv_hotsoon";
////            }
////            else if (tab.integerValue == TTCategoryModelTopTypeNews) {
////
////                labelStr = @"click_hotsoon";
////            }
////        }
//        else if ([((ExploreOrderedData *)self.cellData).categoryID isEqualToString:@"image_ppmm"]) {
//            labelStr = @"click_image_ppmm";
//        }
//
//        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//            wrapperTrackEventWithCustomKeys(@"go_detail", labelStr, huoShanModel.liveId.stringValue, nil, @{@"room_id":huoShanModel.liveId,@"user_id":[huoShanModel.userInfo objectForKey:@"user_id"]});
//        }
//
//        //log3.0 doubleSending
//        NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:4];
//        [logv3Dic setValue:huoShanModel.liveId forKey:@"room_id"];
//        [logv3Dic setValue:[huoShanModel.userInfo objectForKey:@"user_id"] forKey:@"user_id"];
//        [logv3Dic setValue:labelStr forKey:@"enter_from"];
//        [logv3Dic setValue:((ExploreOrderedData *)self.cellData).logPb forKey:@"log_pb"];
//        [TTTrackerWrapper eventV3:@"go_detail" params:logv3Dic isDoubleSending:YES];
//
//        if (TTNetworkConnected()) {
//            if (TTNetworkWifiConnected() || !huoShanShowConnectionAlertCount) {
//                NSMutableDictionary *params = [NSMutableDictionary dictionary];
//                [params setValue:@(huoShanModel.uniqueID) forKey:@"id"];
//                [params setValue:labelStr forKey:@"refer"];
//                LiveRoomPlayerViewController *huoShanVC = [[LiveRoomPlayerViewController alloc] initFromPushService:params];
//                UINavigationController *topMost = [TTUIResponderHelper topNavigationControllerFor: self];
//                [topMost pushViewController:huoShanVC animated:YES];
//
//            }
//            else {
//                if (huoShanShowConnectionAlertCount) {
//                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"您当前正在使用移动网络，继续播放将消耗流量", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
//                    [alert addActionWithTitle:NSLocalizedString(@"停止播放", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
//
//                    }];
//                    [alert addActionWithTitle:NSLocalizedString(@"继续播放", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
//                        huoShanShowConnectionAlertCount = NO;
//                        NSMutableDictionary *params = [NSMutableDictionary dictionary];
//                        [params setValue:@(huoShanModel.uniqueID) forKey:@"id"];
//                        [params setValue:labelStr forKey:@"refer"];
//                        LiveRoomPlayerViewController *huoShanVC = [[LiveRoomPlayerViewController alloc] initFromPushService:params];
//                        UINavigationController *topMost = [TTUIResponderHelper topNavigationControllerFor: self];
//                        [topMost pushViewController:huoShanVC animated:YES];
//
//
//                    }];
//                    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
//
//                }
//            }
//        }
//        else {
//            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
//        }
//    }
//else if ([((ExploreOrderedData *)self.cellData).originalData isKindOfClass:[Thread class]]) {
//        NSString *schema = [(Thread *)((ExploreOrderedData *)self.cellData).originalData schema];
//        if (!isEmptyString(schema)) {
//            if ([(ExploreOrderedData *)self.cellData isU11Cell] || [(ExploreOrderedData *)self.cellData isU13Cell]) {
//                NSDictionary *extraDic = [TTForumCellHelper getLogExtraDictionaryWithOrderedData:self.cellData refer:self.refer];
//                if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//                    wrapperTrackEventWithCustomKeys(@"cell", @"go_detail", [(ExploreOrderedData *)self.cellData thread].threadId, nil, extraDic);
//                }
//
//                // V3 统计，涉及到 orderedData 差异
//                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
//                NSDictionary *extraDicV3 = [TTForumCellHelper getLogExtraDictionaryV3WithOrderedData:self.cellData refer:self.refer];
//                if (extraDicV3.count > 0) {
//                    [dictionary addEntriesFromDictionary:extraDicV3];
//                }
//
//                if ([orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
//                    [dictionary setValue:@"click_headline" forKey:@"enter_from"];
//                } else {
//                    [dictionary setValue:@"click_category" forKey:@"enter_from"];
//                }
//
//                [dictionary setValue:orderedData.categoryID forKey:@"source"];
//                [dictionary setValue:orderedData.categoryID forKey:@"category_name"];
//                [dictionary setValue:orderedData.thread.threadId forKey:@"category_id"];
//                [dictionary setValue:orderedData.logPb forKey:@"log_pb"];
//                [TTTrackerWrapper eventV3:@"cell_go_detail" params:[dictionary copy] isDoubleSending:YES];
//            }
//            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:schema]];
//            ((ExploreOrderedData *)self.cellData).originalData.hasRead = @(YES);
//            [((ExploreOrderedData *)self.cellData).originalData save];
//        }
//    }
else if ([((ExploreOrderedData *)self.cellData).originalData isKindOfClass:[TSVShortVideoOriginalData class]]) {
        [self didSelectWithContext:nil];
    }
}

- (void)willDisplayAtIndexPath:(nonnull NSIndexPath *)indexPath viewModel:(nonnull TTFeedContainerViewModel *)viewModel{
}

- (void)didEndDisplayAtIndexPath:(nonnull NSIndexPath *)indexPath viewModel:(nonnull TTFeedContainerViewModel *)viewModel {
}

#pragma mark - Private Method

//显示/隐藏自定义编辑图标加入动画
- (void)beginEditMode {
    [UIView animateWithDuration:0.3 animations:^{
        [self updateCustomEditControlIsDeleting:self.isfakeEditting];
    }];
}

- (void)updateCustomEditControlIsDeleting:(BOOL)isDeleting {
    WeakSelf;
    
    if (isDeleting) {
        [self.customEditControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            StrongSelf;
            make.top.height.equalTo(self.cellView);
            make.right.equalTo(self.cellView.mas_left).with.offset(kCellLeftPadding);
            make.width.mas_equalTo(@(self.delegate.customEditIndent));
        }];
    } else {
        [self.customEditControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            StrongSelf;
            make.left.top.height.equalTo(self.cellView);
            make.width.mas_equalTo(@(self.delegate.customEditIndent));
        }];
    }
}

@end
