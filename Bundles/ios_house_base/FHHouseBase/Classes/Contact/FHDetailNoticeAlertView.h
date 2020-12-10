//
//  FHDetailNoticeAlertView.h
//  Pods
//
//  Created by 张静 on 2019/2/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNoticeAlertView : UIView

@property (nonatomic, copy) NSString *phoneNum;
@property (nonatomic, copy) void (^confirmClickBlock)(NSString *phoneNum,FHDetailNoticeAlertView *alertView);
@property (nonatomic, copy) void (^tipClickBlock)(void);
@property (nonatomic, copy) void (^revokeAssociateDistributionBlock)(void);

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle;

- (void)showFrom:(UIView *)parentView;
- (void)dismiss;

- (void)showOtherDialogWithTitle:(NSString *)title subTitle:(NSString *)subTitle confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle;

@end

NS_ASSUME_NONNULL_END
