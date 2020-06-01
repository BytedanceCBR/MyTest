//
//  FHDouYinLoginView.h
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate;

@interface FHDouYinLoginView : UIView

@property(nonatomic, weak) id<FHLoginViewDelegate> delegate;

/// 更新UI数据
/// @param protocol 协议
- (void)updateProtocol:(NSAttributedString *)protocol;

@end

NS_ASSUME_NONNULL_END
