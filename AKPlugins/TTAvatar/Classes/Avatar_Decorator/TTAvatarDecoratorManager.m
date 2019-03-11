//
//  TTAvatarDecoratorManager.m
//  TTAvatar
//
//  Created by lipeilun on 2018/1/3.
//

#import "TTAvatarDecoratorManager.h"

#import <TTImageDownloader.h>
#import <YYImageCache.h>
#import <YYDiskCache.h>
#import <YYMemoryCache.h>
#import <TTThemed/TTThemeManager.h>
#import "TTBaseMacro.h"
#import <TTAccountManager.h>
#import <FRApiModel.h>
#import <TTKitchen/TTKitchenHeader.h>
#import <TTNetworkManager.h>

@interface TTAvatarDecoratorManager()
@property (nonatomic, strong) YYImageCache *decoratorCache;
@property (nonatomic, strong) NSMutableDictionary *userDecoratorUrlDict;
@end

@implementation TTAvatarDecoratorManager

+ (TTAvatarDecoratorManager *)sharedManager {
    static dispatch_once_t onceToken;
    static TTAvatarDecoratorManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [TTAvatarDecoratorManager new];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        cachePath = [cachePath stringByAppendingPathComponent:@"tt.avatar.decorator"];
        cachePath = [cachePath stringByAppendingPathComponent:@"images"];
        _decoratorCache = [[YYImageCache alloc] initWithPath:cachePath];
        _decoratorCache.memoryCache.costLimit = 10 * 1024 * 1024;
        _decoratorCache.diskCache.costLimit = 20 * 1024 * 1024;
        _decoratorCache.diskCache.ageLimit = 30 * 24 * 60 * 60;
        
        _userDecoratorUrlDict = [NSMutableDictionary dictionaryWithCapacity:100];
    }
    return self;
}

- (void)setupDecoratorWithUrl:(NSString *)urlStr nightMode:(BOOL)enableNightMode completion:(TTAvatarDecoratorCompletionBlock)block {
    if (!block || isEmptyString(urlStr)) {
        return;
    }
    
    UIImage *result = [self imageWithUrl:urlStr nightMode:enableNightMode];
    
    if (result) {
        block(result);
    } else {
        [[TTImageDownloader sharedInstance] downloadImageWithURL:urlStr options:TTWebImageDownloaderContinueInBackground progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
            if (!error && image) {
                [_decoratorCache setImage:image forKey:urlStr];
                [_decoratorCache setImage:[TTAvatarDecoratorManager nightDecoratorImage:image] forKey:[TTAvatarDecoratorManager nightKey:urlStr]] ;
                block([self imageWithUrl:urlStr nightMode:enableNightMode]);
            }
        }];
    }
}

- (void)setupDecoratorWithUserID:(NSString *)uid nightMode:(BOOL)enableNightMode completion:(TTAvatarDecoratorCompletionBlock)block {
    if (!block || isEmptyString(uid) || ![TTKitchen getBOOL:kKCUserDecorationUserIDSwitch]) {
        return;
    }

    if ([TTAccountManager isLogin] && [[TTAccountManager userID] isEqualToString:uid]) {
        block([self imageWithUrl:[TTAccountManager userDecoration] nightMode:enableNightMode]);
        return;
    }
    
    NSString *userDecoratorUrl = _userDecoratorUrlDict[uid];
    if (isEmptyString(userDecoratorUrl)) {
        //走新接口查询userDecoratorUrl
        FRUgcUserDecorationV1RequestModel *requestModel = [FRUgcUserDecorationV1RequestModel new];
        requestModel.user_ids = uid;
        [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
            if (!error) {
                FRUgcUserDecorationV1ResponseModel *model = (FRUgcUserDecorationV1ResponseModel *)responseModel;
                NSData *data = [[model.user_decoration_list.firstObject user_decoration] dataUsingEncoding:NSUTF8StringEncoding];

                if (data) {
                    NSError *error = nil;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                    if (!error) {
                        [self setupDecoratorWithUrl:[dict tt_stringValueForKey:@"url"] nightMode:enableNightMode completion:block];
                    }
                }
            }
        }];
    } else {
        [self setupDecoratorWithUrl:userDecoratorUrl nightMode:enableNightMode completion:block];
    }
}

#pragma mark - util

- (UIImage *)imageWithUrl:(NSString *)urlStr nightMode:(BOOL)enableNightMode  {
    UIImage *result;
    if (enableNightMode && [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        result = [_decoratorCache getImageForKey:[TTAvatarDecoratorManager nightKey:urlStr]];
    } else {
        result = [_decoratorCache getImageForKey:urlStr];
    }

    return result;
}

+ (NSString *)nightKey:(NSString *)str {
    return [NSString stringWithFormat:@"%@-night", str];
}

+ (UIImage *)nightDecoratorImage:(UIImage *)image {
    UIImage *img = image;
    CIImage *inputImage = [CIImage imageWithCGImage:img.CGImage];
    
    CIFilter *colorMatrixFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [colorMatrixFilter setDefaults];
    [colorMatrixFilter setValue:inputImage forKey:kCIInputImageKey];
    [colorMatrixFilter setValue:[CIVector vectorWithX:0.5 Y:0 Z:0 W:0] forKey:@"inputRVector"];
    [colorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0.5 Z:0 W:0] forKey:@"inputGVector"];
    [colorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0.5 W:0] forKey:@"inputBVector"];
    [colorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputAVector"];
    
    CIImage *outputImage = [colorMatrixFilter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];

    
    return [UIImage imageWithCGImage:cgImage];
}
@end
