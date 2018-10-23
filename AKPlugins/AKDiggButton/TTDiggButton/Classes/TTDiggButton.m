//
//  TTDiggButton.m
//  Article
//
//  Created by ZhangLeonardo on 15/8/11.
//
//

#import "TTDiggButton.h"
#import <TTUIWidget/SSMotionRender.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/TTBusinessManager.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>
#import <TTThemed/UIImage+TTThemeExtension.h>


@interface TTDiggButton()

@property (nonatomic, assign) TTDiggButtonStyleType styleType;
@property (nonatomic, copy) TTDiggButtonClickBlock buttonClickBlock;

@end

@implementation TTDiggButton

+ (id)diggButton {
    return [self diggButtonWithStyleType:TTDiggButtonStyleTypeBoth];
}

+ (id)diggButtonWithStyleType:(TTDiggButtonStyleType)styleType {
    TTDiggButton * button = [TTDiggButton buttonWithType:UIButtonTypeCustom];
    if (button) {
        button.imageName = @"digup_video";
        button.selectedImageName = @"digup_video_press";
        button.selectedTitleColorThemeKey = @"ff0031";
        button.titleColorThemeKey = @"222222";
        button.styleType = styleType;
        button.backgroundColor = [UIColor clearColor];
        [button setDiggCount:0];
        button.enableHighlightAnim = NO;
        [button addTarget:button action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

- (void)setStyleType:(TTDiggButtonStyleType)styleType {
    _styleType = styleType;
    self.tintColorThemeKey = nil;
    self.selectedTintColorThemeKey = nil;
    switch (_styleType) {
        case TTDiggButtonStyleTypeDigitalOnly:{
            self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15.f]];
        }
        break;
        case TTDiggButtonStyleTypeBoth:{
            self.titleLabel.font = [UIFont systemFontOfSize:12];
            self.tintColorThemeKey = @"222222";
            self.selectedTintColorThemeKey = @"ff0031";
        }
        break;
        case TTDiggButtonStyleTypeBothSmall:{
            self.imageName = @"comment_like_icon";
            self.selectedImageName = @"comment_like_icon_press";
            self.titleColorThemeKey = kColorText13;
            self.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
            //            self.titleEdgeInsets = UIEdgeInsetsMake(-0.5, 0, 0.5, 0);
            if ([TTDeviceHelper OSVersionNumber] < 8.f) {
                self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[self digButtonFontSize]];
            }
            else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                self.titleLabel.font = [UIFont systemFontOfSize:[self digButtonFontSize] weight:UIFontWeightThin];
#pragma clang diagnostic pop
            }
        }
        break;
        //        case TTDiggButtonStyleTypeBuryDigitalOnly:{
        //            self.imageName = @"digdown_video";
        //            self.selectedImageName = @"digdown_video_press";
        //            self.titleLabel.font = [UIFont systemFontOfSize:10];
        //        }
        //            break;
        case TTDiggButtonStyleTypeBuryBoth:{
            self.imageName = @"digdown_video";
            self.selectedImageName = @"digdown_video_press";
            self.titleLabel.font = [UIFont systemFontOfSize:12];
        }
        break;
        case TTDiggButtonStyleTypeImageOnly:{
            self.imageName = @"digup_tabbar";
            self.selectedImageName = @"digup_tabbar_press";
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        }
        break;
        //        case TTDiggButtonStyleTypeBuryImageOnly:{
        ////            self.imageName = @"digdown_tabbar";
        ////            self.selectedImageName = @"digdown_tabbar_press";
        ////            self.highlightedImageName = @"digdown_tabbar_press";
        //            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        //        }
        //            break;
        case TTDiggButtonStyleTypeBigBoth:{
            self.imageName = @"digup_tabbar";
            self.selectedImageName = @"digup_tabbar_press";
            self.highlightedImageName = @"digup_tabbar_press";
            self.titleLabel.font = [UIFont systemFontOfSize:14];
            self.titleColorThemeKey = kColorText1;
            self.disabledTitleColorThemeKey = kColorText3;
        }
        break;
        case TTDiggButtonStyleTypeSmallImageOnly:{
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        }
        break;
        case TTDiggButtonStyleTypeBigNumber:{
            self.imageName = @"comment_like_icon";
            self.selectedImageName = @"comment_like_icon_press";
            self.highlightedImageName = @"comment_like_icon_press";
            [self setTitleEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 0)];
            if ([TTDeviceHelper OSVersionNumber] < 8.f) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[self digButtonFontSize]];
#pragma clang diagnostic pop
            }
            else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                self.titleLabel.font = [UIFont systemFontOfSize:[self digButtonFontSize] weight:UIFontWeightThin];
#pragma clang diagnostic pop
            }
            self.titleColorThemeKey = kColorText13;
        }
        break;
        case TTDiggButtonStyleTypeCommentOnly: {
            self.imageName = @"like_grey_comment";
            self.selectedImageName = @"like_press";
            self.tintColorThemeKey = @"979FAC";
            self.selectedTintColorThemeKey = @"ff0031";
            self.titleColorThemeKey = @"979FAC";
            self.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
            if ([TTDeviceHelper OSVersionNumber] < 8.f) {
                self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[self digButtonFontSize]];
            }
            else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                self.titleLabel.font = [UIFont systemFontOfSize:[self digButtonFontSize] weight:UIFontWeightThin];
#pragma clang diagnostic pop
            }
        }
        default:
        break;
    }
}

- (void)setDiggCount:(int64_t)diggCount {
    NSString *title = nil;
    switch (_styleType) {
        case TTDiggButtonStyleTypeDigitalOnly:{
            title = [TTBusinessManager formatCommentCount:diggCount];
        }
        break;
        case TTDiggButtonStyleTypeBoth:{
            title = NSLocalizedString(@"赞", nil);
            if (diggCount > 0) {
                title = [TTBusinessManager formatCommentCount:diggCount];
            }
        }
        break;
        case TTDiggButtonStyleTypeCommentOnly:
        case TTDiggButtonStyleTypeBothSmall:{
            title = NSLocalizedString(@"赞", nil);
            if (diggCount > 0) {
                title = [TTBusinessManager formatCommentCount:diggCount];
                if ([TTDeviceHelper OSVersionNumber] < 8.f) {
                    self.titleLabel.font = [UIFont systemFontOfSize:[self digButtonFontSize]];
                } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                    self.titleLabel.font = [UIFont systemFontOfSize:[self digButtonFontSize] weight:UIFontWeightThin];
#pragma clang diagnostic pop
                }
                
            } else {
                self.titleLabel.font = [UIFont systemFontOfSize:[self digButtonFontSize]];
            }
        }
        break;
        //        case TTDiggButtonStyleTypeBuryDigitalOnly:{
        //            title = [TTDeviceHelper formatCommentCount:diggCount];
        //        }
        //            break;
        case TTDiggButtonStyleTypeBuryBoth:{
            title = NSLocalizedString(@"踩", nil);
            if (diggCount > 0) {
                title = [TTBusinessManager formatCommentCount:diggCount];
            }
        }
        break;
        case TTDiggButtonStyleTypeImageOnly:{//不显示数字
            title = @"";
        }
        break;
        //        case TTDiggButtonStyleTypeBuryImageOnly:{//不显示数字
        //            title = @"";
        //        }
        //            break;
        case TTDiggButtonStyleTypeBigBoth:{
            title = NSLocalizedString(@"赞", nil);
            if (diggCount > 0) {
                title = [TTBusinessManager formatCommentCount:diggCount];
            }
        }
        break;
        case TTDiggButtonStyleTypeSmallImageOnly:{
            title = @"";
        }
        break;
        case TTDiggButtonStyleTypeBigNumber:{
            title = [TTBusinessManager formatCommentCount:diggCount];
        }
        break;
        default:
        break;
    }
    [self setTitle:[NSString stringWithFormat:@"%@", title] forState:UIControlStateNormal];
}

- (void)buttonClicked
{
    if (self.shouldClickBlock && !self.shouldClickBlock()) {
        return;
    }
    
    if (self.manuallySetSelectedEnabled){
        TTDiggButtonClickType type = TTDiggButtonClickTypeDigg;
        if (self.selected) {
            type = TTDiggButtonClickTypeAlreadyDigg;
        }
        if (_buttonClickBlock) {
            _buttonClickBlock(type);
        }
        return;
    }
    
    TTDiggButtonClickType type = TTDiggButtonClickTypeDigg;
    if (self.selected) {
        type = TTDiggButtonClickTypeAlreadyDigg;
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
        self.selected = NO;
    }
}

- (void)setClickedBlock:(TTDiggButtonClickBlock)block {
    self.buttonClickBlock = block;
}

- (void)didMoveToSuperview {
    
}

- (void)setSelected:(BOOL)selected {
    if (!self.manuallySetSelectedEnabled) {
        [super setSelected:selected];
        return ;
    }
    
    //手动设置 & 并非连续赞 & 状态发生改变 则动画
    if (self.selected != selected) {
        TTDiggButtonClickType type = TTDiggButtonClickTypeDigg;
        if (self.selected) {
            type = TTDiggButtonClickTypeAlreadyDigg;
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

- (CGFloat)digButtonFontSize {
    if ([TTDeviceHelper isPadDevice]) {
        return 15.f;
    } else {
        if (![TTDeviceHelper isScreenWidthLarge320]) {
            return 12.f;
        } else {
            return 13.f;
        }
    }
}

@end
