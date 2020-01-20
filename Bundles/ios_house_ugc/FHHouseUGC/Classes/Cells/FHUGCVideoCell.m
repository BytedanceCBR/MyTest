//
//  FHUGCVideoCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/5.
//

#import "FHUGCVideoCell.h"
#import <UIImageView+BDWebImage.h>
#import "FHUGCCellHeaderView.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "FHUGCCellOriginItemView.h"
#import "TTRoute.h"
#import <TTBusinessManager+StringUtils.h>
#import "FHUGCVideoView.h"
#import <TTVFeedPlayMovie.h>
#import <TTVCellPlayMovieProtocol.h>
#import <TTVPlayVideo.h>
#import <TTVCellPlayMovie.h>
#import <TTVFeedCellMoreActionManager.h>
#import <TTVVideoArticle+Extension.h>
#import <TTUIResponderHelper.h>
#import <TTStringHelper.h>
#import <TTVFeedCellSelectContext.h>
#import <TTVFeedItem+TTVArticleProtocolSupport.h>
#import <JSONAdditions.h>
#import <TTVideoShareMovie.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTVFeedUserOpDataSyncMessage.h>
#import <SSCommonLogic.h>
#import <TTVFeedItem+TTVConvertToArticle.h>

#define leftMargin 20
#define rightMargin 20
#define maxLines 3

#define userInfoViewHeight 40
#define bottomViewHeight 49
#define guideViewHeight 17
#define topMargin 20

@interface FHUGCVideoCell ()<TTUGCAttributedLabelDelegate,TTVFeedPlayMovie,TTVFeedUserOpDataSyncMessage>

@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,assign) CGFloat videoViewheight;
@property(nonatomic ,strong) FHUGCVideoView *videoView;
@property(nonatomic ,strong) TTVFeedCellMoreActionManager *moreActionMananger;

@end

@implementation FHUGCVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)dealloc {
//    UNREGISTER_MESSAGE(TTVFeedUserOpDataSyncMessage, self);
}

- (void)initUIs {
//    REGISTER_MESSAGE(TTVFeedUserOpDataSyncMessage, self);
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    NSDictionary *linkAttributes = @{
                                     NSForegroundColorAttributeName : [UIColor themeRed3],
                                     NSFontAttributeName : [UIFont themeFontRegular:16]
                                     };
    self.contentLabel.linkAttributes = linkAttributes;
    self.contentLabel.activeLinkAttributes = linkAttributes;
    self.contentLabel.inactiveLinkAttributes = linkAttributes;
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.videoViewheight = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * 188.0/335.0;
    self.videoView = [[FHUGCVideoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, self.videoViewheight)];
    _videoView.layer.masksToBounds = YES;
    _videoView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _videoView.layer.borderWidth = 0.5;
    _videoView.layer.cornerRadius = 4;
    [self.contentView addSubview:_videoView];

    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectZero];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
    
    __weak typeof(self) wself = self;
    self.videoView.ttv_shareButtonOnMovieFinishViewDidPressBlock = ^{
        [wself shareActionClicked];
    };
}

- (void)initConstraints {
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        make.height.mas_equalTo(0);
    }];
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        make.height.mas_equalTo(([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * 188.0/335.0);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoView.mas_bottom).offset(10);
        make.height.mas_equalTo(49);
        make.left.right.mas_equalTo(self.contentView);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    
    if(self.currentData == data && !cellModel.ischanged){
        return;
    }
    
    self.currentData = data;
    self.cellModel = cellModel;
    //设置userInfo
    self.userInfoView.cellModel = cellModel;
    self.userInfoView.userName.text = cellModel.user.name;
    [self.userInfoView updateDescLabel];
    [self.userInfoView updateEditState];
    [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    //设置底部
    self.bottomView.cellModel = cellModel;
    
    BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
    self.bottomView.position.text = cellModel.community.name;
    [self.bottomView showPositionView:showCommunity];
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.videoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        }];
    }else{
        self.contentLabel.hidden = NO;
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(cellModel.contentHeight);
        }];
        [self.videoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(20 + cellModel.contentHeight);
            make.height.mas_equalTo(self.videoViewheight);
        }];
        [FHUGCCellHelper setRichContent:self.contentLabel model:cellModel];
    }
    //处理视频
    self.videoItem = cellModel.videoItem;
    self.videoView.cellEntity = self.videoItem;
    
    [self updateCommentButton];
    [self updateDiggButton];
    
    [self showGuideView];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = cellModel.contentHeight + userInfoViewHeight + bottomViewHeight + topMargin + 30;
        
        if(isEmptyString(cellModel.content)){
            height -= 10;
        }
        
        CGFloat videoViewheight = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * 188.0/335.0;
        height += videoViewheight;
        
        if(cellModel.isInsertGuideCell){
            height += guideViewHeight;
        }
        
        return height;
    }
    return 44;
}

- (void)showGuideView {
    if(_cellModel.isInsertGuideCell){
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(66);
        }];
    }else{
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(49);
        }];
    }
}

- (void)closeGuideView {
    self.cellModel.isInsertGuideCell = NO;
    [self.cellModel.tableView beginUpdates];
    
    [self showGuideView];
    self.bottomView.cellModel = self.cellModel;
    
    [self setNeedsUpdateConstraints];
    
    [self.cellModel.tableView endUpdates];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeFeedGuide:)]){
        [self.delegate closeFeedGuide:self.cellModel];
    }
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

// 评论点击
- (void)commentBtnClick {
    if(self.delegate && [self.delegate respondsToSelector:@selector(commentClicked:cell:)]){
        [self.delegate commentClicked:self.cellModel cell:self];
    }
}

//进入圈子详情
- (void)goToCommunityDetail:(UITapGestureRecognizer *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToCommunityDetail:)]){
        [self.delegate goToCommunityDetail:self.cellModel];
    }
}

- (void)updateCommentButton {
    NSInteger  commentCount = self.videoItem.article.commentCount;
    if(commentCount == 0){
        [self.bottomView.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    }else{
        [self.bottomView.commentBtn setTitle:[TTBusinessManager formatCommentCount:commentCount] forState:UIControlStateNormal];
    }
}

- (void)updateDiggButton {
    NSString *diggCount = [NSString stringWithFormat:@"%d",self.videoItem.article.diggCount];
    [self.bottomView updateLikeState:diggCount userDigg:(self.videoItem.article.userDigg ? @"1" : @"0")];
}

- (void)willDisplay {

}

- (void)endDisplay {
    [[self playMovie] didEndDisplaying];
}

- (void)didSelectCell:(TTVFeedCellSelectContext *)context {
    [self.videoView.playMovie removeCommodityView];
    
    TTVVideoArticle *article = self.videoItem.article;
    if ((article.groupFlags & kVideoArticleGroupFlagsOpenUseWebViewInList) > 0 && !isEmptyString(article.articleURL)) {
        [self openWebviewWithItem:self.videoItem context:context];
    }else{
        [self openVideoDetailWithItem:self.videoItem context:context];
    }
}

- (void)openWebviewWithItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context {
    UIViewController *topController = [TTUIResponderHelper correctTopViewControllerFor:self];
    TTVVideoArticle *article = item.article;
    NSString *adid = isEmptyString(article.adId) ? nil : [NSString stringWithFormat:@"%@", article.adId];
    NSString *logExtra = article.logExtra;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setValue:adid forKey:SSViewControllerBaseConditionADIDKey];
    [parameters setValue:logExtra forKey:@"log_extra"];
    ssOpenWebView([TTStringHelper URLWithURLString:article.articleURL], nil, topController.navigationController, !!(adid), parameters);
}

- (void)openVideoDetailWithItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context {
    NSString *categoryID = item.categoryId;
    TTVVideoArticle *article = item.article;
    NSString *adid = isEmptyString(article.adId) ? nil : [NSString stringWithFormat:@"%@", article.adId];
    NSString *logExtra = article.logExtra;
    NSString *group_id = article.groupId > 0 ? @(article.groupId).stringValue : nil;
    NSString *item_id = article.itemId > 0 ? @(article.itemId).stringValue : nil;
    int64_t aggrType = article.aggrType;
    NSString *openUrl = nil;
    if (isEmptyString(openUrl)) {
        openUrl = article.openURL;
    }
//    NewsGoDetailFromSource fromSource = [[self class] goDetailFromSouce:categoryID];
    NSMutableDictionary *statParams = [NSMutableDictionary dictionary];
    [statParams setValue:categoryID forKey:@"kNewsDetailViewConditionCategoryIDKey"];
//    [statParams setValue:@(fromSource) forKey:kNewsGoDetailFromSourceKey];
    
    if (context.clickComment) {
        [statParams setValue:@(YES) forKey:@"showcomment"];
    }
    
    [statParams setValue:group_id forKey:@"groupid"];
    [statParams setValue:group_id forKey:@"group_id"];
    [statParams setValue:item_id forKey:@"item_id"];
    [statParams setValue:@(aggrType) forKey:@"aggr_type"];
    [statParams setValue:item.originData.logPbDic forKey:@"log_pb"];
    [statParams setValue:[article.rawAdDataString tt_JSONValue] forKey:@"raw_ad_data"];
    [statParams setValue:logExtra forKey:@"log_extra"];
    [statParams setValue:item.originData forKey:@"video_feed"];
    [statParams setValue:context.feedListViewController forKey:@"video_feedListViewController"];
    
    NSMutableDictionary *tracerDic = [self.cellModel.tracerDic mutableCopy];
    tracerDic[@"page_type"] = @"video_detail";
    if(context.enterType){
        tracerDic[@"enter_type"] = context.enterType;
    }
    if(context.enterFrom){
        tracerDic[@"enter_from"] = context.enterFrom;
    }
    NSString *reportParams = [tracerDic tt_JSONRepresentation];
    if(reportParams){
        [statParams setValue:reportParams forKey:@"report_params"];
    }
    
    //打开详情页：优先判断openURL是否可以用外部schema打开，否则判断内部schema
    BOOL canOpenURL = [self openSchemaWithOpenUrl:openUrl article:article adid:adid logExtra:logExtra statParams:statParams];
    if (canOpenURL) {
        return;
    }
    if(!canOpenURL) {
        NSString *detailURL = nil;
        if (group_id) {
            detailURL = [NSString stringWithFormat:@"sslocal://detail?groupid=%@", group_id];
        }
        // 如果是视频cell且正在播放，则detach视频并传入详情页
            
        NSNumber *videoType = @(article.videoDetailInfo.videoType);
        [statParams setValue:videoType forKey:@"video_type"];
        
        if ([self canContinuePlayMovieOnView:self withArticle:article]) {
            
            TTVideoShareMovie *shareMovie = [[TTVideoShareMovie alloc] init];
            shareMovie.movieView = [self cell_movieView];

            TTVPlayVideo *movieView = (TTVPlayVideo *)shareMovie.movieView;
            
            [statParams setValue:shareMovie forKey:@"movie_shareMovie"];
//            if ([cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
//                if ([item.originData couldContinueAutoPlay]) {
//                    shareMovie.isAutoPlaying = YES;
//                    [[TTVAutoPlayManager sharedManager] cacheAutoPlayingCell:(id<TTVAutoPlayingCell>)cell movie:movieView fromView:cell.tableView];
//                    TTVAutoPlayModel *model = [cell ttv_autoPlayModel];
//                    TTVPlayVideo *movieView = nil;
//                    if ([shareMovie.movieView isKindOfClass:[TTVPlayVideo class]]) {
//                        movieView = (TTVPlayVideo *)shareMovie.movieView;
//                    }
//                    if (!movieView && [shareMovie.playerControl.movieView isKindOfClass:[TTVPlayVideo class]]) {
//                        movieView = (TTVPlayVideo *)shareMovie.playerControl.movieView;
//                    }
//                    [[TTVAutoPlayManager sharedManager] trackForClickFeedAutoPlay:model movieView:movieView];
//                }
//            }
            [self cell_detachMovieView];
        }
        
        if (detailURL) {
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:detailURL] userInfo:TTRouteUserInfoWithDict(statParams)];
        }
    }
}

- (BOOL)openSchemaWithOpenUrl:(NSString *)openUrl article:(TTVVideoArticle *)article adid:(NSString *)adid logExtra:(NSString *)logExtra statParams:(NSMutableDictionary *)statParams
{
    //打开详情页：优先判断openURL是否可以用外部schema打开，否则判断内部schema
    BOOL canOpenURL = NO;
    
    NSMutableDictionary *applinkParams = [NSMutableDictionary dictionary];
    [applinkParams setValue:logExtra forKey:@"log_extra"];
    
//    if (!isEmptyString(adid) && !article.hasVideo) {
//        if ([TTAppLinkManager dealWithWebURL:article.articleURL openURL:openUrl sourceTag:@"embeded_ad" value:adid extraDic:applinkParams]) {
//            //针对广告并且能够通过sdk打开的情况
//            canOpenURL = YES;
//        }
//    }
    
    if (!canOpenURL && !isEmptyString(openUrl)) {
        NSURL *url = [TTStringHelper URLWithURLString:openUrl];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            canOpenURL = YES;
            [[UIApplication sharedApplication] openURL:url];
        }
        else if ([[TTRoute sharedRoute] canOpenURL:url]) {
            
            canOpenURL = YES;
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(statParams)];
            //针对广告不能通过sdk打开，但是传的有内部schema的情况
//            if(isEmptyString(adid)){
//                wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", adid, nil, applinkParams);
//            }
        }
    }
    return canOpenURL;
}

- (BOOL)canContinuePlayMovieOnView:(id <TTVFeedPlayMovie> )view withArticle:(TTVVideoArticle *)article
{
    if ([article isVideoSubject] && [view respondsToSelector:@selector(cell_movieView)] && [view cell_hasMovieView]) {
        return ([view cell_isPaused] || [view cell_isPlayingFinished] || [view cell_isPlaying]);
    }
    return NO;
}

#pragma mark - TTUGCAttributedLabelDelegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if([url.absoluteString isEqualToString:defaultTruncationLinkURLString]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(lookAllLinkClicked:cell:)]){
            [self.delegate lookAllLinkClicked:self.cellModel cell:self];
        }
    } else {
        if (url) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(gotoLinkUrl:url:)]){
                [self.delegate gotoLinkUrl:self.cellModel url:url];
            }
        }
    }
}

#pragma mark - TTVFeedPlayMovie

- (UIView *)movie {
    if (self.videoView == nil) {
        return nil;
    }
    return [[self playMovie] currentMovieView];
}

- (NSObject<TTVCellPlayMovieProtocol> *)playMovie {
    if (self.videoView == nil) {
        return nil;
    }
    return self.videoView.playMovie;
}

- (UIView *)cell_movieView {
    if (self.videoView == nil) {
        return nil;
    }
    return [self movie];
}

- (BOOL)cell_hasMovieView {
    if (self.videoView == nil) {
        return NO;
    }
    return [self movie] != nil;
}

- (BOOL)cell_isPlayingMovie
{
    if (self.videoView == nil) {
        return NO;
    }
    if ([self movie] && [self playMovie]) {
        return YES;
    }
    return NO;
}

- (BOOL)cell_isPlaying
{
    return [[self playMovie] isPlaying];
}

- (BOOL)cell_isPaused
{
    return [[self playMovie] isPaused];
}

- (BOOL)cell_isPlayingFinished
{
    return [[self playMovie] isPlayingFinished];
}

- (void)cell_attachMovieView:(UIView *)movieView {
    if (self.videoView == nil) {
        return;
    }
    if ([movieView isKindOfClass:[TTVPlayVideo class]]) {
        UIView *logo = self.videoView.logo;
        movieView.frame = logo.bounds;
        [logo addSubview:movieView];
        if (self.videoView.playMovie == nil && [self.videoItem isKindOfClass:[TTVFeedListItem class]]) {
            [self.videoView playButtonClicked];
            FHFeedContentModel *model = (FHFeedContentModel *)self.videoItem.originData;
            [[self playMovie] setVideoTitle:model.title];
            [self playMovie].logo = logo;
        }
        [self.videoView.playMovie attachMovieView:(TTVPlayVideo *)movieView];
        // attatch的时候，禁用动画
        self.videoView.ttv_movieViewWillMoveToSuperViewBlock(movieView.superview, NO);
    }
}

- (id)cell_detachMovieView {
    if (self.videoView == nil) {
        return nil;
    }
    return [self.videoView.playMovie detachMovieView];
}

- (void)shareActionClicked {
    [self _shareAction];
}

- (void)_shareAction {
    self.moreActionMananger = [[TTVFeedCellMoreActionManager alloc] init];
    self.moreActionMananger.categoryId = self.videoItem.categoryId;
    self.moreActionMananger.responder = self;
    self.moreActionMananger.cellEntity = self.videoItem.originData;
    self.moreActionMananger.playVideo = self.videoItem.playVideo;
    __weak typeof(self) wself = self;
    self.moreActionMananger.didClickActivityItemAndQueryProcess = ^BOOL(NSString *type) {
        return NO;
    };
    self.moreActionMananger.shareToRepostBlock = ^(TTActivityType type) {

    };
    [self.moreActionMananger shareButtonClickedWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.videoItem.originData] activityAction:^(NSString *type) {
        
    }];

}

#pragma mark - TTVFeedUserOpDataSyncMessage

- (void)ttv_message_feedDiggChanged:(BOOL)userDigg uniqueIDStr:(NSString *)uniqueIDStr {
    id<TTVArticleProtocol> article = nil;
    [self feedCollectChanged:userDigg uniqueIDStr:uniqueIDStr forKey:@keypath(article, userDigg)];
}

- (void)ttv_message_feedDiggCountChanged:(int)diggCount uniqueIDStr:(NSString *)uniqueIDStr {
    id<TTVArticleProtocol> article = nil;
    [self feedCollectChanged:diggCount uniqueIDStr:uniqueIDStr forKey:@keypath(article, diggCount)];
}

- (void)ttv_message_feedCommentCountChanged:(int)commentCount uniqueIDStr:(NSString *)uniqueIDStr {
    id<TTVArticleProtocol> article = nil;
    [self feedCollectChanged:commentCount uniqueIDStr:uniqueIDStr forKey:@keypath(article, commentCount)];
}

- (void)feedCollectChanged:(int)status uniqueIDStr:(NSString *)uniqueIDStr forKey:(NSString *)key {
    if ([self.videoItem.originData.uniqueIDStr isEqualToString:uniqueIDStr]) {
        [self.videoItem.originData setValue:@(status) forKey:key];
        TTVFeedListItem *itemA = self.videoItem;
        [itemA.originData.savedConvertedArticle setValue:@(status) forKey:key];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int64_t fixedgroupID = [[SSCommonLogic fixStringTypeGroupID:itemA.originData.groupModel.groupID] longLongValue];
            NSString *primaryID = [Article primaryIDByUniqueID:fixedgroupID itemID:itemA.originData.groupModel.itemID adID:itemA.originData.adIDStr];
            Article *cachedArticle = [Article objectForPrimaryKey:primaryID];
            if (cachedArticle) {
                [cachedArticle setValue:@(status) forKey:key];
                [cachedArticle save];
            }
        });
        if([key isEqualToString:@"diggCount"] || [key isEqualToString:@"userDigg"]){
            [self updateDiggButton];
        }if([key isEqualToString:@"commentCount"]){
            [self updateCommentButton];
        }
    }
}

@end
