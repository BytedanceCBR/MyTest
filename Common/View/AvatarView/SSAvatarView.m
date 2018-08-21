//
//  SSAvatarView.m
//  Article
//
//  Created by Zhang Leonardo on 12-12-24.
//
//

#import "SSAvatarView.h"
#import <QuartzCore/QuartzCore.h>
#import "SSSimpleCache.h"
#import "NetworkUtilities.h"
#import "SSUserSettingManager.h"
#import "UIImageAdditions.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"
#import "TTNetworkManager.h"
#import "UIColor+TTThemeExtension.h"
#import "UIImage+TTThemeExtension.h"
#import "TTProjectLogicManager.h"
#import "TTStringHelper.h"

#define CurCurrentDownloadNubmer 3

static NSOperationQueue * queue;

@interface SSAvatarView()
{
    BOOL _avatarShowed;
}
@property(nonatomic, assign)BOOL isNightModel;
@property(nonatomic, strong, readwrite)UIButton * avatarButton;

@property(nonatomic, assign)NSOperationQueuePriority downloadPriority;
@property(nonatomic, strong)TTHttpTask * downloadTask;
@property(nonatomic, strong)NSString * avatarURLStr;

@property(nonatomic, strong)UIImage * needDrawAvatarImage;       //实际显示的头像
@property(nonatomic, strong)UIImage * needDrawBackgroundImage;   //实际显示的背景

@end



@implementation SSAvatarView

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_avatarButton removeObserver:self forKeyPath:@"highlighted"];
    
    [self cancelRequest];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _avatarSupportNightModel = YES;
        
        self.nightAvatarCoverImage = [SSAvatarView createImageWithColor:[UIColor colorWithHexString:@"00000066"]];
        _isNightModel = [[TTThemeManager sharedInstance_tt] currentThemeMode];
        
        
        _avatarShowed = NO;
        self.backgroundColor = [UIColor clearColor];
        

        self.rectangleAvatarImgRadius =  20.f;
        
        self.avatarImgPadding = 4.f;
        self.marginEdgeInsets = UIEdgeInsetsZero;
        
        _avatarStyle = SSAvatarViewStyleRectangle;
        self.defaultHeadImgName = @"big_defaulthead_head.png";
        self.needDrawAvatarImage = _defaultHeadImg;
        
        self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_avatarButton addTarget:self action:@selector(avatarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_avatarButton addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        
        _avatarButton.frame = self.bounds;
        _avatarButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_avatarButton];
        
        
        [self reloadThemeUI];
    }
    
    return self; 
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"highlighted"]) {
        BOOL newValue = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (!newValue) {
            if (_backgroundNormalImage  && _needDrawBackgroundImage != _backgroundNormalImage) {
                self.needDrawBackgroundImage = _backgroundNormalImage;
                [self needRedraw];
            }
        }
        else {
            if (_backgroundHightlightImage && _needDrawBackgroundImage != _backgroundHightlightImage) {
                self.needDrawBackgroundImage = _backgroundHightlightImage;
                [self needRedraw];
            }
        }

    }
}

- (void)avatarButtonClicked:(id)sender
{
    //do nothing...
    //what the fuck?
}

#pragma mark -- draw

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [[self backgroundDrawPath] addClip];
    [_needDrawBackgroundImage drawInRect:[self backgroundDrawRect]];
    [[self avatarDrawPath] addClip];
    [_needDrawAvatarImage drawInRect:[self avatarDrawRect]];
    if (_isNightModel && _avatarSupportNightModel) {
        [_nightAvatarCoverImage drawInRect:[self avatarDrawRect]];
    }
}

- (CGRect)avatarDrawRect
{
    float avatarWidth = self.frame.size.width - _marginEdgeInsets.left - _marginEdgeInsets.right - _avatarImgPadding * 2.f;
    float avatarHeight = self.frame.size.height - _marginEdgeInsets.top - _marginEdgeInsets.bottom - _avatarImgPadding * 2.f;
    CGRect avatarRect = CGRectMake(_marginEdgeInsets.left + _avatarImgPadding, _marginEdgeInsets.top + _avatarImgPadding, avatarWidth, avatarHeight);
    return avatarRect;
}

- (UIBezierPath *)avatarDrawPath
{
    UIBezierPath * path = nil;
    
    CGRect avatarRect = [self avatarDrawRect];
    
    switch (_avatarStyle) {
        case SSAvatarViewStyleRound:
        {
            
            path = [UIBezierPath bezierPathWithOvalInRect:avatarRect];
        }
        break;
        case SSAvatarViewStyleRectangle:
        default:
        {
            path = [UIBezierPath bezierPathWithRoundedRect:avatarRect cornerRadius:_rectangleAvatarImgRadius];
        }
            break;
    }
    
    return path;
}

- (UIBezierPath *)backgroundDrawPath
{
    UIBezierPath * path = nil;
    CGRect rect = self.bounds;
    rect.origin.x = _marginEdgeInsets.left;
    rect.origin.y = _marginEdgeInsets.top;
    rect.size.height -= (_marginEdgeInsets.top + _marginEdgeInsets.bottom);
    rect.size.width -= (_marginEdgeInsets.left + _marginEdgeInsets.right);
    
    switch (_avatarStyle) {
        case SSAvatarViewStyleRound:
        {
            
            path = [UIBezierPath bezierPathWithOvalInRect:rect];
        }
            break;
        case SSAvatarViewStyleRectangle:
        default:
        {
            path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_rectangleAvatarImgRadius];
        }
            break;
    }
    
    return path;
}

- (CGRect)backgroundDrawRect
{
    float bgWidth = self.frame.size.width - _marginEdgeInsets.left - _marginEdgeInsets.right;
    float bgHeight = self.frame.size.height - _marginEdgeInsets.top - _marginEdgeInsets.bottom;
    
    CGRect bgRect = CGRectMake(_marginEdgeInsets.left, _marginEdgeInsets.top, bgWidth, bgHeight);
    
    return bgRect;
}

- (void)needRedraw
{
    [self setNeedsDisplay];
}

- (void)showAvatarByURL:(NSString *)urlStr showPriority:(NSOperationQueuePriority)priority
{
    //FIX:XWTT-2885, user default avatar should not use originImage
    if ([urlStr rangeOfString:@"/origin/"].location != NSNotFound) {
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"/origin/" withString:@"/thumb/"];
    }
    //FIX end
    
    if (!isEmptyString(urlStr) && [urlStr isEqualToString:_avatarURLStr] && _avatarShowed) {//相同的URL，直接返回
        return;
    }
    _avatarShowed = NO;
    [self cancelRequest];
    self.avatarURLStr = urlStr;

    self.downloadPriority = priority;
//    SSLog(@"ssAvatar Test  showAvatarByURL: %@", _avatarURLStr);
    if (isEmptyString(urlStr) || ![self shouldShowImage]) {
//        SSLog(@"ssAvatar Test  showAvatarByURL leng = 0: %@", _avatarURLStr);
        self.needDrawAvatarImage = _defaultHeadImg;
        [self needRedraw];
         [self refreshBackgroundImg];
        return;
    }
//    SSLog(@"ssAvatar Test  showAvatarByURL should showImage return: %@", _avatarURLStr);

    
    NSData * data = [[SSSimpleCache sharedCache] dataForUrl:urlStr];
    
    if (data != nil) {
        UIImage *img = [UIImage imageWithData:data];
        if (img) {
            _avatarShowed = YES;
            self.needDrawAvatarImage = img;
            //SSLog(@"image has size w/h:%f/%f", self.needDrawAvatarImage.size.width, self.needDrawAvatarImage.size.height);
        } else {
            _avatarShowed = NO;
            self.needDrawAvatarImage = _defaultHeadImg;
            [self needRedraw];
            [self downloadImageByURLString:urlStr];
        }
        [self needRedraw];
//        SSLog(@"ssAvatar Test  showAvatarByURL: hasData andShowed %@", _avatarURLStr);
    }
    else {
//        SSLog(@"ssAvatar Test  showAvatarByURL no data request : %@", _avatarURLStr);
        _avatarShowed = NO;
        self.needDrawAvatarImage = _defaultHeadImg;
        [self needRedraw];
        [self downloadImageByURLString:urlStr];
    }
    
    [self refreshBackgroundImg];
}

- (void)showAvatarByURL:(NSString *)urlStr
{
    [self showAvatarByURL:urlStr showPriority:NSOperationQueuePriorityNormal];
}

- (NSOperationQueue *)getDownloadQueue
{
   
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:CurCurrentDownloadNubmer];
    });
    
    return queue;
}

- (void)downloadImageByURLString:(NSString *)urlStr
{
    
    if (!TTNetworkConnected()) {
        return;
    }
    
    [self cancelRequest];
    
    NSURL * url = [TTStringHelper URLWithURLString:urlStr];
    if (url != nil) {
        self.downloadTask = [[TTNetworkManager shareInstance] requestForBinaryWithURL:url.absoluteString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
            if (!error && [obj isKindOfClass:[NSData class]]) {
                NSData * responseData = obj;
                
                if (responseData != nil) {
                    
                    [[SSSimpleCache sharedCache] setData:responseData forKey:url.absoluteString];
                    
                    if ([url.absoluteString isEqualToString:_avatarURLStr]) {
                        UIImage * img = [UIImage imageWithData:responseData];
                        if (!img) {
                            return;
                        }
                        self.needDrawAvatarImage = img;
                        [self needRedraw];
                        _avatarShowed = YES;
                    }
                }
                [self cancelRequest];
            }
        }];
        
        if ([_downloadTask respondsToSelector:@selector(setPriority:)]) {
            [_downloadTask setPriority:self.downloadPriority];
        }
    }
}

- (void)setLocalAvatarImage:(UIImage *)avatarImg
{
    if (avatarImg != nil) {
        
        [self cancelRequest];
        
        self.needDrawAvatarImage = avatarImg;
        [self needRedraw];
        _avatarShowed = YES;
    }
}

- (BOOL)cached
{
    if (isEmptyString(_avatarURLStr)) {
        return NO;
    }
    return [[SSSimpleCache sharedCache] quickCheckIsCacheExist:_avatarURLStr];
}


- (void)cancelRequest
{
    [_downloadTask cancel];
    self.downloadTask = nil;
}

#pragma mark -- setter

- (void)setAvatarSupportNightModel:(BOOL)avatarSupportNightModel
{
    _avatarSupportNightModel = avatarSupportNightModel;
    [self needRedraw];
}

- (void)setDefaultHeadImgName:(NSString *)defaultHeadImgName
{
    if (defaultHeadImgName != _defaultHeadImgName) {
        _defaultHeadImgName = defaultHeadImgName;
    }
    self.defaultHeadImg = [UIImage themedImageNamed:_defaultHeadImgName];
}

- (void)setDefaultHeadImg:(UIImage *)defaultHeadImg
{
    _defaultHeadImg = defaultHeadImg;
    
    if (!_avatarShowed) {
        self.needDrawAvatarImage = _defaultHeadImg;
    }
}

- (void)setAvatarStyle:(SSAvatarViewStyle)avatarStyle
{
    _avatarStyle = avatarStyle;
    [self needRedraw];
}

- (void)setBackgroundNormalImageName:(NSString *)backgroundNormalImageName
{
    if (![_backgroundNormalImageName isEqualToString:backgroundNormalImageName]) {
        _backgroundNormalImageName = backgroundNormalImageName;
    }
    self.backgroundNormalImage = [UIImage themedImageNamed:_backgroundNormalImageName];
}

- (void)setBackgroundHightlightImageName:(NSString *)backgroundHightlightImageName
{
    if (![_backgroundHightlightImageName isEqualToString:backgroundHightlightImageName]) {
        _backgroundHightlightImageName = backgroundHightlightImageName;
    }
    
    self.backgroundHightlightImage = [UIImage themedImageNamed:_backgroundHightlightImageName];
}

- (void)setBorderColorName:(NSString *)borderColorName
{
    if (![_borderColorName isEqualToString:borderColorName]) {
        _borderColorName = borderColorName;
    }
    
    if (isEmptyString(borderColorName)) {
        return;
    }
    UIImage * img = [UIImage imageWithUIColor:[UIColor tt_themedColorForKey:_borderColorName]];
    self.backgroundNormalImage = img;
}

- (void)setBackgroundNormalImage:(UIImage *)backgroundNormalImage
{
    if (_backgroundNormalImage != backgroundNormalImage)
    {
        _backgroundNormalImage = backgroundNormalImage;
    }
    
    self.needDrawBackgroundImage = backgroundNormalImage;
    [self needRedraw];
}

#pragma mark -- protected

- (BOOL)shouldShowImage
{
    BOOL result = TTNetworkWifiConnected() || ([TTUserSettingsManager networkTrafficSetting] != TTNetworkTrafficSave  || [self cached]);
    return result;
}

- (void)themeChanged:(NSNotification *)notification
{
    _isNightModel = [[TTThemeManager sharedInstance_tt] currentThemeMode];
    
    if (_defaultHeadImgName != nil) {
        self.defaultHeadImg = [UIImage themedImageNamed:_defaultHeadImgName];
    }
    
    if (_backgroundHightlightImageName != nil) {
        self.backgroundHightlightImage = [UIImage themedImageNamed:_backgroundHightlightImageName];
    }
    
    if (_backgroundNormalImageName != nil) {
        self.backgroundNormalImage = [UIImage themedImageNamed:_backgroundNormalImageName];
    }
    
    [self refreshBackgroundImg];
    
    [self setNeedsDisplay];
}

- (void)refreshBackgroundImg
{
    if (_borderColorName != nil) {
        
        UIImage * img = [UIImage imageWithUIColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] rgbaValueForKey:_borderColorName]]];
        if (_avatarURLStr) {
            self.backgroundNormalImage = img;
        }
        else {
            self.backgroundNormalImage = nil;
        }
    }
}

+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
