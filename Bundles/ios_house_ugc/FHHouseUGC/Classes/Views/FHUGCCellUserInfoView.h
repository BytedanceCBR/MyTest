//
//  FHUGCCellUserInfoView.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/4.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FHUGCPostEditStateNone,
    FHUGCPostEditStateSending,
    FHUGCPostEditStateDone,
} FHUGCPostEditState; // 帖子编辑状态

@interface FHUGCCellUserInfoView : UIView

@property(nonatomic ,strong) UIImageView *icon;
@property(nonatomic ,strong) UILabel *userName;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) UILabel *editLabel;
@property(nonatomic ,strong) UILabel *editingLabel;// 编辑发送中
@property(nonatomic ,strong) UIButton *moreBtn;

@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic, copy) void(^deleteCellBlock)(void);
@property(nonatomic, copy) void(^reportSuccessBlock)(void);

@end

NS_ASSUME_NONNULL_END
