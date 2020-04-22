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

@property(nonatomic , weak) id<FHLoginViewDelegate> delegate;

- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service protocol:(NSAttributedString *)protocol;

@end

NS_ASSUME_NONNULL_END
