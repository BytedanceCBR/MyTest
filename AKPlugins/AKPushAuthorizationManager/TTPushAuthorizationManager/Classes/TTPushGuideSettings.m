//
//  TTPushGuideSettings.m
//  Article
//
//  Created by liuzuopeng on 11/07/2017.
//
//

#import "TTPushGuideSettings.h"
#import <TTWebImagePrefetcher.h>
#import <TTWebImageManager.h>
#import <SDImageCache.h>
#import <SDWebImageManager.h>
#import <FLAnimatedImage.h>
#import <TTThemeManager.h>



#define isDayThemeMode   (TTThemeModeDay == [TTThemeManager sharedInstance_tt].currentThemeMode)
#define isNightThemeMode (TTThemeModeNight == [TTThemeManager sharedInstance_tt].currentThemeMode)


@implementation TTPushGuideSettingsModel

- (BOOL)containsImage
{
    if (_image) return YES;
    if ([_imageURLString length] > 0) return YES;
    return NO;
}

- (NSString *)titleString
{
    if (_titleString) {
        return _titleString;
    }
    return [self.class defaultTitleText];
}

+ (NSString *)defaultTitleText
{
    return @"开启要闻通知";
}

+ (NSString *)defaultSubtitleText
{
    return @"第一时间获取重大新闻";
}

+ (NSString *)defaultButtonText
{
    return @"开启";
}

@end



static NSString *kTTPushDialogMaxShowTimesKey   = @"max_show_times";
static NSString *kTTPushDialogTitleKey          = @"title";
static NSString *kTTPushDialogSubtitleKey       = @"subtitle";
static NSString *kTTPushDialogImageURLKey       = @"gif_image_url";
static NSString *kTTPushDialogNightImageURLKey  = @"night_gif_image_url";
static NSString *kTTPushDialogButtonTextKey     = @"button_text";

@implementation TTPushGuideSettings

static NSString * kTTPushPermissionGuideTextConfigKey = @"kTTPushPermissionGuideTextConfigKey";

+ (void)parsePushGuideConfigFromSettings:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *pushSettings = dict[@"tt_push_guide_dialog_config"];
        if ([pushSettings isKindOfClass:[NSDictionary class]]) {
            NSArray<NSDictionary *> *values = [pushSettings allValues];
            for (NSDictionary *value in values) {
                if ([value isKindOfClass:[NSDictionary class]]) {
                    @autoreleasepool {
                        NSString *dayImageURLString = value[kTTPushDialogImageURLKey];
                        [self.class _downloadImageByURLString:dayImageURLString];
                        
                        NSString *nightImageURLString = value[kTTPushDialogNightImageURLKey];
                        [self.class _downloadImageByURLString:nightImageURLString];
                    }
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:pushSettings forKey:kTTPushPermissionGuideTextConfigKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}

#pragma mark - model

+ (TTPushGuideSettingsModel *)pushGuideDialogModelOfCategory:(NSInteger)category
{
    NSDictionary *configDict = [self.class _pushGuideDialogConfigOfCategory:category];
    if (!configDict) return nil;
    
    NSString *dayImageString   = configDict[kTTPushDialogImageURLKey];
    NSString *nightImageString = configDict[kTTPushDialogNightImageURLKey];
    
    if (isDayThemeMode && ![self.class _cachedImageForURLString:dayImageString]) {
        return nil;
    } else if (isNightThemeMode && ![self.class _cachedImageForURLString:nightImageString]) {
        return nil;
    }
    
    TTPushGuideSettingsModel *aModel = [TTPushGuideSettingsModel new];
    aModel.titleString      = configDict[kTTPushDialogTitleKey];
    aModel.subtitleString   = configDict[kTTPushDialogSubtitleKey];
    aModel.buttonTextString = configDict[kTTPushDialogButtonTextKey];
    aModel.imageURLString   = dayImageString;
    aModel.image            = [self.class _flAnimatedImageForURLString:aModel.imageURLString];
    aModel.nightImageURLString = nightImageString;
    aModel.nightImage          = [self.class _flAnimatedImageForURLString:aModel.nightImageURLString];
    
    return aModel;
}

+ (BOOL)imageHasDownloadedOfCategory:(NSInteger)category
{
    NSDictionary *pushSettingsDict = [self.class _pushGuideDialogConfigOfCategory:category];
    if (!pushSettingsDict) return NO;
    NSString *imageURLString = pushSettingsDict[kTTPushDialogImageURLKey];
    if ([self.class _cachedImageForURLString:imageURLString]) {
        return YES;
    }
    [self.class _downloadImageByURLString:imageURLString];
    return NO;
}

+ (BOOL)nightImageHasDownloadedOfCategory:(NSInteger)category
{
    NSDictionary *pushSettingsDict = [self.class _pushGuideDialogConfigOfCategory:category];
    if (!pushSettingsDict) return NO;
    NSString *nightImageURLString = pushSettingsDict[kTTPushDialogNightImageURLKey];
    if ([self.class _cachedImageForURLString:nightImageURLString]) {
        return YES;
    }
    [self.class _downloadImageByURLString:nightImageURLString];
    return NO;
}

+ (NSInteger)maxShowTimesOfCategory:(NSInteger)category
{
    NSDictionary *pushSettingsDict = [self.class _pushGuideDialogConfigOfCategory:category];
    if (!pushSettingsDict) return 1;
    return MAX(1, [pushSettingsDict[kTTPushDialogMaxShowTimesKey] integerValue]);
}

#pragma mark - helper

+ (NSString *)_categoryStringFromEnumInt:(NSInteger)category
{
    switch (category) {
        case TTPushGuideDialogCategoryFollow: {
            return @"follow";
        }
            break;
        case TTPushGuideDialogCategoryInteraction: {
            return @"interaction";
        }
            break;
        default:
            break;
    }
    return @"read_top_article";
}

+ (NSDictionary *)_pushGuideDialogConfigOfCategory:(NSInteger)category
{
    NSString *categoryString = [self.class _categoryStringFromEnumInt:category];
    NSDictionary *dict = [self.class _pushPermissionGuideConfig_];
    if ([dict isKindOfClass:[NSDictionary class]] && categoryString) {
        return ([dict[categoryString] isKindOfClass:[NSDictionary class]] ? dict[categoryString] : nil);
    }
    return nil;
}

+ (NSDictionary *)_pushPermissionGuideConfig_
{
    NSDictionary *configDict = [[NSUserDefaults standardUserDefaults] objectForKey:kTTPushPermissionGuideTextConfigKey];
    return configDict;
}

+ (void)_downloadImageByURLString:(NSString *)imageURLString
{
    if ([self.class _cachedImageForURLString:imageURLString]) {
        return;
    }
    
    if (!imageURLString) return;
    
    [[TTWebImageManager shareManger] downloadImageWithURL:imageURLString options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
        
    }];
}

+ (UIImage *)_cachedImageForURLString:(NSString *)imageURLString
{
    if (!imageURLString) return nil;
    
    UIImage *image = [TTWebImageManager imageForURLString:imageURLString];
    return image;
}

+ (FLAnimatedImage *)_flAnimatedImageForURLString:(NSString *)imageURLString
{
    NSData *imageData = [self.class _queryImageDataFromDiskOrDownloadForURLString:imageURLString];
    if (imageData) {
        return [FLAnimatedImage animatedImageWithGIFData:imageData];
    }
    return nil;
}

+ (NSData *)_queryImageDataFromDiskOrDownloadForURLString:(NSString *)imageURLString
{
    if (!imageURLString) return nil;
    NSString *imageURLKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageURLString]];
    NSString *imageCachedPath = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageURLKey];
    NSData *data = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[SDImageCache sharedImageCache] respondsToSelector:@selector(diskImageDataBySearchingAllPathsForKey:)]) {
        data = [[SDImageCache sharedImageCache] performSelector:@selector(diskImageDataBySearchingAllPathsForKey:) withObject:imageURLKey];
    } else {
        data = [NSData dataWithContentsOfFile:imageCachedPath];
        if (!data) data = [NSData dataWithContentsOfFile:imageCachedPath.stringByDeletingPathExtension];
    }
#pragma clang diagnostic pop
    
    if (!data) {
        [[TTWebImageManager shareManger] downloadImageWithURL:imageURLString options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
            
        }];
    }
    
    return data;
}

+ (UIImage *)_queryAndDownloadImageForURLString:(NSString *)imageURLString
{
    UIImage *image = [self.class _cachedImageForURLString:imageURLString];
    
    if (!image) {
        [[TTWebImageManager shareManger] downloadImageWithURL:imageURLString options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
            
        }];
    }
    return image;
}

@end
