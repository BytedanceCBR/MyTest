//
//  UITextView+TTAdditions.m
//  Pods
//
//  Created by zhaoqin on 8/22/16.
//
//

#import "UITextView+TTAdditions.h"
@import ObjectiveC;

@interface UITextView ()
@property (nonatomic, weak) UITextView *placeHolderTextView;
@property (nonatomic, assign) BOOL isCustomPlaceHolderFont;
@end

@implementation UITextView (TTAdditions)

- (NSString *)placeHolder {
    return (NSString *)objc_getAssociatedObject(self, @selector(placeHolder));
}

- (UIColor *)placeHolderColor {
    return (UIColor *)objc_getAssociatedObject(self, @selector(placeHolderColor));
}

- (UIFont *)placeHolderFont {
    return (UIFont *)objc_getAssociatedObject(self, @selector(placeHolderFont));
}

- (UIEdgeInsets)placeHolderEdgeInsets {
    NSValue *value = (NSValue *)objc_getAssociatedObject(self, @selector(placeHolderEdgeInsets));
    return [value UIEdgeInsetsValue];
}

- (UITextView *)placeHolderTextView {
    return (UITextView *)objc_getAssociatedObject(self, @selector(placeHolderTextView));
}

- (BOOL)isCustomPlaceHolderFont {
    NSNumber *number = (NSNumber *)objc_getAssociatedObject(self, @selector(isCustomPlaceHolderFont));
    return [number boolValue];
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    
    if (![self.placeHolder isEqualToString:placeHolder]) {
        
        objc_setAssociatedObject(self, @selector(placeHolder), placeHolder, OBJC_ASSOCIATION_RETAIN);
        
        if (self.placeHolderTextView == nil) {
            UITextView * placeHolderTextView = [[UITextView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, self.placeHolderEdgeInsets)];
            placeHolderTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            placeHolderTextView.backgroundColor = [UIColor clearColor];
            placeHolderTextView.userInteractionEnabled = NO;
            placeHolderTextView.editable = NO;
            placeHolderTextView.font = self.placeHolderFont;
            placeHolderTextView.textColor = self.placeHolderColor;
            placeHolderTextView.textAlignment = self.textAlignment;
            [self addSubview:placeHolderTextView];
            self.placeHolderTextView = placeHolderTextView;
        }
        
        self.placeHolderTextView.text = placeHolder;
        
        [self showOrHidePlaceHolderTextView];
    }
    
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {

    if (![self.placeHolderColor isEqual:placeHolderColor]) {
        
        objc_setAssociatedObject(self, @selector(placeHolderColor), placeHolderColor, OBJC_ASSOCIATION_RETAIN);
        
        if (self.placeHolderTextView) {
            self.placeHolderTextView.textColor = placeHolderColor;
        }
    }
    
}

- (void)setPlaceHolderFont:(UIFont *)placeHolderFont {

    if (![self.placeHolderFont isEqual:placeHolderFont]) {
        
        objc_setAssociatedObject(self, @selector(placeHolderFont), placeHolderFont, OBJC_ASSOCIATION_RETAIN);
        
        self.isCustomPlaceHolderFont = YES;
        if (self.placeHolderTextView) {
            self.placeHolderTextView.font = placeHolderFont;
        }
    }
    
}

- (void)setPlaceHolderEdgeInsets:(UIEdgeInsets)placeHolderEdgeInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:placeHolderEdgeInsets];
    objc_setAssociatedObject(self, @selector(placeHolderEdgeInsets), value, OBJC_ASSOCIATION_RETAIN);
}

- (void)setPlaceHolderTextView:(UITextView *)placeHolderTextView {
    objc_setAssociatedObject(self, @selector(placeHolderTextView), placeHolderTextView, OBJC_ASSOCIATION_RETAIN);
}

- (void)setIsCustomPlaceHolderFont:(BOOL)isCustomPlaceHolderFont {
    NSNumber *number = [NSNumber numberWithBool:isCustomPlaceHolderFont];
    objc_setAssociatedObject(self, @selector(isCustomPlaceHolderFont), number, OBJC_ASSOCIATION_RETAIN);
}

- (void)showOrHidePlaceHolderTextView {
    if (self.placeHolderTextView) {
        self.placeHolderTextView.hidden = self.text.length > 0 ? YES : NO;
    }
}

- (void)syncFontWithPlaceHolderFont {
    
    if (self.isCustomPlaceHolderFont == NO) {
        self.placeHolderFont = self.font;
        if (self.placeHolderTextView) {
            self.placeHolderTextView.font = self.font;
        }
    }
    
}

- (void)syncTextAlignmentWithPlaceHoler {
    if (self.placeHolderTextView) {
        self.placeHolderTextView.textAlignment = self.textAlignment;
    }
}

@end
