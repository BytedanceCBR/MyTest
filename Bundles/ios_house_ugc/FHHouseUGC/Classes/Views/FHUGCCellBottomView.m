//
//  FHUGCCellBottomView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellBottomView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCommonApi.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "UIButton+TTAdditions.h"
#import "FHUserTracker.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "TTBusinessManager+StringUtils.h"
#import "TTMessageCenter.h"
#import "TTVideoArticleService+Action.h"
#import "TTVideoArticleServiceMessage.h"
#import "TTVFeedUserOpDataSyncMessage.h"

@interface FHUGCCellBottomView ()

@property (nonatomic, copy)  NSString *saveDiggGroupId;
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
    _positionView.backgroundColor = [UIColor themeOrange2];
    _positionView.layer.masksToBounds= YES;
    _positionView.layer.cornerRadius = 4;
    _positionView.userInteractionEnabled = YES;
    _positionView.hidden = YES;
    [self addSubview:_positionView];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:13] textColor:[UIColor themeOrange1]];
    _position.layer.masksToBounds = YES;
    _position.backgroundColor = [UIColor themeOrange2];
    [_position sizeToFit];
    [_position setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_position setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_positionView addSubview:_position];
    
    self.commentBtn = [[UIButton alloc] init];
    _commentBtn.opaque = YES;
    _commentBtn.imageView.contentMode = UIViewContentModeCenter;
    [_commentBtn setImage:ICON_FONT_IMG(24, @"\U0000e699", [UIColor themeGray1]) forState:UIControlStateNormal];// @"fh_ugc_comment"
    [_commentBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    _commentBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    _commentBtn.titleLabel.layer.masksToBounds = YES;
    _commentBtn.titleLabel.backgroundColor = [UIColor whiteColor];
    [_commentBtn sizeToFit];
    [self addSubview:_commentBtn];
    
    self.likeBtn = [[UIButton alloc] init];
    _likeBtn.imageView.contentMode = UIViewContentModeCenter;
    [_likeBtn setImage:ICON_FONT_IMG(24, @"\U0000e69c", [UIColor themeGray1]) forState:UIControlStateNormal];// @"fh_ugc_comment"
    [_likeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    _likeBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_likeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    _likeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_likeBtn addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
    _likeBtn.titleLabel.layer.masksToBounds = YES;
    _likeBtn.titleLabel.backgroundColor = [UIColor whiteColor];
    [_likeBtn sizeToFit];
    [self addSubview:_likeBtn];

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
//    [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self).offset(20);
//        make.top.mas_equalTo(self);
//        make.height.mas_equalTo(24);
//    }];
//
//    [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.positionView).offset(6);
//        make.right.mas_equalTo(self.positionView).offset(-6);
//        make.centerY.mas_equalTo(self.positionView);
//        make.height.mas_equalTo(18);
//    }];
//
//    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self).offset(2);
//        make.right.mas_equalTo(self).offset(-20);
//        make.height.mas_equalTo(24);
//    }];
//
//    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self).offset(2);
//        make.right.mas_equalTo(self.likeBtn.mas_left).offset(-20);
//        make.height.mas_equalTo(24);
//    }];
//
//    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.positionView.mas_bottom).offset(20);
//        make.left.mas_equalTo(self).offset(0);
//        make.right.mas_equalTo(self).offset(0);
//        make.height.mas_equalTo(5);
//    }];
    
    self.positionView.top = 0;
    self.positionView.left = 20;
    self.positionView.width = 0;
    self.positionView.height = 24;
        
    self.commentBtn.top = 2;
    self.commentBtn.height = 24;
    self.commentBtn.left = self.width - 20 - self.likeBtn.width - 20 - self.commentBtn.width;

    self.likeBtn.left = self.commentBtn.right + 20;
    self.likeBtn.top = 2;
    self.likeBtn.height = 24;
        
    self.bottomSepView.left = 0;
    self.bottomSepView.top = self.positionView.bottom + 20;
    self.bottomSepView.height = 5;
    self.bottomSepView.width = [UIScreen mainScreen].bounds.size.width;
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
    //设置是否显示引导
    if(cellModel.isInsertGuideCell){
        self.guideView.hidden = NO;
        self.guideView.top = self.positionView.bottom;
        self.guideView.left = 0;
        self.guideView.width = self.bounds.size.width;
        self.guideView.height = 42;
//        [self.guideView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.positionView.mas_bottom);
//            make.left.right.mas_equalTo(self);
//            make.height.mas_equalTo(42);
//        }];
    }else{
        self.guideView.hidden = YES;
    }
    
    self.bottomSepView.left = cellModel.bottomLineLeftMargin;
    self.bottomSepView.top = self.positionView.bottom + 20;
    self.bottomSepView.height = cellModel.bottomLineHeight;
    self.bottomSepView.width = self.bounds.size.width - cellModel.bottomLineLeftMargin - cellModel.bottomLineRightMargin;
    
//    [self.bottomSepView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.positionView.mas_bottom).offset(20);
//        make.left.mas_equalTo(self).offset(cellModel.bottomLineLeftMargin);
//        make.right.mas_equalTo(self).offset(-cellModel.bottomLineRightMargin);
//        make.height.mas_equalTo(cellModel.bottomLineHeight);
//    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)showPositionView:(BOOL)isShow {
    self.positionView.hidden = !isShow;
    
    if(isShow){
        self.position.top = 3;
        self.position.height = 18;
        self.position.left = 6;
        [self.position sizeToFit];
        CGFloat labelWidth = self.position.width;
        
        self.positionView.left = 20;
        self.positionView.width = labelWidth + 12;
        self.positionView.height = 24;
    }
}

- (void)updateFrame {
    [self.commentBtn sizeToFit];
    [self.likeBtn sizeToFit];
    if (self.paddingLike >0 && self.marginRight >0) {
        self.commentBtn.left = self.width - self.marginRight - self.likeBtn.width - self.paddingLike - self.commentBtn.width;
        self.likeBtn.left = self.commentBtn.right + self.paddingLike;
    }else {
       self.commentBtn.left = self.width - 20 - self.likeBtn.width - 20 - self.commentBtn.width;
        self.likeBtn.left = self.commentBtn.right + 20;
    }
    
    
}

- (void)updateLikeState:(NSString *)diggCount userDigg:(NSString *)userDigg {
    NSInteger count = [diggCount integerValue];
    if(count == 0){
        [self.likeBtn setTitle:@"赞" forState:UIControlStateNormal];
    }else{
        [self.likeBtn setTitle:[TTBusinessManager formatCommentCount: count] forState:UIControlStateNormal];
    }
    if([userDigg boolValue]){
        [self.likeBtn setImage:ICON_FONT_IMG(24, @"\U0000e6b1", [UIColor themeOrange4]) forState:UIControlStateNormal];
        [self.likeBtn setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
        
    }else{
        [self.likeBtn setImage:ICON_FONT_IMG(24, @"\U0000e69c", [UIColor themeGray1]) forState:UIControlStateNormal];
        [self.likeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    }
    //补充逻辑，如果用户状态为已点赞，但是点赞数为零，这时候默认点赞数设为1
    if([userDigg boolValue] && count == 0){
        [self.likeBtn setTitle:@"1" forState:UIControlStateNormal];
    }
    [self updateFrame];
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
                [self updateFrame];
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
