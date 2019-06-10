//
//  TTVToggledButton.m
//  ScreenRotate
//
//  Created by lisa on 2019/3/28.
//  Copyright © 2019 zuiye. All rights reserved.
//

#import "TTVToggledButton.h"
#import "TTVReduxKit.h"

@interface TTVToggledButton ()

@property (nonatomic, copy) NSString * buttonTitle;/// 默认状态的 buttonTitle
@property (nonatomic, copy) NSString * toggledButtonTitle;/// 切换后状态的 buttonTitle

@property (nonatomic, strong) UIImage * buttonImage;/// 默认状态的 buttonImage
@property (nonatomic, strong) UIImage * toggledButtonImage;/// 切换后状态的 buttonImage

@property (nonatomic, strong) UIColor * buttonTitleColor;/// 默认状态的 buttonColor
@property (nonatomic, strong) UIColor * toggledButtonTitleColor;/// 切换后状态的 buttonColor

@property (nonatomic, strong) TTVReduxAction * actionForNormalStatus; // 正常状态，点击的 action
@property (nonatomic, strong) TTVReduxAction * actionForToggledStatus; // toggle 状态，点击的 action

@end

@implementation TTVToggledButton

@synthesize currentToggledStatus = _currentToggledStatus;
@synthesize didToggledButtonTouchUpInside, buttonWillToggleToStatus, buttonDidToggleToStatus;
@synthesize store;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setImage:(UIImage *)image forStatus:(TTVToggledButtonStatus)status {
    switch (status) {
        case TTVToggledButtonStatus_Normal:
            self.buttonImage = image;
            if (self.currentToggledStatus == TTVToggledButtonStatus_Normal) {
                [self setImage:self.buttonImage forState:UIControlStateNormal];
            }
            break;
            
        case TTVToggledButtonStatus_Toggled:
            self.toggledButtonImage = image;
            if (self.currentToggledStatus == TTVToggledButtonStatus_Toggled) {
                [self setImage:self.toggledButtonImage forState:UIControlStateNormal];
            }
            break;
    }

}
- (UIImage *)imageForStatus:(TTVToggledButtonStatus)status {
    switch (status) {
        case TTVToggledButtonStatus_Normal:
            return self.buttonImage;
            break;
            
        case TTVToggledButtonStatus_Toggled:
            return self.toggledButtonImage;
            break;
    }
    return nil;
}
- (void)setCurrentToggledStatus:(TTVToggledButtonStatus)currentToggledStatus {
    if (_currentToggledStatus != currentToggledStatus) {
        // 需要添加动画 过渡动画 TODO
        if ([self respondsToSelector:@selector(buttonWillToggleToStatus:)]) {
            self.buttonWillToggleToStatus(currentToggledStatus);
        }
        _currentToggledStatus = currentToggledStatus;
        
        switch (currentToggledStatus) {
            case TTVToggledButtonStatus_Normal:
                [self setImage:self.buttonImage forState:UIControlStateNormal];
                [self setTitle:self.buttonTitle forState:UIControlStateNormal];
                [self setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
                break;
                
            case TTVToggledButtonStatus_Toggled:
                [self setImage:self.toggledButtonImage forState:UIControlStateNormal];
                [self setTitle:self.toggledButtonTitle forState:UIControlStateNormal];
                [self setTitleColor:self.toggledButtonTitleColor forState:UIControlStateNormal];
                break;
        }
        
        if ([self respondsToSelector:@selector(buttonDidToggleToStatus:)]) {
            self.buttonDidToggleToStatus(currentToggledStatus);
        }
    }
}

- (void)setTitle:(NSString *)title forStatus:(TTVToggledButtonStatus)status {
    switch (status) {
        case TTVToggledButtonStatus_Normal:
            self.buttonTitle = title;
            if (self.currentToggledStatus == TTVToggledButtonStatus_Normal) {
                [self setTitle:self.buttonTitle forState:UIControlStateNormal];
            }
            break;
            
        case TTVToggledButtonStatus_Toggled:
            self.toggledButtonTitle = title;
            if (self.currentToggledStatus == TTVToggledButtonStatus_Toggled) {
                [self setTitle:self.toggledButtonTitle forState:UIControlStateNormal];
            }
            break;
    }
}
- (NSString *)titleForStatus:(TTVToggledButtonStatus)status {
    switch (status) {
        case TTVToggledButtonStatus_Normal:
            return self.buttonTitle;
            break;
            
        case TTVToggledButtonStatus_Toggled:
            return self.toggledButtonTitle;
            break;
    }
}
- (void)setTitleColor:(UIColor *)titleColor forStatus:(TTVToggledButtonStatus)status {
    switch (status) {
        case TTVToggledButtonStatus_Normal:
            self.buttonTitleColor = titleColor;
            if (self.currentToggledStatus == TTVToggledButtonStatus_Normal) {
                [self setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
            }
            break;
            
        case TTVToggledButtonStatus_Toggled:
            self.toggledButtonTitleColor = titleColor;
            if (self.currentToggledStatus == TTVToggledButtonStatus_Toggled) {
                [self setTitleColor:self.toggledButtonTitleColor forState:UIControlStateNormal];
            }
            break;
    }
}
- (UIColor *)titleColorForStatus:(TTVToggledButtonStatus)status {
    switch (status) {
        case TTVToggledButtonStatus_Normal:
            return self.buttonTitleColor;
            break;
            
        case TTVToggledButtonStatus_Toggled:
            return self.toggledButtonTitleColor;
            break;
    }
}
- (void)setAction:(TTVReduxAction *)action forStatus:(TTVToggledButtonStatus)status {
    switch (status) {
        case TTVToggledButtonStatus_Normal:
            self.actionForNormalStatus = action;
            break;
            
        case TTVToggledButtonStatus_Toggled:
            self.actionForToggledStatus = action;
            break;
    }
}

- (TTVReduxAction *)actionForStatus:(TTVToggledButtonStatus)status {
    switch (status) {
        case TTVToggledButtonStatus_Normal:
            return self.actionForNormalStatus;
            break;
        case TTVToggledButtonStatus_Toggled:
            return self.actionForToggledStatus;
            break;
    }
}

- (void)clickButton:(TTVToggledButton *)button {
    if ([self respondsToSelector:@selector(didToggledButtonTouchUpInside)]) {
        if (self.didToggledButtonTouchUpInside) {
            self.didToggledButtonTouchUpInside();
        }
        if (self.currentToggledStatus == TTVToggledButtonStatus_Normal) {
            // dispatch action
            [self.store dispatch:self.actionForNormalStatus];
        }
        else {
            // dispatch action
            [self.store dispatch:self.actionForToggledStatus];
        }
    }
}

@end
