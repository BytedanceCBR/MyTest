//
//  TTIMChatEmptyView.m
//  Article
//
//  Created by lizhuoli on 2017/8/11.
//
//

#import "TTIMChatEmptyView.h"

#define kImageViewWidth [TTDeviceUIUtils tt_newPadding:90.f]
#define kImageViewHeight [TTDeviceUIUtils tt_newPadding:90.f]
#define kImageViewTopPadding [TTDeviceUIUtils tt_newPadding:120.f]
#define kLabelTopPadding [TTDeviceUIUtils tt_newPadding:14.f]
#define kLabelFontSize [TTDeviceUIUtils tt_newFontSize:14.f]

@implementation TTIMChatEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColorThemeKey = kColorBackground4;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.imageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, kImageViewWidth, kImageViewHeight)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    
    self.label = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    self.label.lineBreakMode = NSLineBreakByTruncatingTail;
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.numberOfLines = 1;
    self.label.font = [UIFont systemFontOfSize:kLabelFontSize];
    self.label.textColorThemeKey = kColorText1;
    [self addSubview:self.label];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.centerX = self.centerX;
    self.imageView.top = kImageViewTopPadding;
    self.label.centerX = self.centerX;
    self.label.top = self.imageView.bottom + kLabelTopPadding;
}

@end
