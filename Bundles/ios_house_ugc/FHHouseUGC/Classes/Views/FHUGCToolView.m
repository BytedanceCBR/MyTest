//
//  FHUGCToolView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/8/9.
//

#import "FHUGCToolView.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"
#import "TTBusinessManager+StringUtils.h"
#import "FHCommonApi.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "FHUserTracker.h"
#import "TTAccountLoginManager.h"
#import "TTVideoArticleService+Action.h"
#import "TTVideoArticleServiceMessage.h"
#import "TTVFeedUserOpDataSyncMessage.h"
#import "TTVFeedCellMoreActionManager.h"
#import "TTVVideoDetailCollectService.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"

@interface FHUGCToolView ()<TTVVideoDetailCollectServiceDelegate>

@property(nonatomic , strong) UIView *bottomLine;

@property(nonatomic, assign) FHDetailDiggType diggType;
@property(nonatomic, copy) NSString *saveDiggGroupId;
@property(nonatomic, strong) TTVFeedCellMoreActionManager *moreActionMananger;
@property(nonatomic, strong) TTVVideoDetailCollectService *collectService;

@end

@implementation FHUGCToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initNotification];
    }
    return self;
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStateChange:) name:@"kFHUGCDiggStateChangeNotification" object:nil];
    // 评论数变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCountChange:) name:@"kPostMessageFinishedNotification" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    
    self.shareButton = [self buttonWithFrame:CGRectMake(0, 0, self.bounds.size.width/4, self.bounds.size.height) title:@"分享" imageName:@"fh_ugc_share" action:@selector(shareBtnClicked)];
    [self addSubview:_shareButton];
    
    self.collectionButton = [self buttonWithFrame:CGRectMake(self.bounds.size.width/4, 0, self.bounds.size.width/4, self.bounds.size.height) title:@"收藏" imageName:@"fh_ugc_favorite_normal" action:@selector(collectionBtnClicked)];
    [self addSubview:_collectionButton];
    
    self.commentButton = [self buttonWithFrame:CGRectMake(2 * self.bounds.size.width/4, 0, self.bounds.size.width/4, self.bounds.size.height) title:@"评论" imageName:@"fh_ugc_comment_icon" action:nil];
    [self addSubview:_commentButton];
    
    self.diggButton = [self buttonWithFrame:CGRectMake(3 * self.bounds.size.width/4, 0, self.bounds.size.width/4, self.bounds.size.height) title:@"赞" imageName:@"fh_ugc_digg_normal" action:@selector(diggBtnClicked)];
    [self addSubview:_diggButton];
    
    self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(15, self.bounds.size.height - 0.5, self.bounds.size.width - 30, 0.5)];
    _bottomLine.backgroundColor = [UIColor themeGray7];
    [self addSubview:_bottomLine];
    
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title imageName:(NSString *)imageName action:(SEL)action{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    btn.imageView.contentMode = UIViewContentModeCenter;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont themeFontRegular:12];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    if(action){
        [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    btn.titleLabel.layer.masksToBounds = YES;
    btn.titleLabel.backgroundColor = [UIColor whiteColor];
  
    return btn;
}

- (void)setCellModel:(FHFeedUGCCellModel *)cellModel {
    _cellModel = cellModel;
    if (cellModel) {
        switch (cellModel.cellType) {
                case FHUGCFeedListCellTypeArticle:
                    self.diggType = FHDetailDiggTypeITEM;
                    if (cellModel.hasVideo) {
                        self.diggType = FHDetailDiggTypeVIDEO;
                    }
                break;
                case FHUGCFeedListCellTypeAnswer:
                    self.diggType = FHDetailDiggTypeANSWER;
                break;
                case FHUGCFeedListCellTypeQuestion:
                    self.diggType = FHDetailDiggTypeQUESTION;
                break;
                case FHUGCFeedListCellTypeArticleComment:
                    self.diggType = FHDetailDiggTypeCOMMENT;
                break;
                case FHUGCFeedListCellTypeArticleComment2:
                    self.diggType = FHDetailDiggTypeCOMMENT;
                break;
                case FHUGCFeedListCellTypeUGC:
                    self.diggType = FHDetailDiggTypeTHREAD;
                break;
                case FHUGCFeedListCellTypeUGCSmallVideo:
                    self.diggType = FHDetailDiggTypeSMALLVIDEO;
                break;
                case FHUGCFeedListCellTypeUGCVoteInfo:
                    self.diggType = FHDetailDiggTypeVote;
                    break;
            default:
                self.diggType = FHDetailDiggTypeTHREAD;
                break;
        }
    }
}

- (void)refreshWithdata:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        
        if(self.cellModel == cellModel && !cellModel.ischanged){
            return;
        }
        
        self.cellModel = cellModel;
        
        [self updateCollectionButton];
        [self updateCommentButton];
        [self updateDiggButton];
        
    }
}

- (void)updateCollectionButton {
    BOOL userRepin = self.cellModel.videoItem.article.userRepin;
    if(userRepin){
        [self.collectionButton setTitle:@"已收藏" forState:UIControlStateNormal];
        [self.collectionButton setImage:[UIImage imageNamed:@"fh_ugc_favorite_selected"] forState:UIControlStateNormal];
        [self.collectionButton setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    }else{
        [self.collectionButton setTitle:@"收藏" forState:UIControlStateNormal];
        [self.collectionButton setImage:[UIImage imageNamed:@"fh_ugc_favorite_normal"] forState:UIControlStateNormal];
        [self.collectionButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    }
}

- (void)updateCommentButton {
    NSInteger commentCount = self.cellModel.videoItem.article.commentCount;
    if(commentCount == 0){
        [self.commentButton setTitle:@"评论" forState:UIControlStateNormal];
    }else{
        [self.commentButton setTitle:[TTBusinessManager formatCommentCount:commentCount] forState:UIControlStateNormal];
    }
}

- (void)updateDiggButton {
    NSString *diggCount = [NSString stringWithFormat:@"%lld",self.cellModel.videoItem.article.diggCount];
    [self updateLikeState:diggCount userDigg:(self.cellModel.videoItem.article.userDigg ? @"1" : @"0")];
}

- (void)updateLikeState:(NSString *)diggCount userDigg:(NSString *)userDigg {
    NSInteger count = [diggCount integerValue];
    if(count == 0){
        [self.diggButton setTitle:@"赞" forState:UIControlStateNormal];
    }else{
        [self.diggButton setTitle:[TTBusinessManager formatCommentCount: count] forState:UIControlStateNormal];
    }
    if([userDigg boolValue]){
        [self.diggButton setImage:[UIImage imageNamed:@"fh_ugc_digg_selected"] forState:UIControlStateNormal];
        [self.diggButton setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
        
    }else{
        [self.diggButton setImage:[UIImage imageNamed:@"fh_ugc_digg_normal"] forState:UIControlStateNormal];
        [self.diggButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    }
    //补充逻辑，如果用户状态为已点赞，但是点赞数为零，这时候默认点赞数设为1
    if([userDigg boolValue] && count == 0){
        [self.diggButton setTitle:@"1" forState:UIControlStateNormal];
    }
}

- (void)shareBtnClicked {
    [self addClickShareLog];
    self.moreActionMananger = [[TTVFeedCellMoreActionManager alloc] init];
    self.moreActionMananger.categoryId = self.cellModel.videoItem.categoryId;
    self.moreActionMananger.responder = self;
    self.moreActionMananger.extraDic = self.cellModel.tracerDic;
    self.moreActionMananger.cellEntity = self.cellModel.videoItem.originData;
    self.moreActionMananger.playVideo = self.cellModel.videoItem.playVideo;
    self.moreActionMananger.didClickActivityItemAndQueryProcess = ^BOOL(NSString *type) {
        return NO;
    };
    self.moreActionMananger.shareToRepostBlock = ^(TTActivityType type) {

    };
    [self.moreActionMananger shareButtonClickedWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellModel.videoItem.originData] activityAction:^(NSString *type) {
        
    }];
}

- (void)collectionBtnClicked {// 网络
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    [self goToCollection];
}

- (void)goToCollection {
    if (_collectService == nil) {
        _collectService = [[TTVVideoDetailCollectService alloc] init];
    }
//    _collectService.originalArticle = [self protocoledArticle];
    
//    TTDetailModel *detailModel = [TTDetailModel new];
//    [detailModel setVideoArticle:self.cellModel.videoItem.article];
    
    _collectService.originalArticle = [self.cellModel.videoFeedItem ttv_convertedArticle];
    _collectService.gdExtJSONDict = self.cellModel.tracerDic;
    _collectService.delegate = self;
    [_collectService changeFavoriteButtonClicked:1 viewController:self withButtonSeat:@""];
}

- (void)diggBtnClicked {
    // 网络
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    [self gotoDigg];
}

// 去点赞
- (void)gotoDigg {
    self.saveDiggGroupId = self.cellModel.groupId;
    if ([TTAccountManager isLogin]) {
        [self p_digg];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *enter_from = self.cellModel.tracerDic[UT_PAGE_TYPE];
    if (enter_from.length <= 0) {
        enter_from = @"be_null";
    }
    [params setObject:enter_from forKey:@"enter_from"];
    [params setObject:@"feed_like" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                [wSelf p_digg];
            }
        }
    }];
}

- (void)p_digg {
    // 防止重用时数据改变
    if (![self.saveDiggGroupId isEqualToString:self.cellModel.groupId]) {
        return;
    }
    
    [self trackClickLike];
    //刷新UI
    NSInteger user_digg = [self.cellModel.userDigg integerValue] == 0 ? 1 : 0;

    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"enter_from"] = self.cellModel.tracerDic[@"enter_from"];
    dict[@"element_from"] = self.cellModel.tracerDic[@"element_from"];
    dict[@"page_type"] = self.cellModel.tracerDic[@"page_type"];
    [FHCommonApi requestCommonDigg:self.cellModel.groupId groupType:self.diggType action:user_digg tracerParam:dict completion:nil];
}

- (void)trackClickLike {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    NSInteger user_digg = [self.cellModel.userDigg integerValue];
    if(user_digg == 1){
        TRACK_EVENT(@"click_dislike", dict);
    }else{
        TRACK_EVENT(@"click_like", dict);
    }
}

- (void)likeStateChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    if(userInfo){
        NSInteger user_digg = [userInfo[@"action"] integerValue];
        NSInteger diggCount = [self.cellModel.diggCount integerValue];
        NSInteger groupType = [userInfo[@"group_type"] integerValue];
        NSString *groupId = userInfo[@"group_id"];
        
        if(groupType == self.diggType && [groupId isEqualToString:self.cellModel.groupId]){
            // 刷新UI
            if(user_digg == 0){
                //取消点赞
                self.cellModel.userDigg = @"0";
                if(diggCount > 0 && self.cellModel.lastUserDiggType != FHFeedUGCDiggType_Decrease){
                    diggCount = diggCount - 1;
                    self.cellModel.lastUserDiggType = FHFeedUGCDiggType_Decrease;
                }
            }else{
                //点赞
                self.cellModel.userDigg = @"1";
                if(self.cellModel.lastUserDiggType != FHFeedUGCDiggType_Increase) {
                    diggCount = diggCount + 1;
                    self.cellModel.lastUserDiggType = FHFeedUGCDiggType_Increase;
                }
            }
            
            self.cellModel.diggCount = [NSString stringWithFormat:@"%li",(long)diggCount];
            
            if (self.cellModel.hasVideo) {
                // 视频点赞
                self.cellModel.videoFeedItem.article.diggCount = diggCount;
                self.cellModel.videoFeedItem.article.userDigg = user_digg;
                NSString *unique_id = self.cellModel.groupId;
                SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggChanged:uniqueIDStr:), ttv_message_feedDiggChanged:(user_digg == 1) uniqueIDStr:unique_id);
                SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggCountChanged:uniqueIDStr:), ttv_message_feedDiggCountChanged:diggCount uniqueIDStr:unique_id);
            }
            [self updateLikeState:self.cellModel.diggCount userDigg:self.cellModel.userDigg];
        }
    }
}

// 评论数变化
- (void)commentCountChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    if(userInfo){
        if(![[userInfo allKeys] containsObject:@"comment_conut"]){
            return;
        }
        NSInteger comment_conut = [userInfo[@"comment_conut"] integerValue];
        NSString *groupId = userInfo[@"group_id"];
        if (groupId.length > 0 && [groupId isEqualToString:self.cellModel.groupId]) {
            self.cellModel.videoItem.article.commentCount = comment_conut;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateCommentButton];
            });
        }
    }
}

#pragma mark - TTVVideoDetailCollectServiceDelegate

- (void)detailCollectService:(TTVVideoDetailCollectService *)collectService showTipMsg:(NSString *)tipMsg icon:(UIImage *)image buttonSeat:(NSString *)btnSeat
{
    [[ToastManager manager] showToast:tipMsg];
    [self updateDiggButton];
}

#pragma mark - 埋点

- (void)addClickShareLog {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    TRACK_EVENT(@"click_share", dict);
}

@end
