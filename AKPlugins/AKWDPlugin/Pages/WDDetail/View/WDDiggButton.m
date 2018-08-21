//
//  WDDiggButton.m
//  Article
//
//  Created by 张延晋 on 17/11/16.
//
//

#import "WDDiggButton.h"
#import "SSMotionRender.h"
#import "TTBusinessManager+StringUtils.h"

#import "TTDeviceUIUtils.h"
#import "UIImage+TTThemeExtension.h"

@interface WDDiggButton()

@property (nonatomic, copy) WDDiggButtonClickBlock buttonClickBlock;

@end

@implementation WDDiggButton

+ (id)diggButton
{
    WDDiggButton * button = [WDDiggButton buttonWithType:UIButtonTypeCustom];
    if (button) {
        button.imageName = @"digup_video";
        button.selectedImageName = @"digup_video_press";
        button.highlightedTitleColorThemeKey = kColorText4;
        button.selectedTitleColorThemeKey = kColorText4;
        button.titleColorThemeKey = kColorText3;
        button.backgroundColor = [UIColor clearColor];
        [button setDiggCount:0];
        button.enableHighlightAnim = NO;
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button addTarget:button action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

- (void)setDiggCount:(int64_t)diggCount
{
    NSString *title = nil;
    title = NSLocalizedString(@"赞", nil);
    if (diggCount > 0) {
        title = [TTBusinessManager formatCommentCount:diggCount];
    }
    [self setTitle:[NSString stringWithFormat:@"%@", title] forState:UIControlStateNormal];
}

- (void)buttonClicked
{
    if (self.shouldClickBlock && !self.shouldClickBlock()) {
        return;
    }
    
    if (self.manulSetSelectedEnabled){
        WDDiggButtonClickType type = WDDiggButtonClickTypeDigg;
        if (self.selected) {
            type = WDDiggButtonClickTypeAlreadyDigg;
        }
        if (_buttonClickBlock) {
            _buttonClickBlock(type);
        }
        return;
    }
    
    WDDiggButtonClickType type = WDDiggButtonClickTypeDigg;
    if (self.selected) {
        type = WDDiggButtonClickTypeAlreadyDigg;
    }
    else {
        [SSMotionRender motionInView:self.imageView byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic.png"] offsetPoint:CGPointMake(4.f, -9.f)];
    }
    if (!self.selected){
        self.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        self.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.selected = YES;
            self.alpha = 0;
            if (_buttonClickBlock) {
                _buttonClickBlock(type);
            }
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                self.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
    } else {
        if (_buttonClickBlock) {
            _buttonClickBlock(type);
        }
    }
}

- (void)setClickedBlock:(WDDiggButtonClickBlock)block
{
    self.buttonClickBlock = block;
}

- (void)didMoveToSuperview
{

}

- (void)setSelected:(BOOL)selected{
    
    if (!self.manulSetSelectedEnabled){
        [super setSelected:selected];
        return ;
    }
    
    //手动设置 & 并非连续赞 & 状态发生改变 则动画
    if (self.selected != selected) {
        WDDiggButtonClickType type = WDDiggButtonClickTypeDigg;
        if (self.selected) {
            type = WDDiggButtonClickTypeAlreadyDigg;
        }else{
            [SSMotionRender motionInView:self.imageView byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic.png"] offsetPoint:CGPointMake(4.f, -9.f)];
        }
        if (selected ) {
            self.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.imageView.contentMode = UIViewContentModeCenter;
            [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [super setSelected:selected];
                self.alpha = 0;
                [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                    self.alpha = 1;
                } completion:^(BOOL finished) {
                }];
            }];
        }else{
            [super setSelected:selected];
        }
        
    }
}

@end
