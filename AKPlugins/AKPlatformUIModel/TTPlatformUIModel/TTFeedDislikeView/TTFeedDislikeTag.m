//
//  ExploreDislikeTag.m
//  Article
//
//  Created by Chen Hong on 14/11/20.
//
//

#import "TTFeedDislikeTag.h"

#import "TTFeedDislikeView.h"
#import "TTThemeConst.h"
#import "UIColor+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "TTDeviceUIUtils.h"

#define kCornerRadius 4.f

@interface TTFeedDislikeTag ()

@property(nonatomic,strong)CAShapeLayer *borderLayer;

@end

@implementation TTFeedDislikeTag

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                self.backgroundColor = [UIColor tt_themedColorForKey:@"F8F8F8"];
            }
            else {
                self.backgroundColor = [UIColor colorWithHexString:@"303030"];
            }
            [self.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]]];
            self.layer.cornerRadius = kCornerRadius;

        }
        else {
            self.backgroundColor = [UIColor clearColor];
            [self.titleLabel setFont:[UIFont systemFontOfSize:[self fontSizeForTag]]];
            self.layer.cornerRadius = 6.f;
        }
        
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];

        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
        
        [self themeChanged:nil];
    }
    return self;
}

- (void)setDislikeWord:(TTFeedDislikeWord *)word {
    _dislikeWord = word;
    [self setTitle:word.name forState:UIControlStateNormal];
    self.selected = _dislikeWord.isSelected;
    //CGSize size = sizeOfContent(word.name, 999.f, self.titleLabel.font);
    //self.frame = CGRectMake(0, 0, MAX([self paddingX]*2 + size.width, [self minTagWidth]), [ExploreDislikeTag tagHeight]);
}

+ (CGFloat)tagHeight {
    static CGFloat h = 0;
    if (h == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            h = 26.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            h = 28.f;
        } else {
            h = 24.f;
        }
    }
    return h;
}

- (CGFloat)minTagWidth {
    static CGFloat w = 0;
    if (w == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            w = 54.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            w = 56.f;
        } else {
            w = 52.f;
        }
    }
    return w;
}

- (CGFloat)paddingX {
    static CGFloat padding = 0;
    if (padding == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            padding = 6.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            padding = 7.f;
        } else {
            padding = 5.f;
        }
    }
    return padding;
}

- (CGFloat)fontSizeForTag {
    static CGFloat fontSize = 0;
    if (fontSize == 0) {
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone6
            fontSize = 14.f;
        } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) { // iPhone6 plus
            fontSize = 14.f;
        } else {
            fontSize = 12.f;
        }
    }
    return fontSize;
}

- (void)refreshBorder {
    /*
    if (![TTDeviceHelper isPadDevice] && [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        if (self.isSelected) {
            self.layer.borderColor = [UIColor colorWithHexString:@"935656"].CGColor;
        } else {
            self.layer.borderColor = [UIColor colorWithHexString:@"707070"].CGColor;
        }
    } else {
        if (self.isSelected) {
            self.layer.borderColor = [UIColor colorWithHexString:@"fe3232"].CGColor;
        } else {
            self.layer.borderColor = [UIColor colorWithHexString:@"cacaca"].CGColor;
        }
    }*/
    
    if (self.isSelected) {
        if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
            self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine2].CGColor;
        }
        else {
            self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1Selected].CGColor;
        }
    } else {
        self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:kCornerRadius].CGPath;
    _borderLayer.frame = self.bounds;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
        if (self.isSelected) {
            self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            self.layer.borderWidth = 1.f;
            [self.titleLabel setFont:[UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]]];
        }
        else {
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                self.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
            }
            else {
                self.backgroundColor = [UIColor colorWithHexString:@"303030"];
            }
            self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
            [self.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]]];
        }
    }
    [self refreshBorder];
}

- (void)themeChanged:(NSNotification *)notification
{
    /*
    if (![TTDeviceHelper isPadDevice] && [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        if (self.isSelected) {
            self.layer.borderColor = [UIColor colorWithHexString:@"935656"].CGColor;
        } else {
            self.layer.borderColor = [UIColor colorWithHexString:@"707070"].CGColor;
        }

        [self setTitleColor:[UIColor colorWithHexString:@"935656"] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithHexString:@"935656"] forState:UIControlStateSelected];
    } else {
        if (self.isSelected) {
            self.layer.borderColor = [UIColor colorWithHexString:@"fe3232"].CGColor;
        } else {
            self.layer.borderColor = [UIColor colorWithHexString:@"cacaca"].CGColor;
        }

        [self setTitleColor:[UIColor colorWithHexString:@"fe3232"] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithHexString:@"fe3232"] forState:UIControlStateSelected];
    }*/
    
    if ([TTFeedDislikeView isFeedDislikeRefactorEnabled]) {
        [self setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor tt_themedColorForKey:kColorText4] forState:UIControlStateSelected];
    }
    else {
        [self setTitleColor:[UIColor tt_themedColorForKey:kColorText2] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor tt_themedColorForKey:kColorText1Selected] forState:UIControlStateSelected];
    }
    
    [self refreshBorder];
}

@end
