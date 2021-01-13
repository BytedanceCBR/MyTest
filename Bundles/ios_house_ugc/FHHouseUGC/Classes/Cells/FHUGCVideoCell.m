//
//  FHUGCVideoCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/5.
//

#import "FHUGCVideoCell.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
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
#import "FHVideoLayout.h"

#define leftMargin 20
#define rightMargin 20
#define maxLines 3

#define userInfoViewHeight 40
#define bottomViewHeight 45
#define guideViewHeight 17
#define topMargin 20

@interface FHUGCVideoCell ()<TTUGCAsyncLabelDelegate,TTVFeedPlayMovie,TTVFeedUserOpDataSyncMessage>

@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
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
    UNREGISTER_MESSAGE(TTVFeedUserOpDataSyncMessage, self);
}

- (void)initUIs {
    REGISTER_MESSAGE(TTVFeedUserOpDataSyncMessage, self);
    [self initViews];
}

- (void)initViews {
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, userInfoViewHeight)];
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.videoViewheight = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * 188.0/335.0;
    self.videoView = [[FHUGCVideoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, self.videoViewheight)];
    _videoView.layer.masksToBounds = YES;
    _videoView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _videoView.layer.borderWidth = 0.5;
    _videoView.layer.cornerRadius = 4;
    WeakSelf;
    self.videoView.ttv_shareButtonOnMovieFinishViewDidPressBlock = ^{
        StrongSelf;
        [self shareActionClicked];
    };
    [self.contentView addSubview:_videoView];

    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, bottomViewHeight)];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)updateConstraints:(FHBaseLayout *)layout {
    if (![layout isKindOfClass:[FHVideoLayout class]]) {
        return;
    }
    
    FHVideoLayout *cellLayout = (FHVideoLayout *)layout;
    
    [FHLayoutItem updateView:self.userInfoView withLayout:cellLayout.userInfoViewLayout];
    [FHLayoutItem updateView:self.contentLabel withLayout:cellLayout.contentLabelLayout];
    [FHLayoutItem updateView:self.videoView withLayout:cellLayout.videoViewLayout];
    [FHLayoutItem updateView:self.bottomView withLayout:cellLayout.bottomViewLayout];
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
    [self.userInfoView refreshWithData:cellModel];
    //设置底部
    [self.bottomView refreshWithData:cellModel];
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
    }else{
        self.contentLabel.hidden = NO;
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }
    //处理视频
    self.videoItem = cellModel.videoItem;
    self.videoView.cellEntity = self.videoItem;
    
    WeakSelf;
    if(cellModel.isVideoJumpDetail){
        _videoView.userInteractionEnabled = YES;
        _videoView.ttv_playButtonClickedBlock = ^{
            StrongSelf;
            [self playVideoDidClicked];
        };
    }else{
        _videoView.userInteractionEnabled = NO;
        _videoView.ttv_playButtonClickedBlock = nil;
    }
    
    [self updateCommentButton];
    [self updateDiggButton];
    
    [self updateConstraints:cellModel.layout];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        return cellModel.layout.height;
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

- (void)updateCommentButton {
    NSInteger  commentCount = self.videoItem.article.commentCount;
    if(commentCount == 0){
        [self.bottomView.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    }else{
        [self.bottomView.commentBtn setTitle:[TTBusinessManager formatCommentCount:commentCount] forState:UIControlStateNormal];
    }
}

- (void)updateDiggButton {
    NSString *diggCount = self.cellModel.diggCount;
    [self.bottomView updateLikeState:diggCount userDigg:self.cellModel.userDigg];
}

- (void)willDisplay {

}

- (void)endDisplay {
    [[self playMovie] didEndDisplaying];
}

- (void)didSelectCell:(TTVFeedCellSelectContext *)context {
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
    ssOpenWebView([NSURL btd_URLWithString:article.articleURL], nil, topController.navigationController, !!(adid), parameters);
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
    [statParams setValue:[article.rawAdDataString btd_jsonValueDecoded] forKey:@"raw_ad_data"];
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
    NSString *reportParams = [tracerDic btd_jsonStringEncoded];
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
            
            [statParams setValue:shareMovie forKey:@"movie_shareMovie"];

            [self cell_detachMovieView];
        }
        
        if (detailURL) {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL btd_URLWithString:detailURL] userInfo:TTRouteUserInfoWithDict(statParams)];
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
        NSURL *url = [NSURL btd_URLWithString:openUrl];
        
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

- (void)playVideoDidClicked {
    if(self.delegate && [self.delegate respondsToSelector:@selector(didVideoClicked:cell:)]){
        [self.delegate didVideoClicked:self.cellModel cell:self];
    }
}

#pragma mark - TTVFeedUserOpDataSyncMessage

- (void)ttv_message_feedDiggChanged:(BOOL)userDigg uniqueIDStr:(NSString *)uniqueIDStr {
//    [self feedCollectChanged:userDigg uniqueIDStr:uniqueIDStr forKey:@"userDigg"];
}

- (void)ttv_message_feedDiggCountChanged:(int)diggCount uniqueIDStr:(NSString *)uniqueIDStr {
//    [self feedCollectChanged:diggCount uniqueIDStr:uniqueIDStr forKey:@"diggCount"];
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
            [self updateDiggButton];
        }else if([key isEqualToString:@"diggCount"]){
            self.cellModel.videoItem.article.diggCount = status;
            [self updateDiggButton];
        }else if([key isEqualToString:@"commentCount"]){
            self.cellModel.videoItem.article.commentCount = status;
            [self updateCommentButton];
        }else if([key isEqualToString:@"userRepin"]){
            self.cellModel.videoItem.article.userRepin = status;
        }
    }
}

@end
