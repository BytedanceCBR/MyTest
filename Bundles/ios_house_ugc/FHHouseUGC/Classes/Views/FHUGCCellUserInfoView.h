//
//  FHUGCCellUserInfoView.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/4.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"
#import "TTAsyncCornerImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellUserInfoView : UIView

@property(nonatomic ,strong) TTAsyncCornerImageView *icon;
@property(nonatomic ,strong) UILabel *userName;
@property(nonatomic ,strong) UILabel *userAuthLabel;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) UILabel *editLabel;
@property(nonatomic ,strong) UILabel *editingLabel;// 编辑发送中
@property(nonatomic ,strong) UIButton *moreBtn;
@property(nonatomic ,strong) UILabel *titleLabel;

@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic, copy) void(^deleteCellBlock)(void);
@property(nonatomic, copy) void(^reportSuccessBlock)(void);

- (void)updateDescLabel;
- (void)updateEditState;

//购房百科样式morebtn:
- (void)updateMoreBtnWithTitleType;

- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel;

- (void)setTitleModel:(FHFeedUGCCellModel *)cellModel;
@end

NS_ASSUME_NONNULL_END
