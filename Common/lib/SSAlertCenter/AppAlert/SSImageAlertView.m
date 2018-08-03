//
//  SSImageAlertView.m
//  Essay
//
//  Created by Dianwei on 13-10-20.
//  Copyright (c) 2013年 Bytedance. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SSImageAlertView.h"
#import <BDWebImage/SDWebImageAdapter.h>
 
#import "TTStringHelper.h"
#import "UIColor+TTThemeExtension.h"

#define DegreesToRadians(degrees) (degrees * M_PI / 180)

@interface SSImageAlertView()
@property(nonatomic, retain)UIView *containerView;
@property(nonatomic, retain)UIButton *closeButton;
@property(nonatomic, retain)NSMutableArray *buttons;
@property(nonatomic, retain)UIImageView *imageView;
@property(nonatomic, retain)UITapGestureRecognizer *tapRecognizer;
@end

@implementation SSImageAlertView

- (void)dealloc
{
    self.containerView = nil;
    self.closeButton = nil;
    self.buttons = nil;
    self.imageView = nil;
    self.delegate = nil;
    [_imageView removeGestureRecognizer:_tapRecognizer];
    self.tapRecognizer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    CGSize size = [[UIApplication sharedApplication] keyWindow].frame.size;
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 270)];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 5.f;
        _containerView.center = CGPointMake(self.width / 2, self.height / 2);
        [self addSubview:_containerView];
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"recommend_cancel.png"] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage imageNamed:@"recommend_cancel_press.png"] forState:UIControlStateHighlighted];
        [_closeButton sizeToFit];
        _closeButton.center = CGPointMake((_containerView.right), (_containerView.top));
        [_closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 270, 218)];
        _imageView.userInteractionEnabled = YES;
        [_containerView addSubview:_imageView];
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [_imageView addGestureRecognizer:_tapRecognizer];
        
        self.buttons = [NSMutableArray arrayWithCapacity:2];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarFrame:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)tapped:(UIGestureRecognizer*)recognizer
{
    if(!isEmptyString(_alertModel.actions))
    {
        NSArray *actionArray = [_alertModel.actions componentsSeparatedByString:@","];
        if([actionArray count] > 0)
        {
            [self dismssWithButtonIndex:0];
        }
    }
}

- (void)show
{
    for(UIButton *button in _buttons)
    {
        [button removeFromSuperview];
    }
    
    [_buttons removeAllObjects];
    
    NSArray *buttonArray = [_alertModel.buttons componentsSeparatedByString:@","];
    float offsetY = (_imageView.bottom) + 6;
    NSInteger buttonIndex = NSNotFound;
    if(buttonArray.count == 1)
    {
        buttonIndex = 0;
    }
    else if(buttonArray.count > 0 && _alertModel.expectedIndex.integerValue != NSNotFound && _alertModel.expectedIndex.integerValue < buttonArray.count)
    {
        buttonIndex = _alertModel.expectedIndex.integerValue;
    }
    
    if(buttonIndex != NSNotFound)
    {
        UIButton *button = [self actionButtonWithTitle:buttonArray[buttonIndex]];
        [button setBackgroundImage:[UIImage imageNamed:@"recommend_button.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"recommend_button_press.png"] forState:UIControlStateHighlighted];
        [button sizeToFit];
        button.tag = buttonIndex;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.origin = CGPointMake(6, offsetY);
        [_containerView addSubview:button];
        [_buttons addObject:button];
    }
    
    [_imageView sda_setImageWithURL:[TTStringHelper URLWithURLString:_alertModel.imageURLString]];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    self.center = CGPointMake((keyWindow.width) / 2, (keyWindow.height) / 2);
    [keyWindow addSubview:self];
    [self updateFrames];
}

- (void)buttonClicked:(UIButton*)button
{
    [self dismssWithButtonIndex:button.tag];
}

- (void)dismssWithButtonIndex:(NSInteger)buttonIndex
{
    if(_delegate)
    {
        [_delegate imageAlertView:self clickedButtonAtIndex:buttonIndex];
    }
    
    [self hide];
}

- (UIButton*)actionButtonWithTitle:(NSString*)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:20];
    [button setTitleColor:[UIColor colorWithHexString:@"fafafa"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"ffe0bf"] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

- (void)hide
{
    [self removeFromSuperview];
}

- (void)close:(id)sender
{
    // by API protocol
    [self dismssWithButtonIndex:-1];
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
    
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-DegreesToRadians(90));
            
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(DegreesToRadians(90));
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(DegreesToRadians(180));
            
        case UIInterfaceOrientationPortrait:
        default:
            return CGAffineTransformMakeRotation(DegreesToRadians(0));
    }
}


- (void)updateFrames {
    
    self.transform = [self transformForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    self.frame = [self frameForSelf];
//    [self updateSubviewFrames];
}

//- (void)updateSubviewFrames
//{
//    _backgroundView.frame = self.bounds;
//    _dialogView.frame = [self frameForDialogView];
//}


- (void)didChangeStatusBarFrame:(NSNotification *)notification
{
    [self updateFrames];
}

- (CGRect)frameForSelf
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat screenWidth = (window.width);
    CGFloat screenHeight = (window.height);
    CGRect frame = CGRectMake(0, 0, screenWidth, screenHeight);
    return frame;
}

@end
