//
//  UIImageView.m
//  Article
//
//  Created by fengyadong on 16/6/22.
//
//

#import "UIImageView+TTCornerRadius.h"
#import <objc/runtime.h>

@interface UIImage (cornerRadius)

@property (nonatomic, assign) BOOL hasCornerRadius;

@end

@implementation UIImage (cornerRadius)

- (BOOL)hasCornerRadius {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setHasCornerRadius:(BOOL)hasCornerRadius {
    objc_setAssociatedObject(self, @selector(hasCornerRadius), @(hasCornerRadius), OBJC_ASSOCIATION_ASSIGN);
}

@end

/////////////////////////////////////////////////////////////////////
@interface TTImageObserver : NSObject

@property (nonatomic, assign) UIImageView *originImageView;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) UIRectCorner cornerType;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;

- (instancetype)initWithImageView:(UIImageView *)imageView;

@end

@implementation TTImageObserver

- (void)dealloc {
    [self.originImageView removeObserver:self forKeyPath:@"image"];
    [self.originImageView removeObserver:self forKeyPath:@"contentMode"];
}

- (instancetype)initWithImageView:(UIImageView *)imageView{
    if (self = [super init]) {
        self.originImageView = imageView;
        [imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        [imageView addObserver:self forKeyPath:@"contentMode" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString*, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        UIImage *newImage = change[NSKeyValueChangeNewKey];
        if (![newImage isKindOfClass:[UIImage class]] || newImage.hasCornerRadius) {
            return;
        }
        [self updateImageView];
    }
    if ([keyPath isEqualToString:@"contentMode"]) {
        self.originImageView.image = self.originImage;
    }
}

- (void)setCornerType:(UIRectCorner)cornerType {
    if (_cornerType == cornerType) {
        return;
    }
    _cornerType = cornerType;
    [self updateImageView];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius == cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    if (_cornerRadius > 0) {
        [self updateImageView];
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (_borderColor == borderColor) {
        return;
    }
    _borderColor = borderColor;
    if (_borderColor) {
        [self updateImageView];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (_borderWidth == borderWidth) {
        return;
    }
    _borderWidth = borderWidth;
    if (_borderWidth > 0) {
        [self updateImageView];
    }
}

- (void)updateImageView {
    self.originImage = self.originImageView.image;
    if (!self.originImage) {
        return;
    }
    if (self.originImage.hasCornerRadius) {
        [self updateBorderCorner];
        return;
    }
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(self.originImageView.bounds.size, NO, [UIScreen mainScreen].scale);
    CGSize cornerRadii = CGSizeMake(self.cornerRadius, self.cornerRadius);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    if (currnetContext) {
        UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.originImageView.bounds byRoundingCorners:self.cornerType cornerRadii:cornerRadii];
        [cornerPath addClip];
        [self.originImageView.layer renderInContext:currnetContext];
        [self drawBorder:cornerPath];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if ([image isKindOfClass:[UIImage class]]) {
        image.hasCornerRadius = YES;
        self.originImageView.image = image;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateImageView];
        });
    }
}

- (void)updateBorderCorner {
    CGSize cornerRadii = CGSizeMake(self.cornerRadius, self.cornerRadius);
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.originImageView.bounds byRoundingCorners:self.cornerType cornerRadii:cornerRadii];
    [self drawBorder:cornerPath];
    
}

- (void)drawBorder:(UIBezierPath *)path {
    if (self.borderWidth != 0 && self.borderColor) {
        [path setLineWidth:2 * self.borderWidth];
        [self.borderColor setStroke];
        [path stroke];
    }
}

@end

/////////////////////////////////////////////////////////////////////

@implementation UIImageView (TTCornerRadius)

- (CGFloat)tt_cornerRadius {
    return [self imageObserver].cornerRadius;
}

- (void)setTt_cornerRadius:(CGFloat)tt_cornerRadius {
    [self imageObserver].cornerRadius = tt_cornerRadius;
}

- (UIRectCorner)tt_cornerType {
    return [self imageObserver].cornerType;
}

- (void)setTt_cornerType:(UIRectCorner)tt_cornerType {
    [self imageObserver].cornerType = tt_cornerType;
}

- (CGFloat)tt_borderWidth {
    return [self imageObserver].borderWidth;
}

- (void)setTt_borderWidth:(CGFloat)tt_borderWidth {
    [self imageObserver].borderWidth = tt_borderWidth;
}

- (UIColor *)tt_borderColor {
    return [self imageObserver].borderColor;
}

- (void)setTt_borderColor:(UIColor *)tt_borderColor {
    [self imageObserver].borderColor = tt_borderColor;
}

- (TTImageObserver *)imageObserver {
    TTImageObserver *imageObserver = objc_getAssociatedObject(self, _cmd);
    if (!imageObserver) {
        imageObserver = [[TTImageObserver alloc] initWithImageView:self];
        objc_setAssociatedObject(self, _cmd, imageObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return imageObserver;
}

@end
