//
//  TTTagButton.m
//  Article
//
//  Created by fengyadong on 16/5/26.
//
//

#import "TTTagButton.h"
#import "TTTagItem.h"
#import "TTDeviceHelper.h"

@interface TTTagButton()

@property (nonatomic, strong) TTTagItem *tagItem;

@end

@implementation TTTagButton

#pragma mark -- Update

- (void)updateWithTagItem:(TTTagItem *)tagItem {
    self.tagItem = tagItem;
    [self setTitle:tagItem.text forState:UIControlStateNormal];
    self.titleLabel.font = tagItem.font ?: [UIFont systemFontOfSize:tagItem.fontSize];
    self.backgroundColorThemeKey = tagItem.bgColorThemedKey;
    self.highlightedBackgroundColorThemeKey = tagItem.highlightedBgColorThemedKey;
    self.titleColorThemeKey = tagItem.textColorThemedKey;
    self.highlightedTitleColorThemeKey = tagItem.highlightedTextColorThemedKey;
    self.borderColorThemeKey = tagItem.borderColorThemedKey;
    self.highlightedBorderColorThemeKey = tagItem.highlightedBorderColorThemedKey;
    self.layer.cornerRadius = tagItem.cornerRadius;
    self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.userInteractionEnabled = self.tagItem.style  != TTTagDisplayButtonStyle;
    self.selected = tagItem.isSelected;
    [self changeBackgroundColorIfNeeded];
    [self addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
    
    if (tagItem.buttonImg) {
        [self setImage:tagItem.buttonImg forState:UIControlStateNormal];
        CGSize size = [tagItem.text boundingRectWithSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width - tagItem.padding.left - tagItem.padding.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
        
        self.imageEdgeInsets = UIEdgeInsetsMake(0, size.width + tagItem.textImageInterval, 0, -size.width - tagItem.textImageInterval);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -tagItem.buttonImg.size.width, 0, tagItem.buttonImg.size.width);
    }
}

- (void)changeStateAndBackgroundColorIfNeeded {
    self.selected = !self.selected;
    self.tagItem.isSelected = self.selected;
    if(self.tagItem.stateChanged) {
        self.tagItem.stateChanged(self.isSelected);
    }
    [self changeBackgroundColorIfNeeded];
}

- (void)changeBackgroundColorIfNeeded {
    if (self.tagItem.style == TTTagSelectedButtonStyle) {
        self.highlighted = NO;
    }
    if (self.self.tagItem.style  == TTTagSelectedButtonStyle) {
        self.backgroundColor = self.isSelected ? SSGetThemedColorWithKey(self.tagItem.selectedBgColorThemedKey) : SSGetThemedColorWithKey(self.tagItem.bgColorThemedKey);
        [self setTitleColor:self.isSelected ? SSGetThemedColorWithKey(self.tagItem.selectedTextColorKey) : SSGetThemedColorWithKey(self.tagItem.textColorThemedKey) forState:self.state];
        self.backgroundColorThemeKey = self.isSelected ? self.tagItem.selectedBgColorThemedKey : self.tagItem.bgColorThemedKey;
        self.highlightedBackgroundColorThemeKey = self.isSelected ? self.tagItem.selectedHighlightedBgColorThemedKey : self.tagItem.highlightedBgColorThemedKey;
        self.borderColorThemeKey = self.isSelected ? self.tagItem.selectedBorderColorThemedKey : self.tagItem.borderColorThemedKey;
    }
}

#pragma mark -- Tap Response

- (void)didTap:(id)sender {
    if (sender) {
        if (self.tagItem.action) {
            self.tagItem.action();
        }
    }
}

#pragma mark -- Touch

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self changeStateAndBackgroundColorIfNeeded];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self changeStateAndBackgroundColorIfNeeded];
}

@end
