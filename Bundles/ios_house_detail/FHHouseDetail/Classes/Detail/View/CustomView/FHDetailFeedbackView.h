//
//  FHDetailFeedbackView.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/7/16.
//

#import <UIKit/UIKit.h>
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailFeedbackView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)show:(UIView *)parentView;

- (void)hide;

@property(nonatomic, weak) UINavigationController *navVC;
@property (nonatomic, strong) FHHouseDetailBaseViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END


