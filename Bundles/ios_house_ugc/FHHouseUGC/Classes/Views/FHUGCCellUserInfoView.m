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

- (void)moreOperation {
    FHFeedOperationView *dislikeView = [[FHFeedOperationView alloc] init];
    FHFeedOperationViewModel *viewModel = [[FHFeedOperationViewModel alloc] init];

    if(self.cellModel){
        viewModel.groupID = self.cellModel.groupId;
        viewModel.userID = self.cellModel.user.userId;
        viewModel.categoryID = self.cellModel.categoryId;
    }

    [dislikeView refreshWithModel:viewModel];
    CGPoint point = _moreBtn.center;
    [dislikeView showAtPoint:point
                    fromView:_moreBtn
             didDislikeBlock:^(FHFeedOperationView * _Nonnull view) {
                 [self handleItemselected:view];
             }];
}

- (void)handleItemselected:(FHFeedOperationView *) view {
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
        //二次弹窗提醒
        [self showDeleteAlert];
    }
}

- (void)showDeleteAlert {
    __weak typeof(self) wself = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否确认要删除"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             // 点击取消按钮，调用此block
                                                         }];
    [alert addAction:cancelAction];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定删除"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              // 点击按钮，调用此block
                                                              [wself postDelete];
                                                          }];
    [alert addAction:defaultAction];
    [[TTUIResponderHelper visibleTopViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)postDelete {
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI postDelete:self.cellModel.groupId socialGroupId:self.cellModel.community.socialGroupId completion:^(bool success, NSError * _Nonnull error) {
        if(success){
            //调用删除接口
            if(wself.deleteCellBlock){
                wself.deleteCellBlock();
            }
            //删除帖子成功发送通知
            if (wself.cellModel.community.socialGroupId.length > 0) {
                NSDictionary *dic = @{
                                      @"social_group_id":wself.cellModel.community.socialGroupId,
                                      @"cellModel":wself.cellModel,
                                      };
                [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCDelPostNotification object:nil userInfo:dic];
            }
        }else{
            [[ToastManager manager] showToast:@"删除失败"];
        }
    }];
}

@end
