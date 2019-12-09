//
// Created by fengbo on 2019-10-28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHShadowView : UIView

@property(nonatomic , strong) UIColor *shadowColor;
@property(nonatomic , assign) CGSize shadowOffset;
@property(nonatomic , assign) CGFloat shadowRadius;
@property(nonatomic , assign) CGFloat shadowOpacity;

@property(nonatomic , assign) CGFloat cornerRadius;

@end

NS_ASSUME_NONNULL_END
