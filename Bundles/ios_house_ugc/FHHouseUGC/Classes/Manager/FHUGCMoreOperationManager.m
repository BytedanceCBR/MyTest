//
//  FHUGCMoreOperationManager.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/23.
//

#import "FHUGCMoreOperationManager.h"
#import "FHFeedOperationView.h"
#import "FHUserTracker.h"
#import "ToastManager.h"
#import "FHUGCConfig.h"
#import "TTUIResponderHelper.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedOperationResultModel.h"
#import "TTCommentDataManager.h"
#import "TTAssetModel.h"

@interface FHUGCMoreOperationManager ()

@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHUGCMoreOperationManager

- (void)showOperationAtView:(UIView *)view withCellModel:(FHFeedUGCCellModel *)cellModel {
    self.cellModel = cellModel;
    
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
    CGPoint point = view.center;
    [dislikeView showAtPoint:point
                    fromView:view
             didDislikeBlock:^(FHFeedOperationView * _Nonnull view) {
        [wself handleItemselected:view];
    }];
}

- (void)handleItemselected:(FHFeedOperationView *) view {
    __weak typeof(self) wself = self;
    if(view.selectdWord.type == FHFeedOperationWordTypeReport){
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
    }else if(view.selectdWord.type == FHFeedOperationWordTypeShield){
        [[ToastManager manager] showToast:@"将减少推荐类似内容"];
    }else if(view.selectdWord.type == FHFeedOperationWordTypeBlackList){
        [[ToastManager manager] showToast:@"将减少推荐类似内容"];
    }
}

- (void)showAlert:(NSString *)title cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle cancelBlock:(void(^)(void))cancelBlock confirmBlock:(void(^)(void))confirmBlock {
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
    [FHHouseUGCAPI postOperation:self.cellModel.groupId cellType:self.cellModel.cellType socialGroupId:self.cellModel.community.socialGroupId operationCode:operationCode enterFrom:self.cellModel.tracerDic[@"enter_from"] pageType:self.cellModel.tracerDic[@"page_type"] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        //已经审核通过的问题删除就返回这个
        if(model && [model.status integerValue] == 2001){
            [[ToastManager manager] showToast:(model.message ?: @"删除失败")];
            return;
        }
        
        if(model && [model.status integerValue] == 0 && [model isKindOfClass:[FHFeedOperationResultModel class]]){
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
    [[TTCommentDataManager sharedManager] deleteCommentWithCommentID:commentID finishBlock:^(NSError *error) {
        if(!error){
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
    [FHHouseUGCAPI postOperation:self.cellModel.groupId cellType:self.cellModel.cellType socialGroupId:self.cellModel.community.socialGroupId operationCode:operationCode enterFrom:self.cellModel.tracerDic[@"enter_from"] pageType:self.cellModel.tracerDic[@"page_type"] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        if(model && [model.status integerValue] == 0 && [model isKindOfClass:[FHFeedOperationResultModel class]]){
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
        }else{
            if(isGood){
                [[ToastManager manager] showToast:@"加精失败"];
            }else{
                [[ToastManager manager] showToast:@"取消加精失败"];
            }
        }
    }];
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
        TTAssetModel *outerAssetModel = [TTAssetModel modelWithImageWidth:[imageModel.width integerValue] height:[imageModel.height integerValue] url:imageModel.url uri:imageModel.uri];
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
