//
//  TTADSplashSkipButton.m
//  Article
//
//  Created by matrixzk on 11/4/15.
//
//

#import "TTSplashADSkipButton.h"
#import "UIColor+TTThemeExtension.h"
 
#import "TTThemeConst.h"
#import "TTDeviceHelper.h"


@implementation TTSplashADSkipButton

- (instancetype)initWithFrame:(CGRect)frame {
    
    UILabel *_textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor tt_defaultColorForKey:kColorText8];
    _textLabel.text = NSLocalizedString(@"跳过广告", @"跳过广告");
    _textLabel.font = [UIFont systemFontOfSize:12.0f];
    
    CGFloat edgeInset = 10.0f;
    CGFloat btnHeight = 44.0f;
    CGFloat bgViewHeight = 24.0f;
    if ([TTDeviceHelper isPadDevice]) {
        edgeInset = 14;
        btnHeight = 58;
        bgViewHeight = 32;
        _textLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    [_textLabel sizeToFit];

    frame.size = CGSizeMake((_textLabel.width) + edgeInset * 2, btnHeight);
    
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, (btnHeight - bgViewHeight)/2,
                                                                  self.width, bgViewHeight)];
        bgView.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground16];// 0,0.2
        bgView.layer.cornerRadius = bgViewHeight/2;
        bgView.layer.masksToBounds = YES;
        bgView.userInteractionEnabled = NO;
        [self addSubview:bgView];
        
        _textLabel.frame = CGRectMake(edgeInset, 0, (_textLabel.width), (bgView.height));
        [bgView addSubview:_textLabel];
    }
    return self;
}

@end
