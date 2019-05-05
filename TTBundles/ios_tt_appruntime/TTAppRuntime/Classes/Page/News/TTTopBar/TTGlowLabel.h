//
//  TTGlowLabel.h
//  Article
//
//  Created by fengyadong on 16/8/30.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

@interface TTGlowLabel : SSThemedLabel

@property (nonatomic, assign) CGFloat glowSize;
@property (nonatomic, strong) UIColor *glowColor;

@end
