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
    
    self.userName = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self addSubview:_userName];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self addSubview:_descLabel];
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
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
        make.right.mas_equalTo(self.moreBtn.mas_left).offset(-20);
        make.height.mas_equalTo(22);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.icon);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.moreBtn.mas_left).offset(-20);
        make.height.mas_equalTo(17);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)setCellModel:(FHFeedUGCCellModel *)cellModel {
    _cellModel = cellModel;
    //针对一下两种类型，隐藏...按钮
    if(cellModel.cellType == FHUGCFeedListCellTypeAnswer || cellModel.cellType == FHUGCFeedListCellTypeArticleComment){
        BOOL hideDelete = [TTAccountManager isLogin] && [[TTAccountManager userID] isEqualToString:cellModel.user.userId];
        self.moreBtn.hidden = hideDelete;
    }else{
        self.moreBtn.hidden = NO;
    }
}

- (void)moreOperation {
    [self trackClickOptions];
    __weak typeof(self) wself = self;
    FHFeedOperationView *dislikeView = [[FHFeedOperationView alloc] init];
    FHFeedOperationViewModel *viewModel = [[FHFeedOperationViewModel alloc] init];

    dislikeView.dislikeTracerBlock = ^{
        [wself trackClickReport];
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
        if(self.reportSuccessBlock){
            self.reportSuccessBlock();
        }
    
        NSDictionary *dic = @{
                              @"cellModel":self.cellModel,
                              };
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCReportPostNotification object:nil userInfo:dic];
        
    }else if(view.selectdWord.type == FHFeedOperationWordTypeDelete){
        [self trackClickDelete];
        //二次弹窗提醒
        [self showAlert:@"是否确认要删除" cancelTitle:@"取消" confirmTitle:@"确定删除" cancelBlock:^{
            [wself trackConfirmDeletePopupClick:YES];
        } confirmBlock:^{
            [wself trackConfirmDeletePopupClick:NO];
            [wself postDelete];
        }];
        [self trackConfirmDeletePopupShow];
        
    }else if(view.selectdWord.type == FHFeedOperationWordTypeTop){
        [self showAlert:@"确认要将帖子在对应的小区圈置顶？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{

        } confirmBlock:^{
            [wself setOperationTop:YES];
        }];
    }else if(view.selectdWord.type == FHFeedOperationWordTypeCancelTop){
        [self showAlert:@"确认要将帖子在对应的小区圈取消置顶？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            
        } confirmBlock:^{
            [wself setOperationTop:NO];
        }];
    }else if(view.selectdWord.type == FHFeedOperationWordTypeGood){
        [self showAlert:@"确认要给帖子在对应的小区圈加精？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            
        } confirmBlock:^{
            [wself setOperationGood:YES];
        }];
    }else if(view.selectdWord.type == FHFeedOperationWordTypeCancelGood){
        [self showAlert:@"确认要给帖子在对应的小区圈取消加精？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            
        } confirmBlock:^{
            [wself setOperationGood:NO];
        }];
    }else if(view.selectdWord.type == FHFeedOperationWordTypeSelfLook){
        [self showAlert:@"确认要将该帖子设置为自见？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            
        } confirmBlock:^{
            [wself setOperationSelfLook];
        }];
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

- (void)postDelete {
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI postDelete:self.cellModel.groupId socialGroupId:self.cellModel.community.socialGroupId enterFrom:self.cellModel.tracerDic[@"enter_from"] pageType:self.cellModel.tracerDic[@"page_type"] completion:^(bool success, NSError * _Nonnull error) {
        if(success){
            //调用删除接口
            if(wself.deleteCellBlock){
                wself.deleteCellBlock();
            }
            //删除帖子成功发送通知
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

- (void)setOperationSelfLook {
    __weak typeof(self) wself = self;
//    [FHHouseUGCAPI postDelete:self.cellModel.groupId socialGroupId:self.cellModel.community.socialGroupId enterFrom:self.cellModel.tracerDic[@"enter_from"] pageType:self.cellModel.tracerDic[@"page_type"] completion:^(bool success, NSError * _Nonnull error) {
//        if(success){
            //调用自见接口，和删帖的逻辑一致
            if(wself.deleteCellBlock){
                wself.deleteCellBlock();
            }
            //删除帖子成功发送通知
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.cellModel.community.socialGroupId.length > 0) {
        dic[@"social_group_id"] = self.cellModel.community.socialGroupId;
    }
    if(self.cellModel){
        dic[@"cellModel"] = self.cellModel;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCDelPostNotification object:nil userInfo:dic];
    
//        }else{
//            [[ToastManager manager] showToast:@"删除失败"];
//        }
//    }];
}

- (void)setOperationTop:(BOOL)isTop {
    
    NSString *imgUrl = @"http://p3.pstatp.com/origin/dac9000f02ec5048f3f8";
    
    if(isTop){
        self.cellModel.isStick = YES;
        self.cellModel.stickStyle = FHFeedContentStickStyleTop;
        if(!self.cellModel.contentDecoration){
            self.cellModel.contentDecoration = [[FHFeedUGCCellContentDecorationModel alloc] init];
        }
        self.cellModel.contentDecoration.url = imgUrl;
    }else{
        self.cellModel.isStick = NO;
        self.cellModel.stickStyle = FHFeedContentStickStyleUnknown;
        if(!self.cellModel.contentDecoration){
            self.cellModel.contentDecoration = [[FHFeedUGCCellContentDecorationModel alloc] init];
        }
        self.cellModel.contentDecoration.url = @"";
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.cellModel.community.socialGroupId.length > 0) {
        dic[@"social_group_id"] = self.cellModel.community.socialGroupId;
    }
    if(self.cellModel){
        dic[@"cellModel"] = self.cellModel;
    }
    dic[@"isTop"] = @(isTop);

    [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCTopPostNotification object:nil userInfo:dic];
}

- (void)setOperationGood:(BOOL)isGood {
    NSString *imgUrl = @"http://p3.pstatp.com/origin/dac9000f02ec5048f3f8";
    
    if(isGood){
        self.cellModel.isStick = YES;
        self.cellModel.stickStyle = FHFeedContentStickStyleGood;
        if(!self.cellModel.contentDecoration){
            self.cellModel.contentDecoration = [[FHFeedUGCCellContentDecorationModel alloc] init];
        }
        self.cellModel.contentDecoration.url = imgUrl;
    }else{
        self.cellModel.isStick = NO;
        self.cellModel.stickStyle = FHFeedContentStickStyleUnknown;
        if(!self.cellModel.contentDecoration){
            self.cellModel.contentDecoration = [[FHFeedUGCCellContentDecorationModel alloc] init];
        }
        self.cellModel.contentDecoration.url = @"";
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.cellModel.community.socialGroupId.length > 0) {
        dic[@"social_group_id"] = self.cellModel.community.socialGroupId;
    }
    if(self.cellModel){
        dic[@"cellModel"] = self.cellModel;
    }
    dic[@"isGood"] = @(isGood);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCGoodPostNotification object:nil userInfo:dic];
}

#pragma mark - 埋点

- (void)trackClickOptions {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_more";
    TRACK_EVENT(@"click_options", dict);
}

- (void)trackClickReport {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_report";
    TRACK_EVENT(@"click_report", dict);
}

- (void)trackClickDelete {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_delete";
    TRACK_EVENT(@"click_delete", dict);
}

- (void)trackConfirmDeletePopupShow {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    TRACK_EVENT(@"confirm_delete_popup_show", dict);
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
