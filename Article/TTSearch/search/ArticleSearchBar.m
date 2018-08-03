//
//  ArticleSearchBar.m
//  Article
//
//  Created by SunJiangting on 14-7-31.
//
//

#import "ArticleSearchBar.h"
#import "TTDeviceHelper.h"

@implementation ArticleSearchBar


- (void)setFrame:(CGRect)frame
{
    if (frame.origin.x != 0) {
        frame = CGRectMake(0, frame.origin.y, frame.size.width + frame.origin.x * 2, frame.size.height);
    }
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //修复iOS11之后导航栏变化，导致左右有margin的问题
    if ([TTDeviceHelper OSVersionNumber] >= 11.0){
        CGFloat kSearchBarLeftPad = 15;
        CGRect contentViewFrame = [self.contentView convertRect:self.contentView.bounds toView:nil];
        CGFloat originXOffset = kSearchBarLeftPad - CGRectGetMinX(contentViewFrame);
        CGRect inputBackgroundView = CGRectMake(kSearchBarLeftPad, CGRectGetMinY(contentViewFrame) + 8, CGRectGetWidth(contentViewFrame) - 2 * originXOffset, CGRectGetHeight(contentViewFrame) - 16);
        self.inputBackgroundView.frame = [self.contentView convertRect:inputBackgroundView fromView:nil];
        CGRect cancelButtonFrame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - self.editing * ((self.cancelButton.width) + kCancelButtonPadding) * self.showsCancelButton, 0, 50, self.height);
        cancelButtonFrame = [self convertRect:cancelButtonFrame fromView:nil];
        cancelButtonFrame.origin.y = 0;
        self.cancelButton.frame = cancelButtonFrame;
    }
    
    if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled] && self.useWhiteCancelButton) {
        self.inputBackgroundView.backgroundColorThemeKey = kColorBackground4;
        self.cancelButton.titleColorThemeKey = kColorText10;
        self.cancelButton.highlightedTitleColorThemeKey = kColorText10;
    }
}

@end
