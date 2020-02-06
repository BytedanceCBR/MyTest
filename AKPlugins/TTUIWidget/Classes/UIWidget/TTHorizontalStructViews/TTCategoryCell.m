//
//  TTCategoryCell.m
//  TTUIWidget
//
//  Created by lizhuoli on 2018/3/22.
//

#import "TTCategoryCell.h"
#import <Masonry/Masonry.h>
#import "TTBadgeNumberView.h"
#import "TTCategoryItem.h"
#import "TTDeviceHelper.h"

#define kTextFont [UIFont systemFontOfSize:15]
static const NSTimeInterval animateDuration = 0.3f;
static const CGFloat transformScale = 1.2f;

@implementation TTCategoryCell

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.animatedHighlighted = YES;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
        [self.maskLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleLabel);
        }];
        
        [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).offset(3);
            make.top.equalTo(self.contentView.mas_top).priorityLow();
        }];
        
        [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(12);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(15);
            make.width.mas_equalTo([TTDeviceHelper ssOnePixel]);
        }];
    }
    return self;
}

#pragma mark set/get
- (SSThemedLabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor redColor];
        _titleLabel.font = kTextFont;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedLabel *)maskLabel {
    if (_maskLabel == nil) {
        _maskLabel = [[SSThemedLabel alloc] init];
        _maskLabel.textAlignment = NSTextAlignmentCenter;
        _maskLabel.backgroundColor = [UIColor clearColor];
        _maskLabel.textColor = [UIColor redColor];
        _maskLabel.font = kTextFont;
        _maskLabel.alpha = 0;
        [self.contentView addSubview:_maskLabel];
    }
    return _maskLabel;
}

- (SSThemedView *)rightLine {
    if (_rightLine == nil) {
        _rightLine = [[SSThemedView alloc] init];
        _rightLine.backgroundColorThemeKey = kColorLine1;
        _rightLine.hidden = YES;
        [self.contentView addSubview:_rightLine];
    }
    return _rightLine;
}

- (TTBadgeNumberView *)badgeView {
    if (_badgeView == nil) {
        _badgeView = [[TTBadgeNumberView alloc] init];
        _badgeView.hidden = YES;
        [_badgeView setBadgeLabelFontSize:8];
        [self.contentView addSubview:_badgeView];
    }
    return _badgeView;
}

- (void)setCellItem:(TTCategoryItem *)cellItem {
    self.titleLabel.text = cellItem.title;
    self.maskLabel.text = cellItem.title;
    
    switch (cellItem.badgeStyle) {
        case TTCategoryItemBadgeStyleNone:
            self.badgeView.badgeNumber = TTBadgeNumberHidden;
            break;
        case TTCategoryItemBadgeStylePoint:
            self.badgeView.badgeNumber = TTBadgeNumberPoint;
            break;
        case TTCategoryItemBadgeStyleNumber:
            self.badgeView.badgeNumber = cellItem.badgeNum;
            break;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.enableHighlightedStatus) {
        [UIView animateWithDuration:(self.animatedHighlighted ? animateDuration : 0) animations:^{
            if (selected) {
                self.titleLabel.alpha = 0;
                self.maskLabel.alpha = 1;
                if (self.animatedBiggerState) {
                    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, transformScale, transformScale);
                }
            } else {
                self.titleLabel.alpha = 1;
                self.maskLabel.alpha = 0;
                if (self.animatedBiggerState) {
                    self.transform = CGAffineTransformIdentity;
                }
            }
        }];
    }
}

#pragma mark UI setting
- (void)setTabBarTextColor:(UIColor *)textColor maskColor:(UIColor *)maskColor lineColor:(UIColor *)lineColor {
    if (textColor) {
        self.titleLabel.textColor = textColor;
        self.titleLabel.highlightedTextColor = nil;
    }
    if (maskColor) {
        self.maskLabel.textColor = maskColor;
        self.maskLabel.highlightedTextColor = nil;
    }
    if (lineColor) {
        self.rightLine.backgroundColor = lineColor;
    }
}

- (void)setTabBarTextColorThemeKey:(NSString *)textColorKey maskColorThemeKey:(NSString *)maskColorKey lineColorThemeKey:(NSString *)lineColorKey {
    if (!isEmptyString(textColorKey)) {
        self.titleLabel.textColorThemeKey = textColorKey;
    }
    if (!isEmptyString(maskColorKey)) {
        self.maskLabel.textColorThemeKey = maskColorKey;
    }
    if (!isEmptyString(lineColorKey)) {
        self.rightLine.backgroundColorThemeKey = lineColorKey;
    }
}

- (void)setTabBarTextFont:(UIFont *)font {
    if (font) {
        self.titleLabel.font = font;
        self.maskLabel.font = font;
        //        [self.rightLine mas_updateConstraints:^(MASConstraintMaker *make) {
        //            make.height.mas_equalTo(font.pointSize);
        //        }];
    }
}

- (void)setTabBarTextFont:(UIFont *)textFont maskTextFont:(UIFont *)maskFont {
    if (textFont && maskFont) {
        self.titleLabel.font = textFont;
        self.maskLabel.font = maskFont;
    }
}

- (void)setBadgeViewOffset:(UIOffset)offset {
    [self.badgeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(offset.horizontal);
        make.top.equalTo(self.titleLabel.mas_top).offset(offset.vertical).priorityHigh();
    }];
    [self updateConstraintsIfNeeded];
}

- (void)setTitleLabelOffset:(UIOffset)offset {
    //    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    //        make.left.and.right.equalTo(self).offset(offset.horizontal);
    //    }];
}

@end
