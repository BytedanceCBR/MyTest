//
//  TTEditUserProfileCell.m
//  Article
//
//  Created by Zuopeng Liu on 7/14/16.
//
//

#import "TTEditUserProfileCell.h"


@implementation TTEditUserProfileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.needMargin = YES;
        self.bgView = [[SSThemedView alloc] initWithFrame:self.bounds];
        self.backgroundView = self.bgView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.bgView.backgroundColorThemeKey = kColorBackground4;
        self.shouldHighlight = YES;
        
        self.topLine = [[SSThemedView alloc] initWithFrame:[self _topLineFrame]]; // 需要重新设置frame
        self.topLine.backgroundColorThemeKey = kColorLine1;
        self.topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.topLine];
        
        self.bottomLine = [[SSThemedView alloc] initWithFrame:[self _bottomLineFrame]];
        self.bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.bottomLine.backgroundColorThemeKey = kColorLine1;
        [self.contentView addSubview:self.bottomLine];
    }
    
    return self;
}

- (CGRect)_bottomLineFrame {
    return CGRectMake(0, CGRectGetHeight(self.contentView.frame) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.contentView.frame), [TTDeviceHelper ssOnePixel]);
}

- (CGRect)_topLineFrame {
    return CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), [TTDeviceHelper ssOnePixel]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topLine.frame = [self _topLineFrame];
    self.bottomLine.frame = [self _bottomLineFrame];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (self.shouldHighlight) {
        [super setHighlighted:highlighted animated:animated];
        self.bgView.backgroundColorThemeKey = highlighted ? kColorBackground4Highlighted : kColorBackground4;
    }
}


#pragma mark - height 

+ (CGFloat)heightOfAccountCell {
    if ([TTDeviceHelper isPadDevice]) {
        return 90.0f;
    }
    
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 58.f;
    } else {
        return 50.f;
    }
}

+ (CGFloat)heightOfLogoutCell {
    if ([TTDeviceHelper isPadDevice]) {
        return 90.0f;
    }
    
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 58.f;
    } else {
        return 50.f;
    }
}

+ (CGFloat)fontSizeOfCellLeftLabel {
    if ([TTDeviceHelper isPadDevice]) {
        return 22.0f;
    }
    
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 18.f;
    } else {
        return 16.f;
    }
}

+ (CGFloat)fontSizeOfCellRightLabel {
    if ([TTDeviceHelper isPadDevice]) {
        return 20.0f;
    }
    
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 16.f;
    } else {
        return 14.f;
    }
}

@end
