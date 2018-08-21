//
//  TTVAdPlayFinnishActionButton.m
//  Article
//
//  Created by panxiang on 2017/5/5.
//
//

#import "TTVAdPlayFinnishActionButton.h"
#import "TTAdAppointAlertView.h"
#import "TTTouchContext.h"

@interface TTVAdPlayFinnishActionButton ()

@property (nonatomic, strong)TTAdAppointAlertView *alertView;

@end

@implementation TTVAdPlayFinnishActionButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        self.titleColorThemeKey = kColorText6;
        self.borderColorThemeKey = kColorText6;

        self.titleLabel.font = [UIFont systemFontOfSize:12.];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;

        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    if (!isEmptyString(title)) {
        [self setTitle:title forState:UIControlStateNormal];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    CGPoint point =  [touch locationInView:touch.view];
    TTTouchContext *context = [TTTouchContext new];
    context.targetView = self;
    context.touchPoint = point;
    self.lastTouchContext = context;
    [super touchesEnded:touches withEvent:event];
}

@end
