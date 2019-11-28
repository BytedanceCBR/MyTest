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
@property(nonatomic, copy)void(^confirmClickBlock)(NSString *phoneNum,FHDetailNoticeAlertView *alertView);
@property(nonatomic, copy)void(^leftClickBlock)(NSString *phoneNum,FHDetailNoticeAlertView *alertView);
@property(nonatomic, copy)void(^tipClickBlock)(void);
@property(nonatomic, copy)void(^agencyClickBlock)(FHDetailNoticeAlertView *alertView);

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle;
- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle leftBtnTitle:(NSString *)leftBtnTitle;

- (void)updateAgencyTitle:(NSString *)agencyTitle;
- (void)showFrom:(UIView *)parentView;
- (void)dismiss;
// 不dissmiss 直接展示另一个view
- (void)showAnotherView:(UIView *)anotherView;

- (NSArray *)selectAgencyList;

@end

NS_ASSUME_NONNULL_END
