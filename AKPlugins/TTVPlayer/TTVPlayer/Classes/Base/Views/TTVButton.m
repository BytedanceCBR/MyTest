//
//  TTVButton.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/6.
//

#import "TTVButton.h"
#import "TTVReduxKit.h"

@interface TTVButton ()

@property (nonatomic, strong) UIColor * buttonTitleColor;/// 默认状态的 buttonColor
@property (nonatomic, strong) TTVReduxAction * actionTouchupInside; // 正常状态，点击的 action

@end


@implementation TTVButton

@synthesize store, didButtonTouchUpInside, image = _image, title = _title, titleColor = _titleColor;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self setImage:self.image forState:UIControlStateNormal];
}

- (void)setAction:(TTVReduxAction *)action {
    self.actionTouchupInside = action;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    [self setTitleColor:titleColor forState:UIControlStateNormal];
}

- (TTVReduxAction *)action {
    return self.actionTouchupInside;
}

- (void)clickButton:(TTVToggledButton *)button {
    if ([self respondsToSelector:@selector(didButtonTouchUpInside)]) {
        if (self.didButtonTouchUpInside) {
            self.didButtonTouchUpInside();
        }
        if ([TTVReduxAction isValidActon:self.actionTouchupInside]) {
            [self.store dispatch:self.actionTouchupInside];
        }
    }
}



@end
