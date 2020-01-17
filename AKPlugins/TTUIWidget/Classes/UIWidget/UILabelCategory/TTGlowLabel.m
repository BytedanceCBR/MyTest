//
//  TTGlowLabel.m
//  Article
//
//  Created by fengyadong on 16/8/30.
//
//

#import "TTGlowLabel.h"

@implementation TTGlowLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _glowSize = 0.0f;
    _glowColor = [UIColor clearColor];
}

- (void)drawGlowEffectInRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    [super drawTextInRect:rect];
    UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGContextSaveGState(ctx);
    
    CGContextSetShadow(ctx, CGSizeZero, self.glowSize);
    CGContextSetShadowWithColor(ctx, CGSizeZero, self.glowSize, self.glowColor.CGColor);
    
    [textImage drawAtPoint:rect.origin];
    CGContextRestoreGState(ctx);
}

- (void)drawTextInRect:(CGRect)rect {
    if (isEmptyString(self.text)) {
        return;
    }
    
    if (self.glowSize > 0) {
        [self drawGlowEffectInRect:rect];
    } else {
        [super drawTextInRect:rect];
    }
}

@end
