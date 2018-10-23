//
//  TTAlphaThemedLabel.m
//  Article
//
//  Created by 徐霜晴 on 17/2/27.
//
//

#import "TTAlphaThemedLabel.h"

@implementation TTAlphaThemedLabel

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.alpha = 0.5;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.alpha = 1.0;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.alpha = 1.0;
    [super touchesCancelled:touches withEvent:event];
}

@end
