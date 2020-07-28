//
//  FHUGCCellBottomView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHArticleCellBottomView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHFeedOperationView.h"
#import "UIButton+TTAdditions.h"
#import "FHCommunityFeedListController.h"
#import "FHUserTracker.h"
#import "TTUIResponderHelper.h"
#import "FHHouseUGCAPI.h"
#import "FHUGCConfig.h"
#import "FHFeedOperationResultModel.h"
#import "ToastManager.h"
#import "UIViewAdditions.h"

@interface FHArticleCellBottomView ()

@property(nonatomic ,strong) UIView *bottomSepView;

@end

@implementation FHArticleCellBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
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
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray4]];
    _descLabel.layer.masksToBounds = YES;
    _descLabel.backgroundColor = [UIColor whiteColor];
    [self addSubview:_descLabel];
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self addSubview:_moreBtn];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self addSubview:_bottomSepView];
}

- (FHUGCFeedGuideView *)guideView {
    if(!_guideView){
        _guideView = [[FHUGCFeedGuideView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 42)];
        [self addSubview:_guideView];
    }
    return _guideView;
}

- (void)initConstraints {
    self.positionView.top = 0;
    self.positionView.left = 20;
    self.positionView.width = 0;
    self.positionView.height = 24;
    
    self.descLabel.left = 20;
    self.descLabel.centerY = self.positionView.centerY;
    self.descLabel.height = 24;
    self.descLabel.width = [UIScreen mainScreen].bounds.size.width - 40 - 20 - 20;
    
    self.moreBtn.left = self.descLabel.right + 20;
    self.moreBtn.top = 2;
    self.moreBtn.height = 20;
    self.moreBtn.width = 20;

    self.bottomSepView.left = 0;
    self.bottomSepView.top = self.positionView.bottom + 10;
    self.bottomSepView.height = 5;
    self.bottomSepView.width = [UIScreen mainScreen].bounds.size.width;
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)setCellModel:(FHFeedUGCCellModel *)cellModel {
    _cellModel = cellModel;
    //设置是否显示引导
    if(cellModel.isInsertGuideCell){
        self.guideView.hidden = NO;
        self.guideView.top = self.positionView.bottom;
        self.guideView.left = 0;
        self.guideView.width = [UIScreen mainScreen].bounds.size.width;
        self.guideView.height = 42;
    }else{
        self.guideView.hidden = YES;
    }
    
    self.moreBtn.hidden = cellModel.hiddenMore;
    
    self.bottomSepView.left = cellModel.bottomLineLeftMargin;
    self.bottomSepView.top = self.positionView.bottom + 10;
    self.bottomSepView.height = cellModel.bottomLineHeight;
    self.bottomSepView.width = [UIScreen mainScreen].bounds.size.width - cellModel.bottomLineLeftMargin - cellModel.bottomLineRightMargin;
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
        
        self.descLabel.left = self.positionView.right + 6;
        self.descLabel.centerY = self.positionView.centerY;
        self.descLabel.height = 24;
        self.descLabel.width = [UIScreen mainScreen].bounds.size.width - 40 - 20 - 20 - self.positionView.width - 6;
    }else{
        self.descLabel.left = 20;
        self.descLabel.centerY = self.positionView.centerY;
        self.descLabel.width = [UIScreen mainScreen].bounds.size.width - 40 - 20 - 20;
    }
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
//        if(self.deleteCellBlock){
//            self.deleteCellBlock();
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
            [wself postDelete:view.selectdWord.serverType];
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
        
        //已经审核通过的问题删除就返回这个
        if(model && [model.status integerValue] == 2001){
            [[ToastManager manager] showToast:(model.message ?: @"删除失败")];
            return;
        }
        
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
        }else{
            if(isGood){
                [[ToastManager manager] showToast:@"加精失败"];
            }else{
                [[ToastManager manager] showToast:@"取消加精失败"];
            }
        }
    }];
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
