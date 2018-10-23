//
//  SRVAnimatedImageView.m
//  Pods
//
//  Created by Zuyang Kou on 14/08/2017.
//
//

#import "TSVAnimatedImageView.h"
#import "TTImageInfosModel.h"
#import "YYWebImage.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTThemeManager.h"
#import "TSVMonitorManager.h"

@implementation TTImageView (TSVImageViewProtocol)

- (void)tsv_setImageWithModel:(TTImageInfosModel *)model placeholderImage:(UIImage *)placeholder
{
    [self tsv_setImageWithModel:model
               placeholderImage:placeholder
                        options:0
                isAnimatedImage:NO
                        success:nil
                        failure:nil];
}

- (void)tsv_setImageWithModel:(TTImageInfosModel *)model
             placeholderImage:(UIImage *)placeholder
                      options:(SDWebImageOptions)options
              isAnimatedImage:(BOOL)isAnimatedImage
                      success:(TTImageViewSuccessBlock)success
                      failure:(TTImageViewFailureBlock)failure
{
    CFTimeInterval beginTime = CACurrentMediaTime();
    
    TTImageViewSuccessBlock successBlockWrapper = ^ (UIImage *image, BOOL cached) {
        [[TSVMonitorManager sharedManager] trackPictureServiceWithDuration:CACurrentMediaTime() - beginTime error:nil cached:cached isAnimatedImage:isAnimatedImage];
        
        if (success) {
            success(image, cached);
        }
    };
    
    TTImageViewFailureBlock failureBlockWrapper = ^ (NSError *error) {
        [[TSVMonitorManager sharedManager] trackPictureServiceWithDuration:CACurrentMediaTime() - beginTime error:error cached:NO isAnimatedImage:isAnimatedImage];
        
        if (failure) {
            failure(error);
        }
    };
    
    [self setImageWithModel:model placeholderImage:placeholder options:options success:successBlockWrapper failure:failureBlockWrapper];
}

@end

@interface TSVAnimatedImageView ()

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, strong) CALayer *coverLayer;

@end

@implementation TSVAnimatedImageView

- (void)didMoveToWindow
{
    [super didMoveToWindow];

    // Not very easy to find a proper initialization point...
    if (!self.initialized) {
        self.initialized = YES;
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             [self themeChanged];
         }];
    }
}

- (void)themeChanged
{
    self.backgroundColor = [UIColor tt_themedColorForKey:self.backgroundColorThemeKey];
    self.layer.borderColor = [[UIColor tt_themedColorForKey:self.borderColorThemeKey] CGColor];

    if (([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) &&
        !self.coverLayer) {
        self.coverLayer = [CALayer layer];
        self.coverLayer.backgroundColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
        [self.layer addSublayer:self.coverLayer];
    }
    self.coverLayer.hidden = [[TTThemeManager sharedInstance_tt] currentThemeMode] != TTThemeModeNight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [CATransaction setDisableActions:YES];
    self.coverLayer.frame = self.frame;
    [CATransaction setDisableActions:NO];
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey
{
    _backgroundColorThemeKey = backgroundColorThemeKey;

    [self themeChanged];
}

- (void)setBorderColorThemeKey:(NSString *)borderColorThemeKey
{
    _borderColorThemeKey = borderColorThemeKey;

    [self themeChanged];
}

- (void)tsv_setImageWithModel:(TTImageInfosModel *)model placeholderImage:(UIImage *)placeholder
{
    [self tsv_setImageWithModel:model
               placeholderImage:placeholder
                        options:0
                isAnimatedImage:NO
                        success:nil
                        failure:nil];
}

- (void)tsv_setImageWithModel:(TTImageInfosModel *)model
             placeholderImage:(UIImage *)placeholder
                      options:(SDWebImageOptions)options
              isAnimatedImage:(BOOL)isAnimatedImage
                      success:(TTImageViewSuccessBlock)success
                      failure:(TTImageViewFailureBlock)failure
{
    NSParameterAssert(!options);
    
    CFTimeInterval beginTime = CACurrentMediaTime();
    
    TTImageViewSuccessBlock successBlockWrapper = ^ (UIImage *image, BOOL cached) {
        [[TSVMonitorManager sharedManager] trackPictureServiceWithDuration:CACurrentMediaTime() - beginTime error:nil cached:cached isAnimatedImage:isAnimatedImage];
        
        if (success) {
            success(image, cached);
        }
    };
    
    TTImageViewFailureBlock failureBlockWrapper = ^ (NSError *error) {
        [[TSVMonitorManager sharedManager] trackPictureServiceWithDuration:CACurrentMediaTime() - beginTime error:error cached:NO isAnimatedImage:isAnimatedImage];
        
        if (failure) {
            failure(error);
        }
    };

    NSURL *URL = [NSURL URLWithString:[model.urlWithHeader firstObject][@"url"]];
    [self yy_setImageWithURL:URL
                 placeholder:placeholder
                     options:YYWebImageOptionSetImageWithFadeAnimation
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                      if (stage != YYWebImageStageFinished) {
                          return;
                      }

                      if (error) {
                          if (failureBlockWrapper) {
                              failureBlockWrapper(error);
                          }
                      } else {
                          [self repositionImage];
                          if (successBlockWrapper) {
                              BOOL fromCache = (from == YYWebImageFromMemoryCacheFast) || (from == YYWebImageFromMemoryCache) || (from == YYWebImageFromDiskCache);
                              successBlockWrapper(image, fromCache);
                          }
                      }
                  }];
}

- (void)repositionImage
{
    CGFloat imageAspectRatio = self.image.size.width / self.image.size.height;
    CGFloat viewAspectRatio = self.frame.size.width / self.frame.size.height;
    if (self.imageContentMode == TTImageViewContentModeScaleAspectFillRemainTop) {
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        if (imageAspectRatio < viewAspectRatio) {
            CGFloat height = imageAspectRatio / viewAspectRatio;
            self.layer.contentsRect = CGRectMake(0, 0, 1, height);
        } else {
            self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
        }
    }
}

- (void)setImageContentMode:(TTImageViewContentMode)imageContentMode
{
    _imageContentMode = imageContentMode;

    NSAssert(self.imageContentMode == TTImageViewContentModeScaleAspectFillRemainTop, @"暂时只支持 TTImageViewContentModeScaleAspectFillRemainTop");
}

@end
