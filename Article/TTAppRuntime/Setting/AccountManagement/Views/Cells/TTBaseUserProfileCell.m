//
//  TTBaseUserProfileCell.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTBaseUserProfileCell.h"
#import "TTSettingConstants.h"


@interface TTBaseUserProfileCell ()
@property (nonatomic, strong) SSThemedView *topLine;
@property (nonatomic, strong) SSThemedView *bottomLine;
@end

@implementation TTBaseUserProfileCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        _cellSpearatorStyle = kTTCellSeparatorStyleBothFull;
        _topLineEnabled = YES;
        _bottomLineEnabled = YES;
        
        self.needMargin = YES;
        self.shouldHighlight = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
        
        self.bgView = [[SSThemedView alloc] initWithFrame:self.bounds];
        self.bgView.backgroundColorThemeKey = kColorBackground4;
        self.backgroundView = self.bgView;
        
        self.topLine = [[SSThemedView alloc] initWithFrame:[self rectForTop:YES]]; // 需要重新设置frame
        self.topLine.backgroundColorThemeKey = [self.class separatorThemeColorKey];
        self.topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.topLine];
        
        self.bottomLine = [[SSThemedView alloc] initWithFrame:[self rectForTop:NO]];
        self.bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.bottomLine.backgroundColorThemeKey = [self.class separatorThemeColorKey];
        [self.contentView addSubview:self.bottomLine];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _cellSpearatorStyle = kTTCellSeparatorStyleBothFull;
        _topLineEnabled = YES;
        _bottomLineEnabled = YES;
        
        self.needMargin = YES;
        self.shouldHighlight = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
        
        self.bgView = [[SSThemedView alloc] initWithFrame:self.bounds];
        self.bgView.backgroundColorThemeKey = kColorBackground4;
        self.backgroundView = self.bgView;
        
        self.topLine = [[SSThemedView alloc] initWithFrame:[self rectForTop:YES]]; // 需要重新设置frame
        self.topLine.backgroundColorThemeKey = [self.class separatorThemeColorKey];
        self.topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.topLine];
        
        self.bottomLine = [[SSThemedView alloc] initWithFrame:[self rectForTop:NO]];
        self.bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.bottomLine.backgroundColorThemeKey = [self.class separatorThemeColorKey];
        [self.contentView addSubview:self.bottomLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self relayoutIfNeeds];
}

- (void)themeChanged:(NSNotification *)notification {
    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

- (void)relayoutIfNeeds {
    self.topLine.hidden    = [self hiddenForTop:YES];
    self.bottomLine.hidden = [self hiddenForTop:NO];
    
    self.topLine.frame     = [self rectForTop:YES];
    self.bottomLine.frame  = [self rectForTop:NO];
}

- (CGFloat)insetLeftOfSeparator {
    return [TTDeviceUIUtils tt_padding:30.f/2];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (self.shouldHighlight) {
        [super setHighlighted:highlighted animated:animated];
        self.bgView.backgroundColorThemeKey = highlighted ? kColorBackground4Highlighted : kColorBackground4;
    }
}

- (void)setCellSpearatorStyle:(TTCellSeparatorStyle)cellSpearatorStyle {
    if (_cellSpearatorStyle != cellSpearatorStyle) {
        _cellSpearatorStyle = cellSpearatorStyle;
        
        [self relayoutIfNeeds];
    }
}

#pragma mark - private methods

- (CGRect)rectForTop:(BOOL)topOrBottom {
    CGFloat offsetX = [self insetXForTop:topOrBottom];
    return CGRectMake(offsetX, topOrBottom ? 0 : CGRectGetHeight(self.contentView.frame) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.contentView.frame) - offsetX, [TTDeviceHelper ssOnePixel]);
}

- (BOOL)hiddenForTop:(BOOL)topOrBottom {
    BOOL hidden = NO;
    if (topOrBottom) {
        switch (_cellSpearatorStyle) {
            case kTTCellSeparatorStyleTopFull:
            case kTTCellSeparatorStyleTopFullBottomPart:
            case kTTCellSeparatorStyleBothFull:
            case kTTCellSeparatorStyleTopPart:
            case kTTCellSeparatorStyleTopPartBottomFull:
            case kTTCellSeparatorStyleBothPart: {
                hidden = NO;
                break;
            }
            case kTTCellSeparatorStyleBothNone:
            case kTTCellSeparatorStyleBottomFull:
            case kTTCellSeparatorStyleBottomPart: {
                hidden = YES;
                break;
            }
        }
    } else {
        switch (_cellSpearatorStyle) {
            case kTTCellSeparatorStyleBottomPart:
            case kTTCellSeparatorStyleTopFullBottomPart:
            case kTTCellSeparatorStyleBothPart:
            case kTTCellSeparatorStyleBottomFull:
            case kTTCellSeparatorStyleTopPartBottomFull:
            case kTTCellSeparatorStyleBothFull: {
                hidden = NO;
                break;
            }
            case kTTCellSeparatorStyleBothNone:
            case kTTCellSeparatorStyleTopFull:
            case kTTCellSeparatorStyleTopPart: {
                hidden = YES;
                break;
            }
        }
    }
    BOOL topOrBottomEnabled = topOrBottom ? _topLineEnabled : _bottomLineEnabled;
    return !(!hidden && topOrBottomEnabled);
}

- (CGFloat)insetXForTop:(BOOL)topOrBottom {
    CGFloat insetX = 0;
    if (topOrBottom) {
        switch (_cellSpearatorStyle) {
            case kTTCellSeparatorStyleTopFull:
            case kTTCellSeparatorStyleTopFullBottomPart:
            case kTTCellSeparatorStyleBothFull: {
                insetX = 0;
                break;
            }
            case kTTCellSeparatorStyleTopPart:
            case kTTCellSeparatorStyleTopPartBottomFull:
            case kTTCellSeparatorStyleBothPart: {
                insetX = [self insetLeftOfSeparator];
                break;
            }
            case kTTCellSeparatorStyleBothNone:
            case kTTCellSeparatorStyleBottomFull:
            case kTTCellSeparatorStyleBottomPart: {
                insetX = 0;
                break;
            }
        }
    } else {
        switch (_cellSpearatorStyle) {
            case kTTCellSeparatorStyleBottomPart:
            case kTTCellSeparatorStyleTopFullBottomPart:
            case kTTCellSeparatorStyleBothPart: {
                insetX = [self insetLeftOfSeparator];
                break;
            }
                
            case kTTCellSeparatorStyleBottomFull:
            case kTTCellSeparatorStyleTopPartBottomFull:
            case kTTCellSeparatorStyleBothFull: {
                insetX = 0;
                break;
            }
            case kTTCellSeparatorStyleBothNone:
            case kTTCellSeparatorStyleTopFull:
            case kTTCellSeparatorStyleTopPart: {
                insetX = 0;
                break;
            }
        }
    }
    return insetX;
}

#pragma mark - class methods

+ (NSString *)separatorThemeColorKey {
    return kColorLine1;
}

+ (TTCellSeparatorStyle)separatorStyleForPosition:(TTCellPositionType)position {
    TTCellSeparatorStyle separatorStyle = kTTCellSeparatorStyleBothNone;
    switch (position) {
        case kTTCellPositionTypeFirst: {
            separatorStyle = kTTCellSeparatorStyleTopFullBottomPart;
        }
            break;
        case kTTCellPositionTypeMiddle: {
            separatorStyle = kTTCellSeparatorStyleBottomPart;
        }
            break;
        case kTTCellPositionTypeLast: {
            separatorStyle = kTTCellSeparatorStyleBottomFull;
        }
            break;
        case kTTCellPositionTypeFirstAndLast: {
            separatorStyle = kTTCellSeparatorStyleBothFull;
        }
            break;
    }
    return separatorStyle;
}

+ (CGFloat)cellHeight {
     return [TTDeviceUIUtils tt_padding:kTTSettingCellHeight];
}

+ (CGFloat)thumbnailHeight {
    return [TTDeviceUIUtils tt_padding:48.f/2];
}

+ (CGFloat)fontSizeOfTitle {
    return [TTDeviceUIUtils tt_fontSize:kTTSettingTitleFontSize];
}

+ (CGFloat)fontSizeOfContent {
    return [TTDeviceUIUtils tt_fontSize:kTTSettingContentFontSize];
}

+ (CGFloat)spacingToMargin {
    return [TTDeviceUIUtils tt_padding:kTTSettingInsetLeft];
}

+ (CGFloat)spacingOfText {
    return [TTDeviceUIUtils tt_padding:kTTSettingSpacingOfTextAndContent];
}

+ (CGFloat)spacingOfTextArrow {
    return [TTDeviceUIUtils tt_padding:kTTSettingSpacingOfContentAndArrow];
}

+ (NSString *)titleColorKey {
    return kTTSettingTitleColorKey;
}

+ (NSString *)contentColorKey {
    return kTTSettingContentColorKey;
}
@end
