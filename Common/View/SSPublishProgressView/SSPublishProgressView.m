//
//  SSPublishProgressView.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-9.
//
//

#import "SSPublishProgressView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
 
#import "UIColor+TTThemeExtension.h"

@implementation SSPublishProgressView


- (void)dealloc
{
    self.progressBgView = nil;
    self.progressFgView = nil;
    self.progressLabel = nil;
    self.titleLabel = nil;
    self.cancelButton = nil;
    self.bgImgView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildViews];
    }
    return self;
}

- (void)buildViews
{
    float titleLabelFontSize = 16.f;
    float titleLabelOriginY = 8.f;
    float progressLabelFontSize = 20.f;
    float cancelButtonTitleFontSize = 14.f;
    if ([TTDeviceHelper isPadDevice]) {
        titleLabelFontSize = 24.f;
        titleLabelOriginY = 12.f;
        progressLabelFontSize = 30.f;
        cancelButtonTitleFontSize = 21.f;
    }
    UIImage * image = [UIImage themedImageNamed:@"refer_backdrop.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5f - 1, image.size.width * 0.5f - 1, image.size.height * 0.5f, image.size.width * 0.5f)];
    self.bgImgView = [[UIImageView alloc] initWithImage:image];
    //_bgImgView.contentStretch = CGRectMake(0.45, 0.45, 0.05, 0.05);
    _bgImgView.frame = [self frameForBGImgView];
    _bgImgView.userInteractionEnabled = YES;
    [self addSubview:_bgImgView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_titleLabel setText:NSLocalizedString(@"提交中...", nil)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:titleLabelFontSize];
    [_titleLabel sizeToFit];
    _titleLabel.origin = CGPointMake(((_bgImgView.width) - (_titleLabel.width)) / 2.f, titleLabelOriginY);
    [_bgImgView addSubview:_titleLabel];
    
    self.progressLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [_progressLabel setText:@"000%"];
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.font = [UIFont systemFontOfSize:progressLabelFontSize];
    [_progressLabel sizeToFit];
    _progressLabel.origin = CGPointMake(((_bgImgView.width) - (_progressLabel.width)) / 2.f, (_titleLabel.bottom) + 10);
    [_bgImgView addSubview:_progressLabel];
    
    image = [UIImage themedImageNamed:@"delivery_schedule_backdrop.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5f - 1, image.size.width * 0.5f - 1, image.size.height * 0.5f, image.size.width * 0.5f)];
    self.progressBgView = [[UIImageView alloc] initWithImage:image];
    //_progressBgView.contentStretch = CGRectMake(0.45, 0.45, 0.05, 0.05);
    _progressBgView.frame = CGRectMake(14.f, (_progressLabel.bottom) + 7, (_bgImgView.width) - 28, (_progressBgView.height));
    [_bgImgView addSubview:_progressBgView];
    
    image = [UIImage themedImageNamed:@"delivery_schedule.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5f - 1, image.size.width * 0.5f - 1, image.size.height * 0.5f, image.size.width * 0.5f)];
    self.progressFgView = [[UIImageView alloc] initWithImage:image];
    //_progressFgView.contentStretch = CGRectMake(0.45, 0.45, 0.05, 0.05);
    [self setProgress:0.f];
    [_bgImgView addSubview:_progressFgView];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:NSLocalizedString(@"取  消", nil) forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:cancelButtonTitleFontSize]];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage * cancelBgNormalImg = [[UIImage themedImageNamed:@"refer_button.png"] stretchableImageWithLeftCapWidth:5.f topCapHeight:5.f];
    [_cancelButton setBackgroundImage:cancelBgNormalImg forState:UIControlStateNormal];
    UIImage * cancelBgHightlightImg = [[UIImage themedImageNamed:@"cancelbtn_progressbar_repost_press.png"] stretchableImageWithLeftCapWidth:5.f topCapHeight:5.f];
    [_cancelButton setBackgroundImage:cancelBgHightlightImg forState:UIControlStateHighlighted];
    [_cancelButton sizeToFit];
    _cancelButton.width = 90.f;
    _cancelButton.height = 44.f;
    _cancelButton.origin = CGPointMake(((_bgImgView.width) - (_cancelButton.width))/2.f, (_bgImgView.height) - (_cancelButton.height) - 10.f);
    [_bgImgView addSubview:_cancelButton];
    
    [self reloadThemeUI];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _bgImgView.frame = [self frameForBGImgView];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"00000088" nightColorName:@"00000088"]];
    _titleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"444444" nightColorName:@"787e87"]];
    _progressLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"fafafa" nightColorName:@"787e87"]];
}

- (CGRect)frameForBGImgView
{
    CGRect rect;
    if ([TTDeviceHelper isPadDevice]) {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            rect = CGRectMake((self.frame.size.width - 360) / 2.f, 240.f, 360, 210);
        }
        else {
            rect = CGRectMake((self.frame.size.width - 360) / 2.f, 60.f, 360, 210);
        }
    }
    else {
        rect = CGRectMake((self.frame.size.width - 240) / 2.f, 44.f, 240, 140);
    }
    return rect;
}

- (void)addTarget:(id)target selecter:(SEL)sel
{
    [_cancelButton addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
}

- (void)setProgress:(CGFloat)progress
{
    CGFloat width = (_progressBgView.width) * progress;
    _progressFgView.frame = CGRectMake((_progressBgView.top), (_progressBgView.top), width, (_progressBgView.height));
    [_progressLabel setText:[NSString stringWithFormat:@"%.0f%%", progress * 100]];
}

@end
