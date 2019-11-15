//
//  FHUGCCellBottomView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellBottomView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCommonApi.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "UIButton+TTAdditions.h"
#import "FHUserTracker.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <TTBusinessManager+StringUtils.h>
#import "TTMessageCenter.h"
#import "TTVideoArticleService+Action.h"
#import "TTVideoArticleServiceMessage.h"
#import "TTVFeedUserOpDataSyncMessage.h"

@interface FHUGCCellBottomView ()

//@property(nonatomic ,strong) UIView *likeView;
//@property(nonatomic ,strong) UIImageView *likeImageView;
//@property(nonatomic ,strong) UILabel *likeLabel;
@property (nonatomic, copy)  NSString *saveDiggGroupId;
@property(nonatomic ,strong) UIImageView *positionImageView;
@property (nonatomic, assign)   FHDetailDiggType       diggType;

@end

@implementation FHUGCCellBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
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
    
    self.positionView = [[UIView alloc] init];
    _positionView.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];
    _positionView.layer.masksToBounds= YES;
    _positionView.layer.cornerRadius = 4;
    _positionView.userInteractionEnabled = YES;
    _positionView.hidden = YES;
    [self addSubview:_positionView];
    
    self.positionImageView = [[UIImageView alloc] init];
    _positionImageView.image = [UIImage imageNamed:@"fh_ugc_community_icon"];
    [self.positionView addSubview:_positionImageView];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:13] textColor:[UIColor themeRed3]];
    [_position sizeToFit];
    [_positionView addSubview:_position];
    
    self.commentBtn = [[UIButton alloc] init];
    _commentBtn.opaque = YES;
    _commentBtn.imageView.contentMode = UIViewContentModeCenter;
    [_commentBtn setImage:ICON_FONT_IMG(20, @"\U0000e699", nil) forState:UIControlStateNormal];// @"fh_ugc_comment"
    [_commentBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    _commentBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    _commentBtn.titleLabel.layer.masksToBounds = YES;
    _commentBtn.titleLabel.backgroundColor = [UIColor whiteColor];
    [self addSubview:_commentBtn];
    
    self.likeBtn = [[UIButton alloc] init];
    _likeBtn.imageView.contentMode = UIViewContentModeCenter;
    [_likeBtn setImage:ICON_FONT_IMG(20, @"\U0000e69c", nil) forState:UIControlStateNormal];// @"fh_ugc_comment"
    [_likeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    _likeBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_likeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    _likeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_likeBtn addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
    _likeBtn.titleLabel.layer.masksToBounds = YES;
    _likeBtn.titleLabel.backgroundColor = [UIColor whiteColor];
    [self addSubview:_likeBtn];
    
//    self.likeView = [[UIView alloc] init];
//    _likeView.userInteractionEnabled = YES;
//    [self addSubview:_likeView];
//
//    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(like:)];
//    [self.likeView addGestureRecognizer:singleTap];
//
//    self.likeImageView = [[UIImageView alloc] init];
//    _likeImageView.image = ICON_FONT_IMG(20, @"\U0000e69c", nil);//@"fh_ugc_like"
//    [self.likeView addSubview:_likeImageView];
//
//    self.likeLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
//    [_likeLabel sizeToFit];
//    [self.likeView addSubview:_likeLabel];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self addSubview:_bottomSepView];
    
    self.diggType = FHDetailDiggTypeTHREAD;
}

- (FHUGCFeedGuideView *)guideView {
    if(!_guideView){
        _guideView = [[FHUGCFeedGuideView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 42)];
        [self addSubview:_guideView];
    }
    return _guideView;
}

- (void)initConstraints {
    [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(24);
    }];
    
    [self.positionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionView).offset(6);
        make.centerY.mas_equalTo(self.positionView);
        make.width.height.mas_equalTo(12);
    }];
    
    [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionImageView.mas_right).offset(2);
        make.right.mas_equalTo(self.positionView).offset(-6);
        make.centerY.mas_equalTo(self.positionView);
        make.height.mas_equalTo(18);
    }];
    
//    [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self);
//        make.left.mas_equalTo(self.commentBtn.mas_left).offset(-80);
//        make.width.mas_equalTo(70);
//        make.height.mas_equalTo(24);
//    }];
//
//    [self.likeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.likeView).offset(10);
//        make.centerY.mas_equalTo(self.likeView);
//        make.width.height.mas_equalTo(20);
//    }];
//
//    [self.likeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.mas_equalTo(self.likeView);
//        make.left.mas_equalTo(self.likeImageView.mas_right).offset(3);
//        make.right.mas_equalTo(self.likeView);
//    }];
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(2);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(20);
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(2);
        make.right.mas_equalTo(self.likeBtn.mas_left).offset(-20);
        make.height.mas_equalTo(20);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.positionView.mas_bottom).offset(20);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(5);
    }];
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
            default:
                self.diggType = FHDetailDiggTypeTHREAD;
                break;
        }
    }
    //设置是否显示引导
    if(cellModel.isInsertGuideCell){
        self.guideView.hidden = NO;
        [self.guideView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.positionView.mas_bottom);
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(42);
        }];
    }else{
        self.guideView.hidden = YES;
    }
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)showPositionView:(BOOL)isShow {
    self.positionView.hidden = !isShow;
}

- (void)updateLikeState:(NSString *)diggCount userDigg:(NSString *)userDigg {
    NSInteger count = [diggCount integerValue];
    if(count == 0){
//        self.likeLabel.text = @"赞";
        [self.likeBtn setTitle:@"赞" forState:UIControlStateNormal];
    }else{
//        self.likeLabel.text = [TTBusinessManager formatCommentCount: count];
        [self.likeBtn setTitle:[TTBusinessManager formatCommentCount: count] forState:UIControlStateNormal];
    }
    if([userDigg boolValue]){
//        self.likeImageView.image = ICON_FONT_IMG(20, @"\U0000e6b1", [UIColor themeRed1]);//"fh_ugc_like_selected"
//        self.likeLabel.textColor = [UIColor themeRed1];
        
        [self.likeBtn setImage:ICON_FONT_IMG(20, @"\U0000e6b1", [UIColor themeRed1]) forState:UIControlStateNormal];
        [self.likeBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        
    }else{
//        self.likeImageView.image =  ICON_FONT_IMG(20, @"\U0000e69c", nil);//@"fh_ugc_like"
//        self.likeLabel.textColor = [UIColor themeGray1];
        
        [self.likeBtn setImage:ICON_FONT_IMG(20, @"\U0000e69c", nil) forState:UIControlStateNormal];
        [self.likeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    }
    //补充逻辑，如果用户状态为已点赞，但是点赞数为零，这时候默认点赞数设为1
    if([userDigg boolValue] && count == 0){
//        self.likeLabel.text = @"1";
        [self.likeBtn setTitle:@"1" forState:UIControlStateNormal];
    }
}

// 点赞
- (void)like:(UITapGestureRecognizer *)sender {
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
    NSString *enter_from = self.cellModel.tracerDic[@"enter_from"];
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
    //    // 刷新UI
    NSInteger user_digg = [self.cellModel.userDigg integerValue] == 0 ? 1 : 0;

    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"enter_from"] = self.cellModel.tracerDic[@"enter_from"];
    dict[@"element_from"] = self.cellModel.tracerDic[@"element_from"];
    dict[@"page_type"] = self.cellModel.tracerDic[@"page_type"];
    [FHCommonApi requestCommonDigg:self.cellModel.groupId groupType:self.diggType action:user_digg tracerParam:dict completion:nil];
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
                if(diggCount > 0){
                    diggCount = diggCount - 1;
                }
            }else{
                //点赞
                self.cellModel.userDigg = @"1";
                diggCount = diggCount + 1;
            }
            
            self.cellModel.diggCount = [NSString stringWithFormat:@"%i",diggCount];
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
        NSInteger comment_conut = [userInfo[@"comment_conut"] integerValue];
        NSString *groupId = userInfo[@"group_id"];
        if (groupId.length > 0 && [groupId isEqualToString:self.cellModel.groupId]) {
            NSInteger commentCount = comment_conut;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(commentCount == 0){
                    [self.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
                }else{
                    [self.commentBtn setTitle:[TTBusinessManager formatCommentCount:commentCount] forState:UIControlStateNormal];
                }
            });
        }
    }
}

- (void)trackClickLike {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    NSInteger user_digg = [self.cellModel.userDigg integerValue];
    if(user_digg == 1){
        dict[@"click_position"] = @"feed_dislike";
        TRACK_EVENT(@"click_dislike", dict);
    }else{
        dict[@"click_position"] = @"feed_like";
        TRACK_EVENT(@"click_like", dict);
    }
}

@end
