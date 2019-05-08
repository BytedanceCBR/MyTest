//
//  TTAuthorizeHintView.m
//  Article
//
//  Created by 邱鑫玥 on 16/6/17.
//
//

#import "TTAuthorizeHintView.h"
#import "TTKeyboardListener.h"
#import "TTDeviceUIUtils.h"
#import "TTThemeManager.h"
#import "TTLabel.h"
#import <FLAnimatedImageView.h>
#import <FLAnimatedImage.h>
#import <UIImageView+WebCache.h>
#import "UIViewAdditions.h"


#define DegreesToRadians(degrees) (degrees * M_PI / 180)


@interface TTAuthAnimatedImageView : SSThemedImageView
@property (nonatomic, strong) FLAnimatedImageView *auth_animatedImageView;
@end

@implementation TTAuthAnimatedImageView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_auth_animatedImageView) {
        _auth_animatedImageView.frame = self.bounds;
    }
}

- (FLAnimatedImageView *)auth_animatedImageView
{
    if (!_auth_animatedImageView) {
        FLAnimatedImageView *aniImageView = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        
        _auth_animatedImageView = aniImageView;
    }
    if (!_auth_animatedImageView.superview) {
        [self addSubview:_auth_animatedImageView];
        [self bringSubviewToFront:_auth_animatedImageView];
    }
    
    return _auth_animatedImageView;
}

@end

@interface TTAuthorizeHintView()

@property (nonatomic,strong,nonnull) SSThemedView *centerView;
@property (strong,nonatomic,nonnull) SSThemedImageView *imageView;
@property (strong,nonatomic,nonnull) SSThemedLabel *titleLabel;
@property (strong,nonatomic,nonnull) TTLabel *messageLabel;
@property (nonatomic,strong,nonnull) SSThemedButton *cancelButton;
@property (nonatomic,strong,nonnull) SSThemedImageView *cancelImageView;
@property (nonatomic,strong,nonnull) SSThemedButton *doneButton;
@property (nonatomic,strong,nullable) TTAuthorizeHintComplete
authorizeHintComplete;

@property (nonatomic, assign) BOOL showGifImage;
@end

@implementation TTAuthorizeHintView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _showGifImage = NO;
        
        [self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
        [self setTintColor:[UIColor clearColor]];
        
        _centerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [TTDeviceUIUtils tt_padding:270.f], [TTDeviceUIUtils tt_padding:395.f])];
        
        _centerView.layer.cornerRadius = [TTDeviceUIUtils tt_padding:12.f];
        _centerView.backgroundColorThemeKey = kColorBackground4;
        _centerView.clipsToBounds = YES;
        _centerView.center = self.center;
        
        [self addSubview:_centerView];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

- (instancetype)initAuthorizeHintWithTitle:(NSString *)title
                                   message:(NSString *)message
                                     image:(id)imageObject /* imageURL or UIImage */
                           confirmBtnTitle:(NSString *)confirmBtnTitle
                                  animated:(BOOL)animated
                                 completed:(TTAuthorizeHintComplete)completed
{
    if ((self = [self init])) {
        TTAuthAnimatedImageView *aniImageView = [[TTAuthAnimatedImageView alloc] init];
        
        if ([imageObject isKindOfClass:[NSURL class]]) {
            [aniImageView.auth_animatedImageView sd_setImageWithURL:(NSURL *)imageObject];
        } else if ([imageObject isKindOfClass:[NSString class]]) {
            [aniImageView.auth_animatedImageView sd_setImageWithURL:[NSURL URLWithString:(NSString *)imageObject]];
        } else if ([imageObject isKindOfClass:[UIImage class]]) {
            aniImageView.image = (UIImage *)imageObject;
        } else if ([imageObject isKindOfClass:[FLAnimatedImage class]]) {
            aniImageView.auth_animatedImageView.animatedImage = (FLAnimatedImage *)imageObject;
        }
        
        _imageView = aniImageView;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.frame = CGRectMake(0, [TTDeviceUIUtils tt_padding:36], [TTDeviceUIUtils tt_padding:215], [TTDeviceUIUtils tt_padding:394/2.f]);
        
        _imageView.centerX = (_centerView.width)/2.0;
        [self _setImageViewAlpha];
        [_centerView addSubview:_imageView];
        
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:18] ];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.numberOfLines = 0;
        
        [_titleLabel setAttributedText:[TTAuthorizeHintView attributedStringWithString:title fontSize:_titleLabel.font.pointSize lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
        CGRect rect = [_titleLabel.attributedText boundingRectWithSize:CGSizeMake([TTDeviceUIUtils tt_padding:215], 300) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        _titleLabel.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame)+[TTDeviceUIUtils tt_padding:34.f], rect.size.width, rect.size.height);
        _titleLabel.centerX = (_centerView.width)/2.0;
        [_centerView addSubview:_titleLabel];
        
        _messageLabel=[[TTLabel alloc]initWithFrame:CGRectZero];
        _messageLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]];
        _messageLabel.textColorKey = kColorText3;
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineHeight = [TTDeviceUIUtils tt_padding:21];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.text = message;
        [_messageLabel sizeToFit:[TTDeviceUIUtils tt_padding:215]];
        _messageLabel.frame = CGRectMake(0, CGRectGetMaxY(_titleLabel.frame)+[TTDeviceUIUtils tt_padding:8.f], CGRectGetWidth(_messageLabel.frame), CGRectGetHeight(_messageLabel.frame));
        _messageLabel.centerX = (_centerView.width)/2.0;
        [_centerView addSubview:_messageLabel];
        
        _doneButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake([TTDeviceUIUtils tt_padding:27.5f] ,[TTDeviceUIUtils tt_padding:330.f], [TTDeviceUIUtils tt_padding:215], [TTDeviceUIUtils tt_padding:44.f]);
        _doneButton.layer.cornerRadius = [TTDeviceUIUtils tt_padding:6.f];
        [_doneButton addTarget:self action:@selector(doneBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.backgroundColorThemeKey = kColorBackground7;
        _doneButton.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
        _doneButton.titleColorThemeKey = kColorText7;
        _doneButton.highlightedTitleColorThemeKey = kColorText7Highlighted;
        [_doneButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]]];
        [_doneButton setTitle:confirmBtnTitle forState:UIControlStateNormal];
        [_centerView addSubview:_doneButton];
        
        _cancelButton = [[SSThemedButton alloc]initWithFrame:CGRectMake([TTDeviceUIUtils tt_padding:226], 0, [TTDeviceUIUtils tt_padding:44], [TTDeviceUIUtils tt_padding:44])];
        [_cancelButton addTarget:self action:@selector(cancelBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _cancelImageView = [[SSThemedImageView alloc]init];
        _cancelImageView.imageName = @"icon_popup_close";
        _cancelImageView.enableNightCover = NO;
        _cancelImageView.frame = CGRectMake(CGRectGetWidth(_cancelButton.frame)-_cancelImageView.image.size.width-[TTDeviceUIUtils tt_padding:8], [TTDeviceUIUtils tt_padding:8], _cancelImageView.image.size.width, _cancelImageView.image.size.height);
        [_cancelButton addSubview:_cancelImageView];
        [_centerView addSubview:_cancelButton];
        
        /*针对messagelabel 显示3行的情况，最多显示3行*/
        if(CGRectGetHeight(_messageLabel.frame) / [TTDeviceUIUtils tt_padding:21] > 2.f){
            _doneButton.frame = CGRectMake(CGRectGetMinX(_doneButton.frame), CGRectGetMaxY(_messageLabel.frame)+[TTDeviceUIUtils tt_padding:13], CGRectGetWidth(_doneButton.frame), CGRectGetHeight(_doneButton.frame));
            _centerView.frame=CGRectMake(0, 0, CGRectGetWidth(_centerView.frame), CGRectGetMaxY(_doneButton.frame)+[TTDeviceUIUtils tt_padding:21]);
        }
        
        self.authorizeHintComplete = completed;
    }
    return self;
}

- (instancetype) initAuthorizeHintWithImageName:(NSString *)imageName
                                          title:(NSString *)title
                                        message:(NSString *)message
                                confirmBtnTitle:(NSString *)confirmBtnTitle
                                       animated:(BOOL)animated
                                      completed:(TTAuthorizeHintComplete)completed
{
    self = [self init];
    if (self) {
        _imageView =[[SSThemedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.imageName = imageName;
        if (_imageView.image.size.height > 0) {
             _imageView.frame = CGRectMake(0, [TTDeviceUIUtils tt_padding:36],[TTDeviceUIUtils tt_padding:164.f*self.imageView.image.size.width/self.imageView.image.size.height], [TTDeviceUIUtils tt_padding:164.f]);
        }
       
        
        _imageView.centerX = (_centerView.width)/2.0;
        [self _setImageViewAlpha];
        [_centerView addSubview:_imageView];
        
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:18] ];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.numberOfLines = 0;
        
        [_titleLabel setAttributedText:[TTAuthorizeHintView attributedStringWithString:title fontSize:_titleLabel.font.pointSize lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
        CGRect rect = [_titleLabel.attributedText boundingRectWithSize:CGSizeMake([TTDeviceUIUtils tt_padding:215], 300) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        _titleLabel.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame)+[TTDeviceUIUtils tt_padding:34], rect.size.width, rect.size.height);
        _titleLabel.centerX = (_centerView.width)/2.0;
        [_centerView addSubview:_titleLabel];
        
        _messageLabel=[[TTLabel alloc]initWithFrame:CGRectZero];
        _messageLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]];
        _messageLabel.textColorKey = kColorText3;
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineHeight = [TTDeviceUIUtils tt_padding:21];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.text = message;
        [_messageLabel sizeToFit:[TTDeviceUIUtils tt_padding:215]];
        _messageLabel.frame  = CGRectMake(0, CGRectGetMaxY(_titleLabel.frame)+[TTDeviceUIUtils tt_padding:8.f], CGRectGetWidth(_messageLabel.frame), CGRectGetHeight(_messageLabel.frame));
        _messageLabel.centerX = (_centerView.width)/2.0;
        [_centerView addSubview:_messageLabel];
        
        _doneButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake([TTDeviceUIUtils tt_padding:27.5f] ,[TTDeviceUIUtils tt_padding:330.f],[TTDeviceUIUtils tt_padding:215], [TTDeviceUIUtils tt_padding:44.f]);
        _doneButton.layer.cornerRadius = [TTDeviceUIUtils tt_padding:6.f];
        [_doneButton addTarget:self action:@selector(doneBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.backgroundColorThemeKey = kColorBackground7;
        _doneButton.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
        _doneButton.titleColorThemeKey = kColorText7;
        _doneButton.highlightedTitleColorThemeKey = kColorText7Highlighted;
        [_doneButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]]];
        [_doneButton setTitle:confirmBtnTitle forState:UIControlStateNormal];
        [_centerView addSubview:_doneButton];
        
        _cancelButton = [[SSThemedButton alloc]initWithFrame:CGRectMake([TTDeviceUIUtils tt_padding:226], 0, [TTDeviceUIUtils tt_padding:44], [TTDeviceUIUtils tt_padding:44])];
        [_cancelButton addTarget:self action:@selector(cancelBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _cancelImageView = [[SSThemedImageView alloc]init];
        _cancelImageView.imageName = @"icon_popup_close";
        _cancelImageView.enableNightCover = NO;        
        _cancelImageView.frame = CGRectMake(CGRectGetWidth(_cancelButton.frame)-_cancelImageView.image.size.width-[TTDeviceUIUtils tt_padding:8], [TTDeviceUIUtils tt_padding:8], _cancelImageView.image.size.width, _cancelImageView.image.size.height);
        [_cancelButton addSubview:_cancelImageView];
        [_centerView addSubview:_cancelButton];
        
        /*针对messagelabel 显示3行的情况，最多显示3行*/
        if(CGRectGetHeight(_messageLabel.frame) / [TTDeviceUIUtils tt_padding:21] > 2.f){
            _doneButton.frame = CGRectMake(CGRectGetMinX(_doneButton.frame), CGRectGetMaxY(_messageLabel.frame)+[TTDeviceUIUtils tt_padding:13], CGRectGetWidth(_doneButton.frame), CGRectGetHeight(_doneButton.frame));
            _centerView.frame=CGRectMake(0, 0, CGRectGetWidth(_centerView.frame), CGRectGetMaxY(_doneButton.frame)+[TTDeviceUIUtils tt_padding:21]);
        }
        
        self.authorizeHintComplete = completed;
    }
    return self;
}

- (instancetype) initAuthorizeHintWithImageName:(NSString *)imageName
                                          title:(NSString*)title
                                        message:(NSString*)message
                                confirmBtnTitle:(NSString*)confirmBtnTitle
                                       animated:(BOOL)animated
                                       reversed:(BOOL)reversed
                                      completed:(TTAuthorizeHintComplete)completed
{
    self = [self initAuthorizeHintWithImageName:imageName title:title message:message confirmBtnTitle:confirmBtnTitle animated:animated completed:completed];
    
    if (reversed) {
        _titleLabel.frame = CGRectMake(0, [TTDeviceUIUtils tt_padding:34], CGRectGetWidth(_titleLabel.frame), CGRectGetHeight(_titleLabel.frame));
        _titleLabel.centerX = (_centerView.width)/2.0;
        _messageLabel.frame = CGRectMake(0, CGRectGetMaxY(_titleLabel.frame)+[TTDeviceUIUtils tt_padding:8.f], CGRectGetWidth(_messageLabel.frame), CGRectGetHeight(_messageLabel.frame));
        _messageLabel.centerX = (_centerView.width)/2.0;
        
        BOOL imageShirnk = (_imageView.image.size.width / _imageView.image.size.height) * [TTDeviceUIUtils tt_padding:164.f] > _centerView.frame.size.width - 2 * [TTDeviceUIUtils tt_padding:20];
        if (imageShirnk) { // 适配图片，如果超过设置边距，以图片本身的宽高比进行缩放
            CGFloat scaleHeight = _imageView.image.size.height / _imageView.image.size.width * _centerView.frame.size.width - 2 * [TTDeviceUIUtils tt_padding:20];
            _imageView.frame = CGRectMake(0, CGRectGetMaxY(_messageLabel.frame) + [TTDeviceUIUtils tt_padding:36], _centerView.frame.size.width - 2 * [TTDeviceUIUtils tt_padding:20], scaleHeight);
        } else {
            _imageView.frame = CGRectMake(0, CGRectGetMaxY(_messageLabel.frame) + [TTDeviceUIUtils tt_padding:36], CGRectGetWidth(_imageView.frame), CGRectGetHeight(_imageView.frame));
        }
        _imageView.centerX = (_centerView.width)/2.0;
        
        /*针对messagelabel 显示3行的情况，最多显示3行*/
        BOOL messageLabelShirnk = CGRectGetHeight(_messageLabel.frame) / [TTDeviceUIUtils tt_padding:21] > 2.f;
        if (messageLabelShirnk) {
            _doneButton.frame = CGRectMake(CGRectGetMinX(_doneButton.frame), CGRectGetMaxY(_imageView.frame)+ [TTDeviceUIUtils tt_padding:13], CGRectGetWidth(_doneButton.frame), CGRectGetHeight(_doneButton.frame));
        } else {
            _doneButton.frame = CGRectMake(CGRectGetMinX(_doneButton.frame), CGRectGetMaxY(_imageView.frame)+ [TTDeviceUIUtils tt_padding:36], CGRectGetWidth(_doneButton.frame), CGRectGetHeight(_doneButton.frame));
        }
        
        if (imageShirnk || messageLabelShirnk) { // 需要更新centerview的frame
            _centerView.frame = CGRectMake(0, 0, CGRectGetWidth(_centerView.frame), CGRectGetMaxY(_doneButton.frame)+[TTDeviceUIUtils tt_padding:21]);
        }
    }
    
    return self;
}

/**
 实现夜间模式下，imageView变成50%透明
 */
- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    [self _setImageViewAlpha];
}

-(void)_setImageViewAlpha{
    if (_showGifImage) {
        return;
    }
    
    if([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        _imageView.alpha = 0.5;
    } else {
        _imageView.alpha = 1;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)show
{
    UIWindow *window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    
    self.alpha = 0.0f;
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    [vc.view addSubview:self];
    
    
    if ([[TTKeyboardListener sharedInstance] isVisible]) {
        CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
        CGPoint center = CGPointMake(_centerView.center.x,  keyboardTop/2);
        _centerView.center = center;
        
    }
    
    self.centerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.13 animations:^{
        self.alpha = 1.0f;
        self.centerView.transform = CGAffineTransformMakeScale(1.03, 1.03);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            self.centerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0.0f;
        self.centerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
}

- (void)doLayOut
{
    CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
    CGPoint center = CGPointMake(self.frame.size.width/2.0f,  keyboardTop/2);
    _centerView.center = center;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.frame = self.superview.bounds;
    [self doLayOut];
}


#pragma mark Btn Actions

- (void)cancelBtnTouched:(id)sender {
    
    if (self.authorizeHintComplete) {
        self.authorizeHintComplete(TTAuthorizeHintCompleteTypeCancel);
    }
    [self hide];
}

- (void)doneBtnTouched:(id)sender {
    if (self.authorizeHintComplete) {
        self.authorizeHintComplete(TTAuthorizeHintCompleteTypeDone);
    }
    [self hide];
    
}


#pragma mark  keyboard observer

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    CGPoint center = CGPointMake(_centerView.center.x,  keyboardTop/2);
    _centerView.center = center;
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    _centerView.center = self.center;
    [UIView commitAnimations];
}

#pragma mark - NSMutableAttributedString Helper

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineSpacing:(CGFloat)lineSpace lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)alignment
{
    if (isEmptyString(string)) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSDictionary *attributes = [self _attributesWithFontSize:fontSize lineSpacing:lineSpace lineBreakMode:lineBreakMode textAlignment:alignment];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}


+ (NSDictionary *)_attributesWithFontSize:(CGFloat)fontSize lineSpacing:(CGFloat)lineSpace lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)alignment
{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    style.lineSpacing = lineSpace;
    style.alignment = alignment;
    
    NSDictionary * attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    return attributes;
}

@end
