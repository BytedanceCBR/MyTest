//
//  TTTopBarManager.m
//  Article
//
//  Created by fengyadong on 16/8/25.
//
//

#import "TTTopBarManager.h"
#import "TTPersistence.h"
#import "NSDictionary+TTAdditions.h"
#import "UIImage+TTThemeExtension.h"
//#import "AFHTTPSessionManager.h"
#import "NSDataAdditions.h"
#import "NSStringAdditions.h"
#import "SSZipArchive.h"
#import "NetworkUtilities.h"
#import "TTReachability.h"
#import "TTTabBarManager.h"
#import "TTNetworkManager.h"
#import "UIImage+YYWebImage.h"
#import "TTTopBarHeader.h"

NSString *kTTTopBarZipDownloadSuccess = @"kTTTopBarZipDownloadSuccess";
NSString *kTTTopBarSurfaceValidate = @"kTTTopBarSurfaceValidate";

static const NSUInteger validImageResourceNumer = 3;

static NSString *const kTTTopBarConfigKey = @"kTTTopBarConfigKey";
static NSString *const kTTTopBarImagesDownloadKey = @"kTTTopBarImagesDownloadKey";

static NSString *const kTTTopBarConfigurationPath = @"topbar/configuration";
static NSString *const kTTTopBarImagesPath = @"topbar/images";
static NSString *const kTTTopConfigurationName = @"top_bar_configuration.zip";

static NSString *const kTTTopNightSuffix = @"_night";

NSString *const kTTPublishBackgroundImageName = @"publish_background";
NSString *const kTTPublishSearchImageName = @"publish_searchbar_background";
NSString *const kTTPublishLogoImageName = @"publish_logo";
NSString *const kTTPublishLightCameraImageName = @"publish_camera_light";
NSString *const kTTPublishDarkCameraImageName = @"publish_camera_dark";
NSString *const kTTPublishUnloginImageName = @"publish_unlogin";

@interface TTTopBarManager ()

@property (nonatomic, strong) NSDictionary *dict;//配置信息
@property (nonatomic, assign) BOOL isSigleConfigValid;//单独的配置是否可以生效
@property (nonatomic, strong) NSNumber *topBarConfigValid;//整个tab配置是否有效
@property (nonatomic, assign) BOOL isImageResourceInvalid;//图片资源是否无效
@property (nonatomic, assign) BOOL isOtherConfigurationInvalid;//其他配置是否无效
@property (nonatomic, assign) BOOL isStatusBarLight;
@property (nonatomic, copy)   NSArray<NSString *> *selectorViewTextColors;
@property (nonatomic, copy)   NSArray<NSString *> *selectorViewTextGlowColors;
@property (nonatomic, assign) CGFloat selectorViewTextGlowSize;
@property (nonatomic, assign) CGFloat textLeftOffset;
@property (nonatomic, assign) CGFloat touchAreaLeftOffset;
@property (nonatomic, copy)   NSArray<NSString *> *searchTextColors;

@property (nonatomic, strong, readwrite) dispatch_group_t completionGroup;
@property (nonatomic, strong, readwrite) dispatch_queue_t completionQueue;

@property (atomic, assign) BOOL isFetching;

@end

@implementation TTTopBarManager

#pragma mark - LifeCycle

- (instancetype)init {
    if (self = [super init]) {
        [self setupDefaultProperties];
        [self retryDonwloadZipFileIfNeed];
        [self cleanExpiredImagesIfNeed];
        [self checkImageResourceValidation];
        [self checkConfigurationValidation];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarSuccess:) name:kTTTabBarZipDownloadSuccess object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configuration

- (void)setupDefaultProperties {
    _completionQueue = dispatch_queue_create("com.bytedance.topbar", DISPATCH_QUEUE_SERIAL);
    _dict = [[TTPersistence persistenceWithName:kTTTopBarConfigurationPath] valueForKey:kTTTopBarConfigKey];
    _isStatusBarLight = YES;
    _isFetching = NO;
    [self setupConfigurationForTopBar];
}

- (void)setupConfigurationForTopBar {
    self.selectorViewTextColors = nil;
}

- (NSTimeInterval)startTime {
    return [self.dict tt_doubleValueForKey:@"start_time"];
}

- (NSTimeInterval)endTime {
    return [self.dict tt_doubleValueForKey:@"end_time"];
}

- (NSNumber *)topBarConfigValid {
    if (!_topBarConfigValid) {
        [self updateTopBarConfigValid];
    }
    return _topBarConfigValid;
}

- (void)updateTopBarConfigValid {
    BOOL isValid  = NO;
    if (![SSCommonLogic homepageUIConfigSimultaneouslyValid]) {
        isValid = self.isSigleConfigValid;
    } else {
        isValid = self.isSigleConfigValid && [TTTabBarManager sharedTTTabBarManager].isSingleConfigValid;
    }
    _topBarConfigValid = [NSNumber numberWithBool:isValid];
}

#pragma mark - Public Method

- (void)setTopBarSettingsDict:(NSDictionary *)dict {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *cachedDict = [[TTPersistence persistenceWithName:kTTTopBarConfigurationPath] valueForKey:kTTTopBarConfigKey];
        if ([dict tt_longlongValueForKey:@"version"] > [cachedDict tt_longlongValueForKey:@"version"]) {
            LOGD(@"TTTopBar 版本号变化，开始更新!!!，当前版本%lld,更新版本%lld",[cachedDict tt_longlongValueForKey:@"version"],[dict tt_longlongValueForKey:@"version"]);
            TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTopBarConfigurationPath];
            [persistence setValue:dict forKey:kTTTopBarConfigKey];
            if (!isEmptyString([dict tt_stringValueForKey:@"url"])) {
                [persistence setValue:@(NO) forKey:kTTTopBarImagesDownloadKey];
                dispatch_async(self.completionQueue, ^{
                    self.completionGroup = dispatch_group_create();
                    dispatch_group_enter(self.completionGroup);
                    if ([SSCommonLogic homepageUIConfigSimultaneouslyValid]) {
                        dispatch_group_enter(self.completionGroup);
                    }
                    dispatch_group_notify(self.completionGroup, dispatch_get_main_queue(), ^{
                        dispatch_group_notify(self.completionGroup, dispatch_get_main_queue(), ^{
                            [self immediatelyValidSurfaceWithDict:dict];
                        });
                    });
                    [self tryFetchZipFileWithURL:[dict tt_stringValueForKey:@"url"]];
                });
            } else {
                //不需要下载图片资源，则认为图片已经下载好了
                [self immediatelyValidSurfaceWithDict:dict];
            }
            [persistence save];
        } else {
            LOGD(@"TTTopBar 版本号不变，无需更新!!!");
        }
    });
}

- (UIImage *)lightPublishImage {
    UIImage *image = [self getImageForName:kTTPublishLightCameraImageName];
    if (!image) {
        image = [UIImage themedImageNamed:@"icon_release_tabbar"];
    }
    
    image = [image yy_imageByResizeToSize:CGSizeMake(kPublishIconW, kPublishIconH)];
    
    return image;
}

- (UIImage *)darkPublishImage {
    UIImage *image = [self getImageForName:kTTPublishDarkCameraImageName];
    if (!image) {
        image = [UIImage themedImageNamed:@"icon_release_tabbar_line"];
    }
    
    image = [image yy_imageByResizeToSize:CGSizeMake(kPublishIconW, kPublishIconH)];
    
    return image;
}

- (UIImage *)unloginImage {
    UIImage *image = [self getImageForName:kTTPublishUnloginImageName];
    if (!image) {
        image = [UIImage themedImageNamed:@"hs_newmine_tabbar"];
    }
    
    image = [image yy_imageByResizeToSize:CGSizeMake(kPublishIconW, kPublishIconH)];
    
    return image;
}

#pragma mark - Private Method 

- (void)checkImageResourceValidation {
    _isImageResourceInvalid = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:[[NSString stringWithFormat:@"%@/%lld",kTTTopBarImagesPath, [self.dict tt_longlongValueForKey:@"version"]] stringDocumentsPath]];
    
    NSMutableDictionary *countDict = [NSMutableDictionary dictionary];
    [countDict setValue:@(0) forKey:kTTPublishSearchImageName];
    [countDict setValue:@(0) forKey:kTTPublishBackgroundImageName];
    [countDict setValue:@(0) forKey:kTTPublishLogoImageName];
    
    //遍历该文件夹看是否有约定好的下发图片名字
    for (NSString *fileName in enumerator) {
        [[countDict allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull prefix, NSUInteger idx, BOOL * _Nonnull stop) {
            //去掉后缀名 比如icon.png => icon
            NSString *fixedName = [fileName stringByDeletingPathExtension];
            if([fixedName hasPrefix:prefix]) {
                NSUInteger count = [countDict tt_integerValueForKey:prefix];
                count++;
                if([fixedName hasSuffix:kTTTopNightSuffix]) {
                    count++;
                }
                [countDict setValue:@(count) forKey:prefix];
                *stop = YES;
            }
        }];
    }
    
    [[countDict allKeys] enumerateObjectsUsingBlock:^(NSString *  _Nonnull prefix, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger imageCount = [countDict tt_integerValueForKey:prefix];
        if([prefix isEqualToString:kTTPublishBackgroundImageName]) {
            //两个相同前缀+一个_night后缀 背景图必须有
            if (imageCount != validImageResourceNumer) {
                self.isImageResourceInvalid = YES;
                *stop = YES;
            }
        } else {
            //两个相同前缀+一个_night后缀
            if (imageCount != 0 && imageCount != validImageResourceNumer) {
                self.isImageResourceInvalid = YES;
                *stop = YES;
            }
        }
    }];
}

- (void)checkConfigurationValidation {
    NSDictionary *normalDict = [self.dict tt_dictionaryValueForKey:@"top_bar_ui_normal"];
    NSArray<NSString *> *textColors = [normalDict tt_arrayValueForKey:@"text_color"];
    NSArray<NSString *> *textGlowColors = [normalDict tt_arrayValueForKey:@"text_glow_color"];
    NSArray<NSString *> *searchTextColors = [normalDict tt_arrayValueForKey:@"search_text_color"];
    CGFloat glowSize = [normalDict tt_floatValueForKey:@"text_glow_size"] / 2.f;
    NSNumber *isStausBarLight = [normalDict valueForKey:@"status_bar_light"];
    
    if ((SSIsEmptyArray(textColors) || textColors.count == 4) && isStausBarLight && (SSIsEmptyArray(textGlowColors) || (textGlowColors.count == 4 && glowSize > 0)) && (SSIsEmptyArray(searchTextColors) || searchTextColors.count == 2)) {
        self.selectorViewTextColors = textColors;
        self.selectorViewTextGlowColors = textGlowColors;
        self.selectorViewTextGlowSize = glowSize;
        self.isStatusBarLight = isStausBarLight.boolValue;
        self.searchTextColors = searchTextColors;
        
        self.isOtherConfigurationInvalid = NO;
    } else {
        self.isOtherConfigurationInvalid = YES;
    }

    _isSigleConfigValid = [self isTopBarConfigurationValid];
}

#pragma mark - Validation

//下发配置是否有效 1.是iPhone 2.图片已经下载成功 3.自定义图片有效 4.自定义其他配置有效 5.在有效期内 6.下发了is_single_valid字段
- (BOOL)isTopBarConfigurationValid {
    TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTopBarConfigurationPath];
    BOOL imageDownLoadSuccess = [persistence valueForKey:kTTTopBarImagesDownloadKey] && ((NSNumber *)[persistence valueForKey:kTTTopBarImagesDownloadKey]).boolValue == YES;
    return ![TTDeviceHelper isPadDevice] && imageDownLoadSuccess && !self.isImageResourceInvalid && !self.isOtherConfigurationInvalid && [self isCurrentDateValid];
}

//是否在有效时效内
- (BOOL)isCurrentDateValid {
    if (self.startTime <= 0 || self.endTime <= 0) {
        return NO;
    }
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.endTime];
    NSDate *currentDate = [NSDate date];
    return [startDate compare:currentDate] != NSOrderedDescending && [currentDate compare:endDate] != NSOrderedDescending;
}

#pragma mark - Notification

- (void)connectionChanged:(NSNotification *)notification {
    TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTopBarConfigurationPath];
    if (((NSNumber *)[persistence valueForKey:kTTTopBarImagesDownloadKey]).boolValue == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
        return;
    }
    [self retryDonwloadZipFileIfNeed];
}

# pragma mark - IO

- (void)tryFetchZipFileWithURL:(NSString *)urlString {
    if (isEmptyString(urlString) || self.isFetching) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.isFetching = YES;
        
        [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
            if (!error || error.code == TTNetworkErrorCodeSuccess) {
                if ([obj isKindOfClass:[NSData class]]) {
                    [self saveImageLists:obj];
                }
            } else {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
                });
            }
            
            self.isFetching = NO;
        }];
    });
}

- (void)saveImageLists:(NSData *)fileData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTopBarConfigurationPath];
        NSDictionary *dict = [persistence valueForKey:kTTTopBarConfigKey];
        
        if(((NSNumber *)[persistence valueForKey:kTTTopBarImagesDownloadKey]).boolValue == YES) {
            return;
        }
        
        if ([[fileData md5String] isEqualToString:[dict tt_stringValueForKey:@"checksum"]]) {
            NSError *removeZipError = nil;
            
            NSString *unzipPath = [[NSString stringWithFormat:@"%@/%lld",kTTTopBarImagesPath, [dict tt_longlongValueForKey:@"version"]] stringDocumentsPath];
            NSFileManager *defaultManager = [NSFileManager defaultManager];
            //写入zip文件
            NSString * zipfile = [kTTTopConfigurationName stringDocumentsPath];
            [fileData writeToFile:zipfile atomically:YES];
            //解压文件 此处不能删除历史版本的图片，因为可能当前正在用
            [SSZipArchive unzipFileAtPath:zipfile toDestination:unzipPath];
            //删除zip文件
            if ([defaultManager fileExistsAtPath:zipfile]) {
                [defaultManager removeItemAtPath:zipfile error:&removeZipError];
            }
            
            if (!removeZipError) {
                [persistence setValue:@(YES) forKey:kTTTopBarImagesDownloadKey];
                [persistence save];
                LOGD(@"TTTopBar资源包下载成功");
                [TTSandBoxHelper disableBackupForPath:[kTTTopBarImagesPath stringDocumentsPath]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTTopBarImagesDownloadKey object:nil];
                
                dispatch_async(self.completionQueue, ^{
                    if (self.completionGroup) {
                        static dispatch_once_t onceToken;
                        dispatch_once(&onceToken, ^{
                            dispatch_group_leave(self.completionGroup);
                        });
                    }
                });
            }
        } else {
            LOGD(@"TTTopBar 资源包md5不匹配!!!");
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
            });
        }
    });
}

- (void)retryDonwloadZipFileIfNeed {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTPersistence *persistence = [TTPersistence persistenceWithName:kTTTopBarConfigurationPath];
        if (((NSNumber *)[persistence valueForKey:kTTTopBarImagesDownloadKey]).boolValue == NO && TTNetworkConnected()) {
            NSDictionary *dict = [persistence valueForKey:kTTTopBarConfigKey];
            [self tryFetchZipFileWithURL:[dict tt_stringValueForKey:@"url"]];
        }
    });
}

- (void)cleanExpiredImagesIfNeed {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *folderPath = [kTTTopBarImagesPath stringDocumentsPath];
        NSArray *folderArray = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
        for (NSString * forderNameStr in folderArray) {
            NSString * sonForderPath = [folderPath stringByAppendingPathComponent:forderNameStr];
            BOOL isDirectory = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:sonForderPath isDirectory:&isDirectory];
            //比内存中版本号还小的文件夹中的图片资源清理
            if (isDirectory && forderNameStr.longLongValue < [self.dict tt_longlongValueForKey:@"version"]) {
                [[NSFileManager defaultManager] removeItemAtPath:sonForderPath error:nil];
            }
        }
    });
}

#pragma mark -- Helper

- (UIImage *)getImageForName:(NSString *)imageName {
    UIImage *image = nil;
    
    NSString *fixedName = [[self class] themeImageNameByName:imageName];
    if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
        fixedName = [fixedName stringByAppendingString:@".png"];
    }
    NSString *fullPath = [[[NSString stringWithFormat:@"%@/%lld",kTTTopBarImagesPath, [self.dict tt_longlongValueForKey:@"version"]] stringDocumentsPath] stringByAppendingPathComponent:fixedName];
    image = [[UIImage imageWithContentsOfFile:fullPath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    image = [UIImage imageWithCGImage:image.CGImage scale:3 orientation:image.imageOrientation];
    return image;
}

+ (NSString *)themeImageNameByName:(NSString *)name {
    NSString *fixedName = name;
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight) {
        NSMutableString *resultName = [NSMutableString stringWithString:fixedName];
        NSRange lastPoint = [resultName rangeOfString:@"." options:NSBackwardsSearch];
        if(lastPoint.location != NSNotFound) {
            [resultName insertString:kTTTopNightSuffix atIndex:lastPoint.location];
        } else {
            [resultName appendString:kTTTopNightSuffix];
        }
        fixedName = resultName;
    }
    return fixedName;
}

- (void)tabBarSuccess:(NSNotification *)notification {
    dispatch_async(self.completionQueue, ^{
        if (![SSCommonLogic homepageUIConfigSimultaneouslyValid]) {
            return;
        }
        
        if (self.completionGroup) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dispatch_group_leave(self.completionGroup);
            });
        }
    });
}

- (void)immediatelyValidSurfaceWithDict:(NSDictionary *)dict {
    self.dict = dict;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkImageResourceValidation];
        [self checkConfigurationValidation];
        [self updateTopBarConfigValid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTTopBarSurfaceValidate object:nil];
            dispatch_async(self.completionQueue, ^{
                self.completionGroup = NULL;
            });
        });
    });
}

@end
