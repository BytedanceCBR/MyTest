//
//  FHRoundShadowView.h
//  FHCommonUI
//
//  Created by 春晖 on 2019/6/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHRoundShadowView : UIView

@property(nonatomic , strong) UIColor *shadowColor;
@property(nonatomic , assign) CGSize shadowOffset;
@property(nonatomic , assign) CGFloat shadowRadius;
@property(nonatomic , assign) CGFloat shadowOpacity;

@property(nonatomic , assign) CGFloat cornerRadius;


@end

NS_ASSUME_NONNULL_END
