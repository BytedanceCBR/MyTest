//
//  WDDetailSearchTitleView.m
//  Article
//
//  Created by xuzichao on 6/1/17.
//
//

#import "WDDetailSearchTitleView.h"

#import <TTThemed/SSThemed.h>
#import "TTDeviceHelper.h"

const CGFloat kWDDetailSearchTitleViewDefaultHeight = 28.f;
static const CGFloat kFontSize = 14.f;
static const CGFloat kMiddlePadding = 3.f;
static const CGFloat kHorizontalMargin = 59.f;

@interface WDDetailSearchTitleView ()

@property (nonatomic, strong) SSThemedButton * searchButton;

@end

@implementation WDDetailSearchTitleView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self addSubview:self.searchButton];
    }
    return self;
}

- (SSThemedButton *)searchButton {
    if (_searchButton == nil) {
        _searchButton = [[SSThemedButton alloc] initWithFrame:self.bounds];
        _searchButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _searchButton.contentEdgeInsets = UIEdgeInsetsMake(0, kHorizontalMargin, 0, kHorizontalMargin+kMiddlePadding);
        _searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, kMiddlePadding, 0, -kMiddlePadding);
        _searchButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _searchButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
        _searchButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _searchButton.borderColorThemeKey = kColorLine1;
        _searchButton.layer.cornerRadius = 4.f;
        _searchButton.titleColorThemeKey = kColorText1;
        _searchButton.backgroundColorThemeKey = kColorBackground3;
        _searchButton.disabledBackgroundColorThemeKey = kColorBackground3Highlighted;
        _searchButton.imageName = @"search_small";
        [_searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offset = 7.0f;
    if ([TTDeviceHelper is736Screen]) {
        offset = 3.0f;
    }
    self.searchButton.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds) - offset, CGRectGetHeight(self.bounds));
}

#pragma mark - UI layout

- (CGSize)sizeThatFits:(CGSize)size{
    CGSize resultSize = [self.searchButton sizeThatFits:size];
    resultSize.height = kWDDetailSearchTitleViewDefaultHeight;
    return resultSize;
}

- (CGSize)intrinsicContentSize {
    CGSize resultSize = [self.searchButton intrinsicContentSize];
    resultSize.height = kWDDetailSearchTitleViewDefaultHeight;
    return resultSize;
}

#pragma mark - Action

- (void)search:(id)sender {
    if (self.tap) {
        self.tap();
    }
}

#pragma mark - Public

- (void)setText:(NSString *)text {
    _text = text;
    [self.searchButton setTitle:_text forState:UIControlStateNormal];
    [self invalidateIntrinsicContentSize];
}

@end
