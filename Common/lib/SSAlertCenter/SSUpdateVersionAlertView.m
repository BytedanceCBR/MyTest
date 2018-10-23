//
//  SSUpdateVersionAlertView.m
//  Article
//
//  Created by Dianwei on 14-10-28.
//
//

#import "SSUpdateVersionAlertView.h"
#import "NewVersionAlertModel.h"
#import "NewVersionAlertManager.h"
 
#import "TTStringHelper.h"
#import "TTLabelTextHelper.h"


@interface UpdateNewVersionConfirmButton : SSThemedButton

@end

@implementation UpdateNewVersionConfirmButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    
    
    CGRect old = [super titleRectForContentRect:contentRect];
//    return old;
    
    float sqrt2 = sqrt(2);
    float origin = (sqrt2 - 1) * self.width / (2 * sqrt2);
    
    float width = self.width / sqrt2;
    CGRect result = CGRectMake(origin, origin, width, width);
    NSLog(@"old:%@, result:%@", NSStringFromCGRect(old), NSStringFromCGRect(result));
    return result;
}

@end

static float kDescriptionLabelPadding = 30;
#define DegreesToRadians(degrees) (degrees * M_PI / 180)
#define kDescLabelFontSize 13

@interface SSUpdateVersionAlertView(){
    NewVersionAlertModel *_alertModel;
}

@property(nonatomic, strong)SSThemedImageView *backgroundImageView;
@property(nonatomic, strong)SSThemedLabel *titleLabel;
@property(nonatomic, strong)SSThemedLabel *descriptionLabel;
@property(nonatomic, strong)UpdateNewVersionConfirmButton *confirmButton;
@property(nonatomic, strong)SSThemedButton *cancelButton;
@property(nonatomic, strong)void(^didFinishBlock)(void);
@property(nonatomic, strong)void(^didCancelBlock)(void);

@end

@implementation SSUpdateVersionAlertView

- (instancetype)initWithDidFinishBlock:(void(^)())finishBlock didCancelBlock:(void(^)())cancelBlock
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        self.didFinishBlock = finishBlock;
        self.didCancelBlock = cancelBlock;
        SSThemedView *maskView = [[SSThemedView alloc] init];
        maskView.alpha = .8f;
        maskView.backgroundColors = @[@"000000"];
        maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:maskView];
        
        self.backgroundImageView = [[SSThemedImageView alloc] init];
        _backgroundImageView.imageName = @"mail_upgrade_introduce.png";
        _backgroundImageView.userInteractionEnabled = YES;
        [_backgroundImageView sizeToFit];
        [self addSubview:_backgroundImageView];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:23];
        _titleLabel.textColors = @[@"464646"];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_backgroundImageView addSubview:_titleLabel];
        
        self.descriptionLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.textColors = @[@"232323"];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        
        [_backgroundImageView addSubview:_descriptionLabel];
        
        self.confirmButton = [[UpdateNewVersionConfirmButton alloc] init];
        _confirmButton.backgroundImageName = @"default_upgrade_introduce.png";
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_confirmButton setTitleColors:@[@"fafafa"]];
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton setTitle:NSLocalizedString(@"立即升级", @"") forState:UIControlStateNormal];
        _confirmButton.titleLabel.numberOfLines = 0;
        [_backgroundImageView addSubview:_confirmButton];
        _confirmButton.size = CGSizeMake(83, 83);
        
        _confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.cancelButton = [[SSThemedButton alloc] init];
        _cancelButton.titleColors = @[@"ff6d6d"];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundImageView addSubview:_cancelButton];
    }
    
    return self;
}

- (void)reloadNewVersionAlertModel:(NewVersionAlertModel *)alertModel
{
    _alertModel = alertModel;
    if(!isEmptyString(alertModel.title))
    {
        _titleLabel.text = alertModel.title;
    }
    else
    {
        _titleLabel.text = @"";
    }
    
    [_titleLabel sizeToFit];
    _titleLabel.top = 55;
    _titleLabel.centerX = (_backgroundImageView.width) / 2;
    
    _descriptionLabel.text = alertModel.message;
    
    float descWidth = (_backgroundImageView.width) -  kDescriptionLabelPadding * 2;
    CGFloat descHeight = [TTLabelTextHelper heightOfText:_descriptionLabel.text fontSize:kDescLabelFontSize forWidth:descWidth];
    _descriptionLabel.frame = CGRectMake(kDescriptionLabelPadding, 94, descWidth, descHeight);
    
    
    _confirmButton.top = (_backgroundImageView.height) - (_confirmButton.height) - 60;
    _confirmButton.centerX = (_backgroundImageView.width) / 2;
    NSString *cancelText = nil;
    if(alertModel.forceUpdate)
    {
        cancelText = NSLocalizedString(@"退出应用", @"");
        [_cancelButton setTitle:NSLocalizedString(@"退出应用", @"") forState:UIControlStateNormal];
    }
    else
    {
        cancelText = NSLocalizedString(@"以后再说", @"");
        [_cancelButton setTitle:NSLocalizedString(@"以后再说", @"") forState:UIControlStateNormal];
    }
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:cancelText];
    [aString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, cancelText.length)];
    [_cancelButton setAttributedTitle:aString forState:UIControlStateNormal];
    
    [_cancelButton sizeToFit];
    
    
    
    
    _cancelButton.top = (_backgroundImageView.height) - (_cancelButton.height) - 18;
    _cancelButton.centerX = (_backgroundImageView.width) / 2;
    
    
}

- (void)confirm:(id)sender
{
    NSString *actionStr = _alertModel.actions;
    NSArray *actionArray = [actionStr componentsSeparatedByString:@","];
    if(actionArray.count > 0)
    {
        updateNewVersionLastDelayDaysAndCheckRecordLastTime(_alertModel.versionNameNew);
        
        NSString *url = [[actionArray objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([url length] > 0)
        {
            if(_alertModel.forceUpdate)
            {
                ssTrackEvent(@"upgrade_pop", @"forcible_accept");
            }
            else
            {
                ssTrackEvent(@"upgrade_pop", @"accept");
            }
            
            [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:url]];
        }
    }
    
    if(_didFinishBlock)
    {
        _didFinishBlock();
    }
    
    [self close];
}

- (void)cancel:(id)sender
{
    updateNewVersionLastDelayDaysAndCheckRecordLastTime(_alertModel.versionNameNew);
    
    if(_didCancelBlock)
    {
        _didCancelBlock();
    }
    
    if([_alertModel forceUpdate])
    {
        ssTrackEvent(@"upgrade_pop", @"forcible_refuse");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
        
        
    }
    else
    {
        ssTrackEvent(@"upgrade_pop", @"refuse");
        [self close];
    }
}

- (void)show
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    self.center = CGPointMake((keyWindow.width) / 2, (keyWindow.height) / 2);
    [keyWindow addSubview:self];
    [self updateFrames];
    _backgroundImageView.center = CGPointMake(self.width / 2, self.height / 2);
    
    if(_alertModel.forceUpdate)
    {
        ssTrackEvent(@"upgrade_pop", @"forcible_show");
    }
    else
    {
        ssTrackEvent(@"upgrade_pop", @"show");
    }
}

- (void)close
{
    [self removeFromSuperview];
}

- (void)updateFrames {
    
    self.transform = [self transformForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    self.frame = [self frameForSelf];
    
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
    
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-DegreesToRadians(90));
            
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(DegreesToRadians(90));
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(DegreesToRadians(180));
            
        case UIInterfaceOrientationPortrait:
        default:
            return CGAffineTransformMakeRotation(DegreesToRadians(0));
    }
}

- (CGRect)frameForSelf
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat screenWidth = (window.width);
    CGFloat screenHeight = (window.height);
    CGRect frame = CGRectMake(0, 0, screenWidth, screenHeight);
    return frame;
}


@end
