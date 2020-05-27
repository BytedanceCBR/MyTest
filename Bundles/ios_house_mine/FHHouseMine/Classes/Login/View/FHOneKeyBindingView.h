//
//  FHOneKeyBindingView.h
//  Pods
//
//  Created by bytedance on 2020/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate;

@interface FHOneKeyBindingView : UIView

@property(nonatomic, weak) id<FHLoginViewDelegate> delegate;

/// 更新UI数据
/// @param phoneNum 手机号
/// @param service 运营商名称
/// @param protocol 协议
- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service protocol:(NSAttributedString *)protocol;

@end

NS_ASSUME_NONNULL_END