//
//  FHMobileBindingView.h
//  Pods
//
//  Created by bytedance on 2020/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate;

@interface FHMobileBindingView : UIView

@property(nonatomic, weak) id<FHLoginViewDelegate> delegate;

@property (nonatomic, weak) UITextField *mobileTextField;

@end

NS_ASSUME_NONNULL_END
