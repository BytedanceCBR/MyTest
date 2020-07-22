//
//  FHOneKeyLoginView.h
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate;

@interface FHOneKeyLoginView : UIView

@property(nonatomic, weak) id<FHLoginViewDelegate> delegate;

/// 更新UI数据
/// @param phoneNum 手机号
/// @param service 运营商名称
/// @param protocol 协议
- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service protocol:(NSAttributedString *)protocol showDouyinIcon:(BOOL )showDouyinIcon;

- (instancetype)initWithFrame:(CGRect)frame isHalfLogin:(BOOL)isHalfLogin;

- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service protocol:(NSAttributedString *)protocol showDouyinIcon:(BOOL )showDouyinIcon showCodeLoginBtn:(BOOL)showCode;
@end

NS_ASSUME_NONNULL_END
