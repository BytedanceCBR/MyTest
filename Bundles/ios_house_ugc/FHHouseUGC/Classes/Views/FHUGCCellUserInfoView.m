//
//  FHUGCCellUserInfoView.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellUserInfoView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHFeedOperationView.h"
#import "UIButton+TTAdditions.h"
#import "FHCommunityFeedListController.h"
#import "FHHouseUGCAPI.h"
#import "ToastManager.h"
#import "FHHouseUGCHeader.h"
#import "FHUGCConfig.h"
#import "TTUIResponderHelper.h"
#import "FHUserTracker.h"
#import "TTAccountManager.h"
#import <FHUGCConfig.h>
#import "FHFeedOperationResultModel.h"
#import "TTCommentDataManager.h"
#import "TTAssetModel.h"
#import "UIViewAdditions.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellHelper.h"

@interface FHUGCCellUserInfoView()

//@property (nonatomic, assign) FHUGCPostEditState editState;
//desc文案太长了。这时候会隐藏掉 后面的 内容已编辑 部分 by xsm
@property (nonatomic, assign) BOOL isDescToLong;

@end

@implementation FHUGCCellUserInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //        self.editState = FHUGCPostEditStateNone;
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
    self.icon = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(20, 0, 40, 40) allowCorner:YES];
    //    _icon.backgroundColor = [UIColor themeGray7];
    _icon.placeholderName = @"fh_mine_avatar";
    _icon.cornerRadius = 20;
    //    _icon.imageContentMode = TTImageViewContentModeScaleAspectFill;
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    //    _icon.layer.masksToBounds = YES;
    //    _icon.layer.cornerRadius = 20;
    _icon.borderWidth = 1;
    _icon.borderColor = [UIColor themeGray6];
    
    [self addSubview:_icon];
    
    _icon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPersonalHomePage)];
    [_icon addGestureRecognizer:tap];
    
    self.userName = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self addSubview:_userName];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.hidden = YES;
    [self addSubview:_titleLabel];
    
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
    
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self addSubview:_moreBtn];
}

- (void)initConstraints {
    self.icon.top = 0;
    self.icon.left = 20;
    self.icon.width = 40;
    self.icon.height = 40;
    
    self.userName.top = 0;
    self.userName.left = self.icon.right + 10;
    self.userName.width = 100;
    self.userName.height = 22;
    
    self.titleLabel.top = 0;
    self.titleLabel.left =  20;
    self.titleLabel.width = 100;
    self.titleLabel.height = 50;
    
    
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
    self.descLabel.left = self.icon.right + 10;
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

- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel {
    //设置userInfo
    self.cellModel = cellModel;
    //图片
    FHFeedContentImageListModel *imageModel = [[FHFeedContentImageListModel alloc] init];
    imageModel.url = cellModel.user.avatarUrl;
    NSMutableArray *urlList = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        FHFeedContentImageListUrlListModel *urlListModel = [[FHFeedContentImageListUrlListModel alloc] init];
        urlListModel.url = cellModel.user.avatarUrl;
        [urlList addObject:urlListModel];
    }
    imageModel.urlList = urlList;
    
    if (imageModel && imageModel.url.length > 0) {
        [self.icon tt_setImageWithURLString:imageModel.url];
    }else{
        [self.icon setImage:[UIImage imageNamed:@"fh_mine_avatar"]];
    }
    
    self.userName.text = !isEmptyString(cellModel.user.name) ? cellModel.user.name : @"用户";
    self.userAuthLabel.hidden = self.userAuthLabel.text.length <= 0;
    [self updateDescLabel];
    [self updateEditState];
    [self updateFrame];
}

- (void)setTitleModel:(FHFeedUGCCellModel *)cellModel {
    //设置userInfo
    self.cellModel = cellModel;
    self.titleLabel.text = !isEmptyString(cellModel.originItemModel.content) ?[NSString stringWithFormat:@"问题：%@",cellModel.originItemModel.content] : @"";
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
    self.icon.hidden =  YES;
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
        _icon.userInteractionEnabled = NO;
        _userName.userInteractionEnabled = NO;
    }else{
        _icon.userInteractionEnabled = YES;
        _userName.userInteractionEnabled = YES;
    }
    
    //我的评论列表页打开
    if(pageType && [pageType isEqualToString:@"personal_comment_list"]){
        self.moreBtn.hidden = NO;
    }
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
    [self trackClickOptions];
    __weak typeof(self) wself = self;
    FHFeedOperationView *dislikeView = [[FHFeedOperationView alloc] init];
    FHFeedOperationViewModel *viewModel = [[FHFeedOperationViewModel alloc] init];
    
    dislikeView.dislikeTracerBlock = ^{
        [wself trackClickWithEvent:@"click_report" position:@"feed_report"];
    };
    
    if(self.cellModel){
        viewModel.groupID = self.cellModel.groupId;
        viewModel.userID = self.cellModel.user.userId;
        viewModel.categoryID = self.cellModel.categoryId;
    }
    
    if(self.cellModel.feedVC.operations.count > 0){
        viewModel.permission = self.cellModel.feedVC.operations;
    }
    
    if(self.cellModel.isStick){
        if(self.cellModel.stickStyle == FHFeedContentStickStyleTop || self.cellModel.stickStyle == FHFeedContentStickStyleTopAndGood){
            viewModel.isTop = YES;
        }else{
            viewModel.isTop = NO;
        }
        
        if(self.cellModel.stickStyle == FHFeedContentStickStyleGood || self.cellModel.stickStyle == FHFeedContentStickStyleTopAndGood){
            viewModel.isGood = YES;
        }else{
            viewModel.isGood = NO;
        }
    }else{
        viewModel.isGood = NO;
        viewModel.isTop = NO;
    }
    viewModel.cellType = self.cellModel.cellType;
    viewModel.hasEdit = self.cellModel.hasEdit;
    viewModel.groupSource  =self.cellModel.groupSource;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = _moreBtn.center;
    [dislikeView showAtPoint:point
                    fromView:_moreBtn
             didDislikeBlock:^(FHFeedOperationView * _Nonnull view) {
        [wself handleItemselected:view];
    }];
    
}

- (void)handleItemselected:(FHFeedOperationView *) view {
    __weak typeof(self) wself = self;
    if(view.selectdWord.type == FHFeedOperationWordTypeReport){
        //举报
        //        if(self.reportSuccessBlock){
        //            self.reportSuccessBlock();
        //        }
        
        [[ToastManager manager] showToast:@"举报成功"];
        
        NSDictionary *dic = @{
            @"cellModel":self.cellModel,
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCReportPostNotification object:nil userInfo:dic];
        
    }else if(view.selectdWord.type == FHFeedOperationWordTypeDelete){
        [self trackClickWithEvent:@"click_delete" position:@"feed_delete"];
        //二次弹窗提醒
        [self showAlert:@"是否确认要删除" cancelTitle:@"取消" confirmTitle:@"确定删除" cancelBlock:^{
            [wself trackConfirmDeletePopupClick:YES];
        } confirmBlock:^{
            [wself trackConfirmDeletePopupClick:NO];
            
            NSString *pageType = wself.cellModel.tracerDic[@"page_type"];
            //我的评论列表页打开
            if(pageType && [pageType isEqualToString:@"personal_comment_list"]){
                [wself commentDelete:wself.cellModel.groupId];
            }else{
                [wself postDelete:view.selectdWord.serverType];
            }
        }];
        [self trackConfirmPopupShow:@"confirm_delete_popup_show"];
        
    }else if(view.selectdWord.type == FHFeedOperationWordTypeTop){
        [self trackClickWithEvent:@"click_top_feed" position:@"top_feed"];
        [self showAlert:@"确认要将帖子在对应的圈子置顶？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"confirm_topfeed_popup_click" isCancel:YES];
        } confirmBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"confirm_topfeed_popup_click" isCancel:NO];
            [wself setOperationTop:YES operationCode:view.selectdWord.serverType];
        }];
        [self trackConfirmPopupShow:@"confirm_topfeed_popup_show"];
    }else if(view.selectdWord.type == FHFeedOperationWordTypeCancelTop){
        [self trackClickWithEvent:@"click_cancel_topfeed" position:@"cancel_top_feed"];
        [self showAlert:@"确认要将帖子在对应的圈子取消置顶？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"cancel_topfeed_popup_click" isCancel:YES];
        } confirmBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"cancel_topfeed_popup_click" isCancel:NO];
            [wself setOperationTop:NO operationCode:view.selectdWord.serverType];
        }];
        [self trackConfirmPopupShow:@"cancel_topfeed_popup_show"];
    }else if(view.selectdWord.type == FHFeedOperationWordTypeGood){
        [self trackClickWithEvent:@"click_essence_feed" position:@"essence_feed"];
        [self showAlert:@"确认要给帖子在对应的圈子加精？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"essence_feed_popup_click" isCancel:YES];
        } confirmBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"essence_feed_popup_click" isCancel:NO];
            [wself setOperationGood:YES operationCode:view.selectdWord.serverType];
        }];
        [self trackConfirmPopupShow:@"essence_feed_popup_show"];
    }else if(view.selectdWord.type == FHFeedOperationWordTypeCancelGood){
        [self trackClickWithEvent:@"click_cancel_essence" position:@"cancel_essence_feed"];
        [self showAlert:@"确认要给帖子在对应的圈子取消加精？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"cancel_essence_popup_click" isCancel:YES];
        } confirmBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"cancel_essence_popup_click" isCancel:NO];
            [wself setOperationGood:NO operationCode:view.selectdWord.serverType];
        }];
        [self trackConfirmPopupShow:@"cancel_essence_popup_show"];
    }else if(view.selectdWord.type == FHFeedOperationWordTypeSelfLook){
        [self trackClickWithEvent:@"click_own_see" position:@"feed_own_see"];
        [self showAlert:@"确认要将该帖子设置为自见？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"own_see_popup_click" isCancel:YES];
        } confirmBlock:^{
            [wself trackConfirmPopupClickWithEvent:@"own_see_popup_click" isCancel:NO];
            [wself setOperationSelfLook:view.selectdWord.serverType];
        }];
        [self trackConfirmPopupShow:@"own_see_popup_show"];
    } else if(view.selectdWord.type == FHFeedOperationWordTypeEdit) {
        [self gotoEditPostVC];
    } else if(view.selectdWord.type == FHFeedOperationWordTypeEditHistory) {
        [self gotoPostHistory:@"edit_record_selection"];
    }
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

- (void)showAlert:(NSString *)title cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle cancelBlock:(void(^)())cancelBlock confirmBlock:(void(^)())confirmBlock {
    __weak typeof(self) wself = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        // 点击取消按钮，调用此block
        if(cancelBlock){
            cancelBlock();
        }
    }];
    [alert addAction:cancelAction];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:confirmTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // 点击按钮，调用此block
        if(confirmBlock){
            confirmBlock();
        }
    }];
    [alert addAction:defaultAction];
    [[TTUIResponderHelper visibleTopViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)postDelete:(NSString *)operationCode {
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI postOperation:self.cellModel.groupId cellType:self.cellModel.cellType socialGroupId:self.cellModel.community.socialGroupId operationCode:operationCode enterFrom:self.cellModel.tracerDic[@"enter_from"] pageType:self.cellModel.tracerDic[@"page_type"] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        if(model && [model.status integerValue] == 0 && [model isKindOfClass:[FHFeedOperationResultModel class]]){
            if(wself.deleteCellBlock){
                wself.deleteCellBlock();
            }
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (self.cellModel.community.socialGroupId.length > 0) {
                dic[@"social_group_id"] = self.cellModel.community.socialGroupId;
            }
            if(self.cellModel){
                dic[@"cellModel"] = self.cellModel;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCDelPostNotification object:nil userInfo:dic];
        }else{
            [[ToastManager manager] showToast:@"删除失败"];
        }
    }];
}

- (void)commentDelete:(NSString *)commentID {
    __weak typeof(self) wself = self;
    [[TTCommentDataManager sharedManager] deleteCommentWithCommentID:commentID finishBlock:^(NSError *error) {
        if(!error){
            if(wself.deleteCellBlock){
                wself.deleteCellBlock();
            }
            
            //通知其他带有评论的页面去删除此条记录
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:commentID forKey:@"id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteCommentFromHomePageNotificationKey object:nil userInfo:userInfo];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if(self.cellModel){
                dic[@"cellModel"] = self.cellModel;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCDelPostNotification object:nil userInfo:dic];
        }
    }];
}

- (void)setOperationSelfLook:(NSString *)operationCode {
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI postOperation:self.cellModel.groupId cellType:self.cellModel.cellType socialGroupId:self.cellModel.community.socialGroupId operationCode:operationCode enterFrom:self.cellModel.tracerDic[@"enter_from"] pageType:self.cellModel.tracerDic[@"page_type"] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        if(model && [model.status integerValue] == 0 && [model isKindOfClass:[FHFeedOperationResultModel class]]){
            if(wself.deleteCellBlock){
                wself.deleteCellBlock();
            }
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (self.cellModel.community.socialGroupId.length > 0) {
                dic[@"social_group_id"] = self.cellModel.community.socialGroupId;
            }
            if(self.cellModel){
                dic[@"cellModel"] = self.cellModel;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCDelPostNotification object:nil userInfo:dic];
        }else{
            [[ToastManager manager] showToast:@"设置仅发帖人可见失败"];
        }
    }];
}

- (void)setOperationTop:(BOOL)isTop operationCode:(NSString *)operationCode {
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI postOperation:self.cellModel.groupId cellType:self.cellModel.cellType socialGroupId:self.cellModel.community.socialGroupId operationCode:operationCode enterFrom:self.cellModel.tracerDic[@"enter_from"] pageType:self.cellModel.tracerDic[@"page_type"] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        if(model && [model.status integerValue] == 0 && [model isKindOfClass:[FHFeedOperationResultModel class]]){
            FHFeedOperationResultModel *resultModel = (FHFeedOperationResultModel *)model;
            
            self.cellModel.isStick = resultModel.data.isStick;
            self.cellModel.stickStyle = [resultModel.data.stickStyle integerValue];
            if(!self.cellModel.contentDecoration){
                self.cellModel.contentDecoration = [[FHFeedUGCCellContentDecorationModel alloc] init];
            }
            self.cellModel.contentDecoration.url = resultModel.data.url;
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (self.cellModel.community.socialGroupId.length > 0) {
                dic[@"social_group_id"] = self.cellModel.community.socialGroupId;
            }
            if(self.cellModel){
                dic[@"cellModel"] = self.cellModel;
            }
            dic[@"isTop"] = @(isTop);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCTopPostNotification object:nil userInfo:dic];
            
            NSString *pageType = wself.cellModel.tracerDic[@"page_type"];
            if(self.cellModel.isFromDetail){
                if(isTop){
                    [[ToastManager manager] showToast:@"置顶成功"];
                }else{
                    [[ToastManager manager] showToast:@"取消置顶成功"];
                }
            }
            
        }else{
            if(isTop){
                [[ToastManager manager] showToast:@"置顶失败"];
            }else{
                [[ToastManager manager] showToast:@"取消置顶失败"];
            }
        }
    }];
}

- (void)setOperationGood:(BOOL)isGood operationCode:(NSString *)operationCode {
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI postOperation:self.cellModel.groupId cellType:self.cellModel.cellType socialGroupId:self.cellModel.community.socialGroupId operationCode:operationCode enterFrom:self.cellModel.tracerDic[@"enter_from"] pageType:self.cellModel.tracerDic[@"page_type"] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        if(model && [model.status integerValue] == 0 && [model isKindOfClass:[FHFeedOperationResultModel class]]){
            FHFeedOperationResultModel *resultModel = (FHFeedOperationResultModel *)model;
            
            self.cellModel.isStick = resultModel.data.isStick;
            self.cellModel.stickStyle = [resultModel.data.stickStyle integerValue];
            if(!self.cellModel.contentDecoration){
                self.cellModel.contentDecoration = [[FHFeedUGCCellContentDecorationModel alloc] init];
            }
            self.cellModel.contentDecoration.url = resultModel.data.url;
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (self.cellModel.community.socialGroupId.length > 0) {
                dic[@"social_group_id"] = self.cellModel.community.socialGroupId;
            }
            if(self.cellModel){
                dic[@"cellModel"] = self.cellModel;
            }
            dic[@"isGood"] = @(isGood);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCGoodPostNotification object:nil userInfo:dic];
            
            NSString *pageType = wself.cellModel.tracerDic[@"page_type"];
            if(self.cellModel.isFromDetail){
                if(isGood){
                    [[ToastManager manager] showToast:@"加精成功"];
                }else{
                    [[ToastManager manager] showToast:@"取消加精成功"];
                }
            }
            
        }else{
            if(isGood){
                [[ToastManager manager] showToast:@"加精失败"];
            }else{
                [[ToastManager manager] showToast:@"取消加精失败"];
            }
        }
    }];
}

- (void)goToPersonalHomePage {
    if (self.cellModel.user.realtorId.length > 0) {
        if (![self.cellModel.user.firstBizType isEqualToString:@"1"]) {
            NSURL *openUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_realtor_detail"]];
            NSMutableDictionary *info = @{}.mutableCopy;
            info[@"title"] = @"经纪人主页";
            info[@"realtor_id"] = self.cellModel.user.realtorId;
            NSMutableDictionary *tracerDic = self.cellModel.tracerDic.mutableCopy;
            info[@"tracer"] = tracerDic;
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
            [[TTRoute sharedRoute]openURLByViewController:openUrl userInfo:userInfo];
        }
    }else {
        if(!isEmptyString(self.cellModel.user.schema)){
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"from_page"] = self.cellModel.tracerDic[@"page_type"] ? self.cellModel.tracerDic[@"page_type"] : @"default";
            dict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            NSURL *openUrl = [NSURL URLWithString:self.cellModel.user.schema];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
        }
    }
}

- (void)gotoEditPostVC {
    if(self.cellModel.cellType != FHUGCFeedListCellTypeUGC) {
        return;
    }
    if (self.cellModel.editState == FHUGCPostEditStateSending) {
        // 编辑发送中
        [[ToastManager manager] showToast:@"帖子编辑中，请稍后"];
        return;
    }
    // 跳转发布器
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    NSMutableDictionary *tracerDict = [self.cellModel.tracerDic mutableCopy];
    tracerDict[@"click_position"] = @"edit";
    tracerDict[@"enter_type"] = @"be_null";
    TRACK_EVENT(@"click_edit", tracerDict);
    
    NSString *page_type = tracerDict[@"page_type"];
    if (page_type) {
        tracerDict[@"enter_from"] = page_type;
    }
    [tracerDict removeObjectForKey:@"click_position"];
    tracerDict[UT_ENTER_TYPE] = @"click";
    dic[TRACER_KEY] = tracerDict;
    
    // Feed 文本内容传入图文发布器
    dic[@"post_content"] = self.cellModel.content;
    dic[@"post_content_rich_span"] = self.cellModel.contentRichSpan;
    
    // Feed 图片信息传入图文发布器
    NSMutableArray *outerInputAssets = [NSMutableArray array];
    [self.cellModel.imageList enumerateObjectsUsingBlock:^(FHFeedContentImageListModel * _Nonnull imageModel, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAssetModel *outerAssetModel = [TTAssetModel modelWithImageWidth:imageModel.width height:imageModel.height url:imageModel.url uri:imageModel.uri];
        [outerInputAssets addObject:outerAssetModel];
    }];
    dic[@"outerInputAssets"] = outerInputAssets;
    
    // Feed 圈子信息传入图文发布器
    dic[@"select_group_id"] = self.cellModel.community.socialGroupId;
    dic[@"select_group_name"] = self.cellModel.community.name;
    
    // 是否是来自外部传入编辑
    dic[@"isOuterEdit"] = @(YES);
    dic[@"outerPostId"] = self.cellModel.groupId;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dic];
    NSURL *url = [NSURL URLWithString:@"sslocal://ugc_post"];
    [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:userInfo];
}

#pragma mark - 埋点

- (void)trackClickOptions {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_more";
    TRACK_EVENT(@"click_options", dict);
}

- (void)trackClickWithEvent:(NSString *)event position:(NSString *)position {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = position;
    TRACK_EVENT(event, dict);
}

- (void)trackConfirmPopupShow:(NSString *)event {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    TRACK_EVENT(event, dict);
}

- (void)trackConfirmPopupClickWithEvent:(NSString *)event isCancel:(BOOL)isCancel {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    if(isCancel){
        dict[@"click_position"] = @"cancel";
    }else{
        dict[@"click_position"] = @"confrim";
    }
    TRACK_EVENT(event, dict);
}

- (void)trackConfirmDeletePopupClick:(BOOL)isCancel {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    if(isCancel){
        dict[@"click_position"] = @"cancel";
    }else{
        dict[@"click_position"] = @"confrim_delete";
    }
    TRACK_EVENT(@"confirm_delete_popup_click", dict);
}

@end
