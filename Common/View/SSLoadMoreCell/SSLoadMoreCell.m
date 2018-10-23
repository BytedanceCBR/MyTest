//
//  LoadMoreCell.m
//  Essay
//
//  Created by Tianhang Yu on 12-3-6.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "SSLoadMoreCell.h"
 
#import "TTThemeManager.h"

@interface SSLoadMoreCell () {
    
    UIActivityIndicatorView *_indicator;
    SSThemedLabel *_label;
}

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation SSLoadMoreCell
@synthesize indicator = _indicator;

- (void)dealloc
{
    [_indicator stopAnimating];
}

- (void)hiddenLabel:(BOOL)hidden
{
    _label.hidden = hidden;
}

- (void)startAnimating
{
    if (!self.indicator.isAnimating) {
        [self.indicator startAnimating];
    }
}

- (void)stopAnimating
{
    [self.indicator stopAnimating];
}

- (BOOL)isAnimating
{
    return [self.indicator isAnimating];
}

- (CGRect)_labelFrame
{
    if (self.labelStyle == SSLoadMoreCellLabelStyleAlignLeft) {
        return CGRectMake(kCellLeftPadding, 0, CGRectGetWidth(self.frame) - kCellLeftPadding, kLoadMoreCellHeight);
    }
    else if(self.labelStyle == SSLoadMoreCellLabelStyleAlignMiddle){
        [_label sizeToFit];
        return CGRectMake((self.width - (_label.width)) / 2, 0, (_label.width), kLoadMoreCellHeight);
    }
    return CGRectMake(kCellLeftPadding, 0, CGRectGetWidth(self.frame) - kCellLeftPadding, kLoadMoreCellHeight);
}

- (void)addMoreLabel
{
    if (!_label) {
        _label = [[SSThemedLabel alloc] initWithFrame:[self _labelFrame]];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.font = [UIFont systemFontOfSize:16];
        _label.text = NSLocalizedString(@"点击加载更多", nil);
        _label.textColorThemeKey = kColorText5;
        _label.backgroundColor = [UIColor clearColor];
        _label.hidden = YES;
        [self addSubview:_label];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _label.frame = [self _labelFrame];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        
        [self themeChanged:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    if (!isEmptyString(_customSSLoadMoreCellBgColorString)) {
        self.backgroundView.backgroundColor = [UIColor tt_themedColorForKey:_customSSLoadMoreCellBgColorString];
    }
    else {
        self.backgroundView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"ffffff00" nightColorName:@"252525"]];
    }
    
    if (!isEmptyString(_customSSLoadMoreCellSelectBgColorString)) {
        self.selectedBackgroundView.backgroundColor = [UIColor tt_themedColorForKey:_customSSLoadMoreCellSelectBgColorString];
    }
    else {
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"e6e6e6" nightColorName:@"303030"]];
    }
    
    [_indicator removeFromSuperview];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else {
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    _indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    _indicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:_indicator];
    [_indicator startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
