//
//  TTEditUserProfileSectionView.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTEditUserProfileSectionView.h"



@implementation TTEditUserProfileSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
         self.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.text = @"账号绑定";
        _titleLabel.textColorThemeKey = kColorText3;
        _titleLabel.font = [UIFont systemFontOfSize:[self.class fontSizeOfAccountSetting]];
        [_titleLabel sizeToFit];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLabel.frame = CGRectMake([self.class insetLeft], 0 , CGRectGetWidth(_titleLabel.frame), CGRectGetHeight(self.contentView.frame));
}

+ (CGFloat)insetLeft
{
    return [TTDeviceUIUtils tt_padding:30.f/2];
}

+ (CGFloat)fontSizeOfAccountSetting
{
    return [TTDeviceUIUtils tt_padding:24.f/2];
}

+ (CGFloat)defaultSectionHeight
{
    return [TTDeviceUIUtils tt_padding:72.f/2];
}

@end
