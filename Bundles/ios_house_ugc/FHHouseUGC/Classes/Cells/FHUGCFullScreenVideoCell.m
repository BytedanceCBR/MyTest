//
//  FHUGCFullScreenVideoCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/8/9.
//

#import "FHUGCFullScreenVideoCell.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCToolView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "TTRoute.h"
#import "TTBusinessManager+StringUtils.h"
#import "FHUGCVideoView.h"
#import "TTVFeedPlayMovie.h"
#import "TTVCellPlayMovieProtocol.h"
#import "TTVPlayVideo.h"
#import "TTVCellPlayMovie.h"
#import "TTVFeedCellMoreActionManager.h"
#import "TTVVideoArticle+Extension.h"
#import "TTUIResponderHelper.h"
#import "TTStringHelper.h"
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "JSONAdditions.h"
#import "TTVideoShareMovie.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVFeedUserOpDataSyncMessage.h"
#import "SSCommonLogic.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "UIViewAdditions.h"

#define leftMargin 15
#define rightMargin 15
#define maxLines 3

#define userInfoViewHeight 20
#define bottomViewHeight 50
#define guideViewHeight 17
#define topMargin 15

@interface FHUGCFullScreenVideoCell ()<TTUGCAsyncLabelDelegate,TTVFeedPlayMovie,TTVFeedUserOpDataSyncMessage>

@property(nonatomic ,strong) TTAsyncCornerImageView *icon;
@property(nonatomic ,strong) UILabel *userName;
@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,strong) FHUGCToolView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,assign) CGFloat videoViewheight;
@property(nonatomic ,strong) FHUGCVideoView *videoView;
@property(nonatomic ,strong) TTVFeedCellMoreActionManager *moreActionMananger;

@end

@implementation FHUGCFullScreenVideoCell

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
    UNREGISTER_MESSAGE(TTVFeedUserOpDataSyncMessage, self);
}

- (void)initUIs {
    REGISTER_MESSAGE(TTVFeedUserOpDataSyncMessage, self);
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.icon = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(15, 15, 20, 20) allowCorner:YES];
    _icon.placeholderName = @"fh_mine_avatar";
    _icon.cornerRadius = 10;
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.borderWidth = 1;
    _icon.borderColor = [UIColor themeGray6];
    [self addSubview:_icon];
    
    _icon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPersonalHomePage)];
    [_icon addGestureRecognizer:tap];
    
    self.userName = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray1]];
    [self addSubview:_userName];
    
    _userName.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPersonalHomePage)];
    [_userName addGestureRecognizer:tap1];
    
    self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.videoViewheight = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * 188.0/335.0;
    self.videoView = [[FHUGCVideoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, self.videoViewheight)];
    WeakSelf;
    _videoView.ttv_playVideoOverrideBlock = ^{
        StrongSelf;
        [self goToVideoDetail];
    };
    [self.contentView addSubview:_videoView];

    self.bottomView = [[FHUGCToolView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, bottomViewHeight)];
    [_bottomView.commentButton addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    self.videoView.ttv_shareButtonOnMovieFinishViewDidPressBlock = ^{
        StrongSelf;
        [self shareActionClicked];
    };
}

- (void)initConstraints {
    self.icon.left = leftMargin;
    self.icon.top = topMargin;
    self.icon.width = 20;
    self.icon.height = 20;
    
    self.userName.left = self.icon.right + 8;
    self.userName.top = self.icon.top + 1;
    self.userName.width = [UIScreen mainScreen].bounds.size.width - 30 - 8 - 20;
    self.userName.height = 18;
    
    self.contentLabel.top = self.icon.bottom + 8;
    self.contentLabel.left = leftMargin;
    self.contentLabel.width = [UIScreen mainScreen].bounds.size.width - 30;
    self.contentLabel.height = 0;
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(ceil([UIScreen mainScreen].bounds.size.width * 211.0/375.0));
    }];
    
    [self.videoView layoutIfNeeded];
    
    self.bottomView.left = 0;
    self.bottomView.top = self.videoView.bottom;
    self.bottomView.width = [UIScreen mainScreen].bounds.size.width;
    self.bottomView.height = bottomViewHeight;
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
    //设置头像和用户名
    FHFeedContentImageListModel *imageModel = [[FHFeedContentImageListModel alloc] init];
    imageModel.url = cellModel.user.avatarUrl;
    NSMutableArray *urlList = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        FHFeedContentImageListUrlListModel *urlListModel = [[FHFeedContentImageListUrlListModel alloc] init];
        urlListModel.url = cellModel.user.avatarUrl;
        [urlList addObject:urlListModel];
    }
    imageModel.urlList = [urlList copy];
    
    if (imageModel && imageModel.url.length > 0) {
        [self.icon tt_setImageWithURLString:imageModel.url];
    }else{
        [self.icon setImage:[UIImage imageNamed:@"fh_mine_avatar"]];
    }
    
    self.userName.text = !isEmptyString(cellModel.user.name) ? cellModel.user.name : @"用户";
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
        self.contentLabel.height = 0;
        [self.videoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.icon.mas_bottom).offset(8);
        }];
    }else{
        self.contentLabel.hidden = NO;
        self.contentLabel.height = cellModel.contentHeight;
        [self.videoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.icon.mas_bottom).offset(16 + cellModel.contentHeight);
        }];
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }
    //处理视频
    self.videoItem = cellModel.videoItem;
    self.videoView.cellEntity = self.videoItem;
    //设置底部
    [self.bottomView refreshWithdata:self.cellModel];
    
    [self layoutIfNeeded];
    self.bottomView.top = self.videoView.bottom;
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = userInfoViewHeight + topMargin;
        
        if(!isEmptyString(cellModel.content)){
            height += (cellModel.contentHeight + 8);
        }
        
        CGFloat videoViewheight = ceil([UIScreen mainScreen].bounds.size.width * 211.0/375.0);
        height += (videoViewheight + 8);
        
        height += bottomViewHeight;
        
        if(cellModel.isInsertGuideCell){
            height += guideViewHeight;
        }
        
        return height;
    }
    return 44;
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

- (void)updateBottomView {
    [self.bottomView refreshWithdata:self.cellModel];
}

- (void)willDisplay {

}

- (void)endDisplay {
    [[self playMovie] didEndDisplaying];
}

- (void)goToVideoDetail {
    TTVFeedCellSelectContext *context = [[TTVFeedCellSelectContext alloc] init];
    context.refer = 1;
    context.categoryId = self.cellModel.categoryId;
    context.clickComment = NO;
    context.enterType = @"feed_content_blank";
    context.enterFrom = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
    [self didSelectCell:context];
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
    
    if (!canOpenURL && !isEmptyString(openUrl)) {
        NSURL *url = [TTStringHelper URLWithURLString:openUrl];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            canOpenURL = YES;
            [[UIApplication sharedApplication] openURL:url];
        }
        else if ([[TTRoute sharedRoute] canOpenURL:url]) {
            
            canOpenURL = YES;
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(statParams)];
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

#pragma mark - TTUGCAsyncLabelDelegate

- (void)asyncLabel:(TTUGCAsyncLabel *)label didSelectLinkWithURL:(NSURL *)url {
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
    [self feedCollectChanged:userDigg uniqueIDStr:uniqueIDStr forKey:@"userDigg"];
}

- (void)ttv_message_feedDiggCountChanged:(int)diggCount uniqueIDStr:(NSString *)uniqueIDStr {
    [self feedCollectChanged:diggCount uniqueIDStr:uniqueIDStr forKey:@"diggCount"];
}

- (void)ttv_message_feedCommentCountChanged:(int)commentCount uniqueIDStr:(NSString *)uniqueIDStr {
    [self feedCollectChanged:commentCount uniqueIDStr:uniqueIDStr forKey:@"commentCount"];
}

- (void)ttv_message_feedCollectChanged:(BOOL)collect uniqueIDStr:(NSString *)uniqueIDStr {
    [self feedCollectChanged:collect uniqueIDStr:uniqueIDStr forKey:@"userRepin"];
}

- (void)feedCollectChanged:(int)status uniqueIDStr:(NSString *)uniqueIDStr forKey:(NSString *)key {
    if ([self.videoItem.originData.uniqueIDStr isEqualToString:uniqueIDStr]) {
        if([key isEqualToString:@"userDigg"]){
            self.cellModel.videoItem.article.userDigg = status;
            [self.bottomView updateDiggButton];
        }else if([key isEqualToString:@"diggCount"]){
            self.cellModel.videoItem.article.diggCount = status;
            [self.bottomView updateDiggButton];
        }else if([key isEqualToString:@"commentCount"]){
            self.cellModel.videoItem.article.commentCount = status;
            [self.bottomView updateCommentButton];
        }else if([key isEqualToString:@"userRepin"]){
            self.cellModel.videoItem.article.userRepin = status;
            [self.bottomView updateCollectionButton];
        }
    }
}

- (void)goToPersonalHomePage {
    if(!isEmptyString(self.cellModel.user.schema)){
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"from_page"] = self.cellModel.tracerDic[@"page_type"] ? self.cellModel.tracerDic[@"page_type"] : @"default";
        dict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:self.cellModel.user.schema];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

@end
