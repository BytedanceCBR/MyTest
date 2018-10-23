//
//  TTAsyncCornerImageView.m
//  Pods
//
//  Created by zhaoqin on 15/11/2016.
//
//


#import "TTAsyncCornerImageView.h"
#import "UIImage+TTAvatar.h"

// TTBaseLib
#import "TTLabelTextHelper.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"
#import "UIImageAdditions.h"

// TTThemed
#import "TTThemeManager.h"
#import "UIColor+TTThemeExtension.h"
#import "SSThemed.h"

// SDWebImage
#import <SDWebImage/UIImageView+WebCache.h>

@interface TTAsyncCornerImageView ()
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIView *nightCoverView;
@property (nonatomic, assign) BOOL allowCorner;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSString *urlString;
@end

@implementation TTAsyncCornerImageView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTThemeManagerThemeModeChangedNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame allowCorner:(BOOL)allowCorner {
    _allowCorner = allowCorner;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _coverColor = [UIColor clearColor];
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        CGFloat borderWidth = [TTDeviceHelper ssOnePixel];
        _nightCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        if (_allowCorner) {
            _nightCoverView.layer.cornerRadius = _nightCoverView.width / 2;
        }
        _borderWidth = [TTDeviceHelper ssOnePixel];
        _nightCoverView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _borderColor = SSGetThemedColorWithKey(kColorLine1);
        _nightCoverView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            _nightCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        }
        else {
            _nightCoverView.backgroundColor = _coverColor;
        }
        [self addSubview:_nightCoverView];
        [self insertSubview:_avatarView belowSubview:_nightCoverView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(customThemeChanged)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        
        self.queue = dispatch_queue_create("com.bytedance.asyncImageView", DISPATCH_QUEUE_SERIAL);
        
        if (_allowCorner){
            self.contentMode = UIViewContentModeScaleAspectFill;
        }
    }
    return self;
}

- (void)tt_setImageWithURLString:(NSString *)urlString {
    
    if ([urlString rangeOfString:@"/origin/"].location != NSNotFound) {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"/origin/" withString:@"/thumb/"];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    
    WeakSelf;
    if ([urlString isEqualToString:self.urlString]) {
        [self.avatarView sd_setImageWithURL:url placeholderImage:self.avatarView.image options:SDWebImageAvoidAutoSetImage | SDWebImageRetryFailed | SDWebImageLowPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            StrongSelf;
            if (!error) {
                self.avatarView.hidden = NO;
                if (self.allowCorner) {
                    [self tt_asyncSetCornerImage:image imageView:self.avatarView completion:^(UIImage *clipImage) {
                        self.avatarView.image = clipImage;
                    }];
                }
                else {
                    self.avatarView.image = image;
                }
                if (cacheType != SDImageCacheTypeMemory) {
                    self.avatarView.alpha = 0;
                    [UIView animateWithDuration:0.5f animations:^{
                        self.avatarView.alpha = 1;
                    }];
                }
            }
            else {
                self.avatarView.hidden = YES;
            }
        }];
    }
    else {
        [self.avatarView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageAvoidAutoSetImage | SDWebImageRetryFailed | SDWebImageLowPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            StrongSelf;
            if (!error) {
                self.avatarView.hidden = NO;
                if (self.allowCorner) {
                    [self tt_asyncSetCornerImage:image imageView:self.avatarView completion:^(UIImage *clipImage) {
                        self.avatarView.image = clipImage;
                    }];
                }
                else {
                    self.avatarView.image = image;
                }
                if (cacheType != SDImageCacheTypeMemory) {
                    self.avatarView.alpha = 0;
                    [UIView animateWithDuration:0.5f animations:^{
                        self.avatarView.alpha = 1;
                    }];
                }
            }
            else {
                self.avatarView.hidden = YES;
            }
        }];
    }
    self.urlString = urlString;
    
}

- (void)addTouchTarget:(id)target action:(SEL)action {
    [self addGestureRecognizer:self.tapGestureRecognizer];
    self.userInteractionEnabled = YES;
    [self.tapGestureRecognizer addTarget:target action:action];
}

- (void)refreshNightCoverView {
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        _nightCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    else {
        _nightCoverView.backgroundColor = _coverColor;
    }
}

- (void)tt_asyncSetCornerImage:(UIImage *)image imageView:(UIImageView *)imageView completion:(void (^)(UIImage *clipImage))completionBlock{
    CGSize size = imageView.bounds.size;
    CGSize cornerRadii = CGSizeMake(self.cornerRadius, self.cornerRadius);
    UIViewContentMode contentMode = imageView.contentMode;
   
    dispatch_async(self.queue, ^{
        UIImage *clipImage = [image tt_imageByRoundCornerRadius:cornerRadii size:size contentMode:contentMode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(clipImage);
        });
    });
}

- (void)customThemeChanged {
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        _nightCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    else {
        _nightCoverView.backgroundColor = [UIColor clearColor];
    }
    _nightCoverView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
}

- (void)setPlaceholderName:(NSString *)placeholderName {
    if ([_placeholderName isEqualToString:placeholderName]) {
        return;
    }
    _placeholderName = placeholderName;
    if (_allowCorner) {
        [self tt_asyncSetCornerImage:[UIImage imageNamed:_placeholderName] imageView:self completion:^(UIImage *clipImage) {
            self.image = clipImage;
        }];
    }
    else {
        self.image = [UIImage imageNamed:_placeholderName];
    }
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (oldFrame.size.width != self.frame.size.width || oldFrame.size.height != self.frame.size.height) {
        [self layoutSubviewsIfNeeded];
    }
}

- (void)layoutSubviewsIfNeeded {
    CGRect avatarViewFrame = _avatarView.frame;
    avatarViewFrame.size = CGSizeMake(self.width, self.height);
    _avatarView.frame = avatarViewFrame;
    
    CGRect nightCoverViewFrame = _nightCoverView.frame;
    nightCoverViewFrame.size = CGSizeMake(self.width, self.height);
    _nightCoverView.frame = nightCoverViewFrame;
    if (_allowCorner) {
        _nightCoverView.layer.cornerRadius = _nightCoverView.width / 2;
    }
}

- (void)tt_setImageText:(NSString *)text fontSize:(CGFloat)fontSize textColorThemeKey:(NSString *)textColorThemeKey backgroundColorThemeKey:(NSString *)backgroundColorThemeKey backgroundColors:(NSArray *)backgroundColors{

    UIColor *backgroundColor = [UIColor clearColor];
    if (backgroundColors.count > 0 || !isEmptyString(backgroundColorThemeKey)) {
        backgroundColor = SSGetThemedColorUsingArrayOrKey(backgroundColors, backgroundColorThemeKey);
    }
    
    UIImage *image = [UIImage imageWithUIColor:backgroundColor];
    
    if (self.allowCorner) {
        CGSize size = self.bounds.size;
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize cornerRadii = CGSizeMake(self.cornerRadius, self.cornerRadius);
        CGRect viewBounds = self.bounds;
        CGFloat viewWidth = self.width;
        CGFloat viewHeight = self.height;
        
        dispatch_async(self.queue, ^{
            
            UIGraphicsBeginImageContextWithOptions(size, NO, scale);
            if (nil == UIGraphicsGetCurrentContext()) {
                return;
            }
            UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:viewBounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerRadii];
            [cornerPath addClip];
            
            CGSize stringSize = [TTLabelTextHelper sizeOfText:text fontSize:fontSize forWidth:viewWidth forLineHeight:fontSize * 1.1 constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
            
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
            [text drawInRect:CGRectMake(viewWidth / 2 - stringSize.width / 2, viewHeight / 2 - stringSize.height / 2, size.width, size.height) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName: [UIColor tt_themedColorForKey:textColorThemeKey]}];
            
            UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.avatarView.image = clipImage;
            });
        });
    }
    else {
        self.avatarView.image = image;
        SSThemedLabel *label = [[SSThemedLabel alloc] init];
        label.text = text;
        label.textColorThemeKey = textColorThemeKey;
        [self.avatarView addSubview:label];
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (_borderColor == borderColor) {
        return;
    }
    _borderColor = borderColor;
    _nightCoverView.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (_borderWidth == borderWidth) {
        return;
    }
    _borderWidth = borderWidth;
    _nightCoverView.layer.borderWidth = borderWidth;
}

- (void)setCoverColor:(UIColor *)coverColor {
    if (_coverColor == coverColor) {
        return;
    }
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        _nightCoverView.backgroundColor = coverColor;
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode{
    [super setContentMode:contentMode];
    self.avatarView.contentMode = contentMode;
}

@end
