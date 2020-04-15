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

@property(nonatomic , weak) id<FHLoginViewDelegate> delegate;

@property (nonatomic, weak) UITextField *mobileTextField;

- (void)updateProtocol:(NSAttributedString *)protocol;

@end

NS_ASSUME_NONNULL_END
