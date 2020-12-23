//
//  FHUGCCellUserInfoView.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellUserInfoView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UIButton+TTAdditions.h"
#import "FHURLSettings.h"
#import "FHHouseUGCHeader.h"
#import "FHUserTracker.h"
#import "TTAccountManager.h"
#import "UIViewAdditions.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHUGCMoreOperationManager.h"


@interface FHUGCCellUserInfoView()

//desc文案太长了。这时候会隐藏掉 后面的 内容已编辑 部分 by xsm
@property (nonatomic, assign) BOOL isDescToLong;
@property(nonatomic ,strong) FHUGCMoreOperationManager *moreOperationManager;

@end

@implementation FHUGCCellUserInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _moreOperationManager = [[FHUGCMoreOperationManager alloc] init];
        [self initViews];
        [self initConstraints];
        [self setupNoti];
    }
    return self;
}

- (void)setupNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditNoti:) name:@"kTTForumBeginPostEditedThreadNotification" object:nil]; // 编辑完成 显示“发送中...”
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditNoti:) name:@"kTTForumPostEditedThreadSuccessNotification" object:nil]; // 编辑发送成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditNoti:) name:@"kTTForumPostEditedThreadFailureNotification" object:nil]; // 编辑帖子发送失败
}

- (void)postEditNoti:(NSNotification *)noti {
    self.cellModel.editState = FHUGCPostEditStateNone;
    if (self.cellModel && self.cellModel.cellType == FHUGCFeedListCellTypeUGC) {
        NSString *notiName = noti.name;
        NSDictionary *userInfo = noti.userInfo;
        if (notiName.length > 0 && userInfo) {
            NSString *groupId = userInfo[@"group_id"];
            if (groupId.length >0 && [groupId isEqualToString:self.cellModel.groupId]) {
                // 同一个帖子
                if ([notiName isEqualToString:@"kTTForumBeginPostEditedThreadNotification"]) {
                    self.cellModel.editState = FHUGCPostEditStateSending;
                } else if ([notiName isEqualToString:@"kTTForumPostEditedThreadSuccessNotification"]) {
                    self.cellModel.editState = FHUGCPostEditStateDone;
                } else if ([notiName isEqualToString:@"kTTForumPostEditedThreadFailureNotification"]) {
                    self.cellModel.editState = FHUGCPostEditStateDone;
                }
            }
        }
    }
    // 是否显示
    [self updateEditState];
}

- (void)initViews {
    _avatarView = [[FHUGCAvatarView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _avatarView.placeHoldName = @"fh_mine_avatar";
    _avatarView.userInteractionEnabled = YES;
    [self addSubview:_avatarView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPersonalHomePage)];
    [_avatarView addGestureRecognizer:tap];
    
    self.userName = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self addSubview:_userName];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.hidden = YES;
    [self addSubview:_titleLabel];
    
    _questionIcon = [[UIImageView alloc]init];
    _questionIcon.contentMode = UIViewContentModeScaleAspectFit;
    _questionIcon.image = [UIImage imageNamed:@"ugc_question_icon"];
    [self addSubview:_questionIcon];
    _questionIcon.hidden = YES;
    
    _userName.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPersonalHomePage)];
    [_userName addGestureRecognizer:tap1];
    
    self.userAuthLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor colorWithHexStr:@"#929292"]];
    self.userAuthLabel.layer.borderWidth = 0.5;
    self.userAuthLabel.layer.borderColor = [UIColor colorWithHexStr:@"#d6d6d6"].CGColor;
    self.userAuthLabel.layer.cornerRadius = 2;
    self.userAuthLabel.layer.masksToBounds = YES;
    self.userAuthLabel.backgroundColor = [UIColor themeGray7];
    self.userAuthLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_userAuthLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self addSubview:_descLabel];
    
    self.editLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    self.editLabel.text = @"内容已编辑";
    self.editLabel.textAlignment = NSTextAlignmentLeft;
    self.editLabel.userInteractionEnabled = YES;
    [self addSubview:_editLabel];
    self.editLabel.hidden = YES;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editButtonOperation)];
    [self.editLabel addGestureRecognizer:tapGes];
    
    self.editingLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    self.editingLabel.text = @"发送中...";
    self.editingLabel.textAlignment = NSTextAlignmentLeft;
    self.editingLabel.userInteractionEnabled = NO;
    [self addSubview:_editingLabel];
    self.editingLabel.hidden = YES;
    
    self.essenceIcon = [[UIImageView alloc] init];
    _essenceIcon.image = [UIImage imageNamed:@"fh_ugc_wenda_essence_small_new"];
    _essenceIcon.hidden = YES;
    [self addSubview:_essenceIcon];
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self addSubview:_moreBtn];
}

- (void)showEssenceIcon {
    if(self.cellModel.isStick && (self.cellModel.stickStyle == FHFeedContentStickStyleGood || self.cellModel.stickStyle == FHFeedContentStickStyleTopAndGood)){
        self.essenceIcon.width = 24;
        self.essenceIcon.height = 16;
        self.essenceIcon.centerY = self.userName.centerY;
        if (self.userAuthLabel.hidden == YES) {
            self.essenceIcon.left = self.userName.right + 5;
        }else {
            self.essenceIcon.left = self.userAuthLabel.right + 5;
        }
        self.essenceIcon.hidden = NO;
    }else{
        self.essenceIcon.hidden = YES;
    }
}



- (void)initConstraints {
    self.avatarView.top = 0;
    self.avatarView.left = 20;
    self.avatarView.width = 40;
    self.avatarView.height = 40;
    self.userName.top = 0;
    self.userName.left = self.avatarView.right + 10;
    self.userName.width = 100;
    self.userName.height = 22;
    
    self.titleLabel.top = 0;
    self.titleLabel.left =  20;
    self.titleLabel.width = 100;
    self.titleLabel.height = 50;
    
    self.questionIcon.top = 5.4;
    self.questionIcon.left =  20;
    self.questionIcon.width = 18;
    self.questionIcon.height = 18;
    
    self.moreBtn.top = 10;
    self.moreBtn.width = 20;
    self.moreBtn.height = 20;
    self.moreBtn.left = self.width - self.moreBtn.width - 20;
    
    self.userAuthLabel.top = 3;
    self.userAuthLabel.left = self.userName.right + 4;
    self.userAuthLabel.width = 0;
    self.userAuthLabel.height = 16;
    
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 40 - 40 - 10 - 20 - 10;
    self.descLabel.top = self.userName.bottom + 1;
    self.descLabel.left = self.avatarView.right + 10;
    self.descLabel.height = 17;
    self.descLabel.width = maxWidth;
    
    self.editLabel.top = self.descLabel.top - 3;
    self.editLabel.left = self.descLabel.right + 5;
    self.editLabel.width = 60;
    self.editLabel.height = 23;
    
    self.editingLabel.top = self.descLabel.top - 3;
    self.editingLabel.left = self.descLabel.right + 5;
    self.editingLabel.width = 60;
    self.editingLabel.height = 23;
}

- (void)updateFrameFromNeighborhoodDetail {
    self.avatarView.left = 12;
    self.userName.left = self.avatarView.right + 10;
    self.descLabel.left = self.avatarView.right + 10;
    self.userAuthLabel.left = self.userName.right + 4;
}

- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel {
    //设置userInfo
    self.cellModel = cellModel;
    //图片
    [self.avatarView updateAvatarWithUGCCellModel:cellModel];

    self.userName.text = !isEmptyString(cellModel.user.name) ? cellModel.user.name : @"用户";
    [self updateUserAuth];
    [self updateDescLabel];
    [self updateEditState];
    [self updateFrame];
}

- (void)setTitleModel:(FHFeedUGCCellModel *)cellModel {
    //设置userInfo
    self.cellModel = cellModel;
    self.titleLabel.text = !isEmptyString(cellModel.originItemModel.content) ?[NSString stringWithFormat:@"    %@",cellModel.originItemModel.content] : @"";
    self.questionIcon.hidden = NO;
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, 50)];
    self.titleLabel.width = titleLabelSize.width;
    CGFloat maxTitleLabelSizeWidth = self.width - 20 - 20 - 20 -5 ;
    if(self.titleLabel.width > maxTitleLabelSizeWidth){
        self.titleLabel.width = maxTitleLabelSizeWidth;
        self.titleLabel.height = 50;
        self.moreBtn.top = 5;
    }else {
        self.titleLabel.height = 30;
        self.moreBtn.top = 5;
    }
    self.titleLabel.hidden = NO;
    self.userName.hidden = YES;
    self.avatarView.hidden =  YES;
    self.userAuthLabel.hidden = YES;
    self.descLabel.hidden = YES;
}

- (void)updateMoreBtnWithTitleType {
    [self.moreBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.moreBtn setTitle:@"查看更多" forState:UIControlStateNormal];
    [self.moreBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
    self.moreBtn.titleLabel.font = [UIFont themeFontRegular:12];
    
    self.moreBtn.width = 50;
    self.moreBtn.left = self.width - self.moreBtn.width - 20;
    
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 40 - 40 - 10 - 20 - 10 - 50;
    
    self.descLabel.width = maxWidth;
    self.editLabel.left = self.descLabel.right + 5;
    self.editingLabel.left = self.descLabel.right + 5;
}

- (void)updateFrame {
    CGSize userNameSize = [self.userName sizeThatFits:CGSizeMake(MAXFLOAT, 22)];
    self.userName.width = userNameSize.width;
    
    CGSize userAuthLabelSize = [self.userAuthLabel sizeThatFits:CGSizeMake(MAXFLOAT, 16)];
    self.userAuthLabel.width = userAuthLabelSize.width + 10;
    
    CGFloat maxUserNameWidth = self.width - 40 - 50 - (self.userAuthLabel.hidden ? 0 : (self.userAuthLabel.width + 9));
    if(!self.userAuthLabel.hidden){
        if(self.cellModel.isStick && self.cellModel.stickStyle == FHFeedContentStickStyleGood) {
            // 置顶加精移动位置
            if(self.cellModel.isInNeighbourhoodCommentsList){
                maxUserNameWidth -= 56;
            }
        }
    }
    
    if(self.userName.width > maxUserNameWidth){
        self.userName.width = maxUserNameWidth;
    }
    
    self.userAuthLabel.left = self.userName.right + 4;
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (void)setCellModel:(FHFeedUGCCellModel *)cellModel {
    _cellModel = cellModel;
    
    if(cellModel.hiddenMore){
        self.moreBtn.hidden = YES;
    }else{
        //针对一下两种类型，隐藏...按钮
        if(cellModel.cellType == FHUGCFeedListCellTypeAnswer || cellModel.cellType == FHUGCFeedListCellTypeArticleComment || cellModel.cellType == FHUGCFeedListCellTypeArticleComment2){
            BOOL hideDelete = [TTAccountManager isLogin] && [[TTAccountManager userID] isEqualToString:cellModel.user.userId];
            self.moreBtn.hidden = hideDelete;
        }else{
            self.moreBtn.hidden = NO;
        }
    }
    
    NSString *pageType = self.cellModel.tracerDic[@"page_type"];
    if(pageType && [pageType isEqualToString:@"personal_homepage_detail"]){
        //在个人主页页面 头像和名字不可点击
        _avatarView.userInteractionEnabled = NO;
        _userName.userInteractionEnabled = NO;
    }else{
        _avatarView.userInteractionEnabled = YES;
        _userName.userInteractionEnabled = YES;
    }
    
    //我的评论列表页打开
    if(pageType && [pageType isEqualToString:@"personal_comment_list"]){
        self.moreBtn.hidden = NO;
    }
}

- (void)updateUserAuth {
    self.userAuthLabel.hidden = self.userAuthLabel.text.length <= 0;
    if(self.cellModel.user.userBackgroundColor.length > 0){
        self.userAuthLabel.backgroundColor = [UIColor colorWithHexStr:self.cellModel.user.userBackgroundColor];
    }else{
        self.userAuthLabel.backgroundColor = [UIColor themeGray7];
    }
    if(self.cellModel.user.userBorderColor.length > 0){
        self.userAuthLabel.layer.borderColor = [UIColor colorWithHexStr:self.cellModel.user.userBorderColor].CGColor;
    }else{
        self.userAuthLabel.layer.borderColor = [UIColor colorWithHexStr:@"#d6d6d6"].CGColor;
    }
    if(self.cellModel.user.userFontColor.length > 0){
        self.userAuthLabel.textColor = [UIColor colorWithHexStr:self.cellModel.user.userFontColor];
    }else{
        self.userAuthLabel.textColor = [UIColor colorWithHexStr:@"#929292"];
    }
    
//    self.userAuthLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor colorWithHexStr:@"#929292"]];
//    self.userAuthLabel.layer.borderWidth = 0.5;
//    self.userAuthLabel.layer.borderColor = [UIColor colorWithHexStr:@"#d6d6d6"].CGColor;
//    self.userAuthLabel.layer.cornerRadius = 2;
//    self.userAuthLabel.layer.masksToBounds = YES;
//    self.userAuthLabel.backgroundColor = [UIColor themeGray7];
//    self.userAuthLabel.textAlignment = NSTextAlignmentCenter;
//    [self addSubview:_userAuthLabel];
}

- (void)updateDescLabel {
    self.descLabel.attributedText = self.cellModel.desc;
    CGSize size = [self.descLabel sizeThatFits:CGSizeMake(MAXFLOAT, 17)];
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 40 - 40 - 10 - 20 - 10;
    if(size.width + 15 + 60 <= maxWidth){
        self.isDescToLong = NO;
        
        self.descLabel.width = size.width;
        self.editLabel.left = self.descLabel.right + 5;
        self.editingLabel.left = self.descLabel.right + 5;
    }else{
        self.isDescToLong = YES;
        
        self.descLabel.width = maxWidth;
        self.editLabel.left = self.descLabel.right + 5;
        self.editingLabel.left = self.descLabel.right + 5;
    }
}

- (void)updateEditState {
    // 编辑按钮
    if (self.cellModel.hasEdit) {
        self.editLabel.text = @"内容已编辑";
    } else {
        self.editLabel.text = @"";
    }
    CGSize size = [self.descLabel sizeThatFits:CGSizeMake(MAXFLOAT, 23)];
    self.descLabel.width = size.width;
    // 是否显示
    if(self.isDescToLong){
        self.editLabel.hidden = YES;
        self.editingLabel.hidden = YES;
    }else{
        self.editLabel.hidden = !self.cellModel.hasEdit;
        self.editingLabel.hidden = !(self.cellModel.editState == FHUGCPostEditStateSending);
    }
}

// 编辑按钮点击
- (void)editButtonOperation {
    [self gotoPostHistory:@"content_has_edit"];
}

- (void)moreOperation {
    if (self.cellModel.cellType == FHUGCFeedListCellTypeUGCEncyclopedias) {
        NSMutableDictionary *guideDict = [NSMutableDictionary dictionary];
        guideDict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"];
        guideDict[@"page_type"] = @"f_news_recommend";
        guideDict[@"element_type"] = @"encyclopedia";
        guideDict[@"log_pb"] = self.cellModel.logPb?self.cellModel.logPb:@"br_null";
        TRACK_EVENT(@"click_more", guideDict);
        if (!isEmptyString(self.cellModel.allSchema)) {
            NSURL *openUrl = [NSURL URLWithString:self.cellModel.allSchema];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
        }

        return;
    }
    
    [self.moreOperationManager showOperationAtView:self.moreBtn withCellModel:self.cellModel];
}

// 帖子编辑历史
- (void)gotoPostHistory:(NSString *)element_from {
    if (self.cellModel.cellType == FHUGCFeedListCellTypeUGC) {
        // 帖子
        NSMutableDictionary *dict = @{}.mutableCopy;
        NSMutableDictionary *tracerDict = [self.cellModel.tracerDic mutableCopy];
        tracerDict[@"click_position"] = @"edit_record";
        tracerDict[@"enter_type"] = @"be_null";
        TRACK_EVENT(@"click_edit", tracerDict);
        
        NSString *page_type = tracerDict[@"page_type"];
        if (page_type) {
            tracerDict[@"enter_from"] = page_type;
        }
        tracerDict[@"element_from"] = element_from;
        [tracerDict removeObjectForKey:@"click_position"];
        
        dict[TRACER_KEY] = tracerDict;
        dict[@"query_id"] = self.cellModel.groupId; // 帖子id
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_post_history"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)goToPersonalHomePage {
    if (self.cellModel.user.realtorId.length > 0) {
        if (![self.cellModel.user.firstBizType isEqualToString:@"1"]) {
            NSDictionary *fhSettings = [self fhSettings];
            BOOL openNewRealtor =  [fhSettings btd_boolValueForKey:@"f_new_realtor_detail"];
            if (openNewRealtor) {
                  NSURL *openUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_realtor_detail"]];
                          NSMutableDictionary *info = @{}.mutableCopy;
                          info[@"title"] = @"经纪人主页";
                          info[@"realtor_id"] = self.cellModel.user.realtorId;
                          NSMutableDictionary *tracerDic = self.cellModel.tracerDic.mutableCopy;
                          info[@"tracer"] = tracerDic;
                          TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
                          [[TTRoute sharedRoute]openURLByViewController:openUrl userInfo:userInfo];
            }else {
                NSError *parseError = nil;
                NSString *reportParams = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.cellModel.tracerDic options:0 error:&parseError];
                if (!parseError) {
                    reportParams = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
                NSMutableDictionary *info = @{}.mutableCopy;
                NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
                NSURL *openUrl = [NSURL URLWithString:@"sslocal://realtor_detail"];
                NSString *jumpUrl = [NSString stringWithFormat:@"%@/f100/client/realtor_detail?realtor_id=%@&report_params=%@",host,self.cellModel.user.realtorId,reportParams ? : @""];
                info[@"url"] = jumpUrl;
                info[@"title"] = @"经纪人主页";
                info[@"realtor_id"] = self.cellModel.user.realtorId;
                info[@"trace"] = self.cellModel.tracerDic;
                    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
                    [[TTRoute sharedRoute]openURLByViewController:openUrl userInfo:userInfo];
            }
        }
    }else {
        NSString *schema = nil;
        if(!isEmptyString(self.cellModel.user.schema)){
            schema = self.cellModel.user.schema;
        }else if(!isEmptyString(self.cellModel.user.userId)){
            schema = [NSString stringWithFormat:@"sslocal://profile?uid=%@", self.cellModel.user.userId];
        }
        
        if(!isEmptyString(schema)){
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"from_page"] = self.cellModel.tracerDic[@"page_type"] ? self.cellModel.tracerDic[@"page_type"] : @"default";
            dict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            NSURL *openUrl = [NSURL URLWithString:schema];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
        }
    }
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

@end
