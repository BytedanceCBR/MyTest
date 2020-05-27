//
//  FHMobileInputView.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate;

@interface FHMobileInputView : UIView

@property (nonatomic, weak) id<FHLoginViewDelegate> delegate;

@property (nonatomic, weak) UITextField *mobileTextField;

/// 更新UI数据
/// @param protocol 协议
- (void)updateProtocol:(NSAttributedString *)protocol showDouyinIcon:(BOOL )showDouyinIcon;

@end

NS_ASSUME_NONNULL_END