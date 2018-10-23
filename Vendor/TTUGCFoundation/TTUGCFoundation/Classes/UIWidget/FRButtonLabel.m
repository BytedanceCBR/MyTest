//
//  FRButtonLabel.m
//  Article
//
//  Created by 王霖 on 5/27/16.
//
//

#import "FRButtonLabel.h"

@interface FRButtonLabel ()

@property (nonatomic, assign) UIGestureRecognizerState state;

@end

@implementation FRButtonLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.state = UIGestureRecognizerStatePossible;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;
        self.state = UIGestureRecognizerStatePossible;
    }
    return self;
}

- (void)themeChanged:(NSNotification*)notification {
    if (self.highlightedTitleColorThemeKey) {
        self.highlightedTextColor = SSGetThemedColorWithKey(self.highlightedTitleColorThemeKey);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    self.state = UIGestureRecognizerStateBegan;
    self.highlighted = YES;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch * touch = [touches anyObject];
    bool inside = CGRectContainsPoint(self.bounds, [touch locationInView:self]);
    if (!inside) {
        self.state = UIGestureRecognizerStatePossible;
    }
    self.highlighted = inside;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (self.state == UIGestureRecognizerStateBegan && self.tapHandle) {
        self.tapHandle();
    }
    self.state = UIGestureRecognizerStatePossible;
    self.highlighted = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    self.state = UIGestureRecognizerStatePossible;
    self.highlighted = NO;
}

@end
