//
//  FHUGCCellUserInfoView.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellUserInfoView.h"
#import <Masonry.h>
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
#import <TTCommentDataManager.h>
#import <TTAssetModel.h>

@implementation FHUGCCellUserInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.icon = [[UIImageView alloc] init];
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = 20;
    [self addSubview:_icon];
    
    _icon.userInteractionEnabled = YES;
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPersonalHomePage)];
    [_icon addGestureRecognizer:tap];
    
    self.userName = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self addSubview:_userName];
    
    _userName.userInteractionEnabled = YES;
     UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPersonalHomePage)];
    [_userName addGestureRecognizer:tap1];
    
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
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self addSubview:_moreBtn];
}

- (void)initConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(20);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-20);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.width.mas_lessThanOrEqualTo([UIScreen mainScreen].bounds.size.width - 100);
        make.height.mas_equalTo(22);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.icon);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.height.mas_equalTo(17);
    }];
    
    [self.editLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.icon);
        make.left.mas_equalTo(self.descLabel.mas_right).offset(10);
        make.right.mas_lessThanOrEqualTo(self.moreBtn.mas_left).offset(-10);
        make.height.mas_equalTo(17);
    }];
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
    
    // 编辑按钮
    self.editLabel.hidden = !cellModel.hasEdit;
    if (cellModel.hasEdit) {
        self.editLabel.text = @"内容已编辑";
    } else {
        self.editLabel.text = @"";
    }
    [self.editLabel sizeToFit];
}

// 编辑按钮点击
- (void)editButtonOperation {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // add by zyk 添加入口参数
    dict[@"social_group_id"] = self.cellModel.community.socialGroupId ?: @"";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_post_history"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)moreOperation {
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
        [[ToastManager manager] showToast:@"编辑历史按钮点击了"];
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
    if(self.cellModel.user.schema){
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"from_page"] = self.cellModel.tracerDic[@"page_type"] ? self.cellModel.tracerDic[@"page_type"] : @"default";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:self.cellModel.user.schema];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)gotoEditPostVC {
    
    if(self.cellModel.cellType != FHUGCFeedListCellTypeUGC) {
        [[ToastManager manager] showToast:@"编辑按钮点击了, 但不是贴子类型, 不支持编辑"];
        return;
    }
    
    // 跳转发布器
//    NSMutableDictionary *tracerDict = @{}.mutableCopy;
//    tracerDict[@"element_type"] = @"feed_publisher";
//    tracerDict[@"page_type"] = @"community_group_detail";
//    [FHUserTracker writeEvent:@"click_publisher" params:tracerDict];
//
//    NSMutableDictionary *traceParam = @{}.mutableCopy;
//    NSMutableDictionary *dict = @{}.mutableCopy;
//    traceParam[@"page_type"] = @"feed_publisher";
//    traceParam[@"enter_from"] = @"community_group_detail";
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
//    dic[@"select_group_id"] = self.data.socialGroupId;
//    dic[@"select_group_name"] = self.data.socialGroupName;
//    dic[TRACER_KEY] = traceParam;
//    dic[VCTITLE_KEY] = @"发帖";
    
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
