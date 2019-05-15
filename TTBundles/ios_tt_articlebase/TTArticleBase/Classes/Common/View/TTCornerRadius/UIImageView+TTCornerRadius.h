//
//  UIImageView+TTCornerRadius.h
//  Article
//
//  Created by fengyadong on 16/6/22.
//
//

#import <Foundation/Foundation.h>

@interface UIImageView (TTCornerRadius)

@property (nonatomic, assign) CGFloat tt_cornerRadius;
@property (nonatomic, assign) UIRectCorner tt_cornerType;
@property (nonatomic, assign) CGFloat tt_borderWidth;
@property (nonatomic, strong) UIColor *tt_borderColor;

@end
