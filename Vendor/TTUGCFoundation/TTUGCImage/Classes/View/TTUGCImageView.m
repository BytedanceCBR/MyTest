//
//  TTUGCImageView.m
//  Article
//
//  Created by jinqiushi on 2018/1/9.
//

#import "TTUGCImageView.h"
#import <objc/runtime.h>
#import <TTBaseLib/UIImageAdditions.h>
#import <UIColor+TTThemeExtension.h>
#import <TTImage/TTWebImageManager.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTUserSettings/TTUserSettingsManager+NetworkTraffic.h>
#import <TTKitchen/TTKitchen.h>
#import "FRImageInfoModel.h"
#import "TTUGCBDGIFLoadManager.h"
#import "NSData+ImageContentType.h"
#import "TTMonitor.h"
#import "TTThemeManager.h"
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "NetworkUtilities.h"
#import <TTBaseLib/TTDeviceHelper.h>

#import "TTUGCImageMonitor.h"
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "FRImageViewAdapter.h"
#import <BDWebImage/UIImageView+SDAdapter.h>
#import <BDWebImage/BDImageCache.h>
#import <BDWebImage/BDWebImageManager.h>
#import <BDWebImage/BDWebImage.h>
#import <TTUGCImageRecordManager.h>
#import "TTUGCImageKitchen.h"
#import "TTUGCImageHelper.h"
#import <TTKitchenExtension/TTKitchenExtension.h>

NSString * const kUGCImageViewGifRequestOverNotification = @"kUGCImageViewGifRequestOverNotification";
NSString * const kUGCImageViewGifDecodeOverNotification = @"kUGCImageViewGifDecodeOverNotification";
NSString * const kUGCImageViewBDGifRequestOverNotification = @"kUGCImageViewBDGifRequestOverNotification";

NSString * const kUGCImageViewGifInfoModelKey = @"kUGCImageViewGifInfoModelKey";


@interface TTUGCImageView ()

@property (nonatomic, strong) FRImageViewAdapter *adapter;
@property (nonatomic, strong) FRImageInfoModel *largeImageModel;
@property (nonatomic, assign) BOOL isAppear;
@property (nonatomic, assign) BOOL willRecording;
@end

@implementation TTUGCImageView
@dynamic enableAutoPlay, foreverLoop;

+ (UIImage *)imageFromMemoryCacheForImageModel:(FRImageInfoModel *)imageInfoModel {
    NSString *urlString = imageInfoModel.url;
    NSURL *imageURL = [urlString ttugc_feedImageURL];
    NSString *imageKey = [[BDWebImageManager sharedManager] requestKeyWithURL:imageURL];
    NSUInteger type = BDImageCacheTypeMemory;
    UIImage *image = [[BDImageCache sharedImageCache] imageForKey:imageKey withType:&type];
    return image;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    [self configBDFilter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBDGifSuccessNotification:) name:kUGCImageViewBDGifRequestOverNotification object:nil];
}

- (void)willAppear {
    if (!self.isAppear) {
        self.isAppear = YES;
        self.willRecording = YES;
    }
}

- (void)didDisappear {
    if (self.isAppear) {
        self.isAppear = NO;
        self.willRecording = NO;
        [TTUGCImageMonitor stopWithImageModel:self.largeImageModel];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _coverView.frame = self.bounds;
}

#pragma mark - Filter
- (void)configBDFilter {
    static dispatch_once_t onceTokenBDFilter;
    dispatch_once(&onceTokenBDFilter, ^{
        BDWebImageURLFilter *originFilter = [BDWebImageManager sharedManager].urlFilter;
        if ([originFilter isKindOfClass:[TTUGCBDWebImageURLFilter class]]) {
            return;
        }
        BDWebImageURLFilter *newFilter = [[TTUGCBDWebImageURLFilter alloc] initWithOriginFilter:originFilter];
        [BDWebImageManager sharedManager].urlFilter = newFilter;
    });
    
}

- (void)setEnableNightCover:(BOOL)enableNightCover {
    if (_enableNightCover != enableNightCover) {
        _enableNightCover = enableNightCover;
        [self refreshCoverView];
    }
}

- (void)_customThemeChanged:(NSNotification *)notification {
    [self refreshCoverView];
}

- (void)refreshCoverView {
    if (_enableNightCover && [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        if (!_coverView) {
            self.coverView = [[UIView alloc] initWithFrame:self.bounds];
            _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _coverView.backgroundColor = [UIColor colorWithHexString:@"00000099"];
            _coverView.userInteractionEnabled = NO;
            [self addSubview:_coverView];
        }
        _coverView.hidden = NO;
    }
    else {
        _coverView.hidden = YES;
    }
}

- (CGSize)intrinsicContentSize {
    if (self.preferredContentSize.width * self.preferredContentSize.height == 0) {
        return [super intrinsicContentSize];
    }
    return self.preferredContentSize;
}

- (void)clearImage {
    [self.adapter.imageView sd_setImageWithURL:nil];
    [self.adapter.imageView bd_cancelImageLoad];
    self.adapter.imageView.image = nil;
    self.largeImageModel = nil;
}

#pragma mark - 对外接口
- (void)ugc_setImageWithModel:(FRImageInfoModel *)imageModel {
    [self ugc_setImageWithLargeModel:imageModel
                          thumbModel:imageModel];
}


- (void)ugc_setImageWithLargeModel:(FRImageInfoModel *)largeModel
                        thumbModel:(FRImageInfoModel *)thumbModel {
        [self ugc_bd_setImageWithLargeModel:largeModel thumbModel:thumbModel];
}



#pragma mark - 图片逻辑

- (void)ugc_setImageWithLocalPath:(NSString *)localPath {
    [self clearImage];
    if (!isEmptyString(localPath)) {
        NSData *uploadData = [NSData dataWithContentsOfFile:localPath];
        if (uploadData) {
            self.adapter.animatedImageData = uploadData;
        }
    }
}



#pragma mark - Gif相关逻辑

- (void)startGifAnimation {
    [self.adapter startGifAnimation];
}

- (void)stopGifAnimation {
    [self.adapter stopGifAnimation];
}

- (void)loadingGifStart {
    //派生类实现
}

- (void)loadingGifEnd {
    //派生类实现
}

#pragma mark - Getter & Setter

- (FRImageViewAdapter *)adapter {
    if (_adapter == nil) {
        _adapter = [[FRImageViewAdapter alloc] initWithFrame:self.bounds];
        [_adapter.imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        _adapter.imageView.clipsToBounds = YES;
        [_adapter.imageView setContentMode:UIViewContentModeScaleAspectFill];
        WeakSelf;
        _adapter.gifLoopCompletionBlock = ^{
            StrongSelf;
            if ([self.gifDelegate respondsToSelector:@selector(gifPlayOverImageView:)]) {
                [self.gifDelegate gifPlayOverImageView:self];
            }
        };
        [self addSubview:_adapter.imageView];
        [self sendSubviewToBack:_adapter.imageView];
    }
    return _adapter;
}

- (UIImage *)image
{
    return self.adapter.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.adapter.imageView.image = image;
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    self.adapter.imageView.contentMode = contentMode;
}

- (void)setEnableAutoPlay:(BOOL)enableAutoPlay {
    self.adapter.enableAutoPlay = enableAutoPlay;
}

- (BOOL)enableAutoPlay {
    return self.adapter.enableAutoPlay;
}

- (void)setForeverLoop:(BOOL)foreverLoop {
    self.adapter.foreverLoop = foreverLoop;
}

- (BOOL)foreverLoop {
    return self.adapter.foreverLoop;
}

- (CALayer *)layer {
    return self.adapter.imageView.layer;
}

//换BD下载
#pragma mark - BD下载相关

- (void)ugc_bd_setImageWithModel:(FRImageInfoModel *)imageModel
{
    [self ugc_bd_setImageWithLargeModel:imageModel
                             thumbModel:imageModel];
}


- (void)ugc_bd_setImageWithLargeModel:(FRImageInfoModel *)largeModel
                           thumbModel:(FRImageInfoModel *)thumbModel {
    if ([TTUserSettingsManager networkTrafficSetting] != TTNetworkTrafficSave
        || TTNetworkWifiConnected()) {
        //不是极省流量或者wifi下，走显示和下载逻辑。
        if (largeModel.type == FRImageTypeGif && TTNetworkConnected()) {
            //gif且wifi环境,走gif下载播放的逻辑
            [self ugc_bd_newSetImageWithGifLargeModel:largeModel thumbModel:thumbModel];
        } else {
            //展示thumb的逻辑。
            //直接开始普通的sd下载和设置逻辑，各种逻辑交给bd去做。
            [self ugc_bd_setImageWithModel:thumbModel
                          placeholderImage:nil
                                   options:nil];
        }
        
    } else {
        //否则走cache显示逻辑。
        NSURL *thumbURL = [thumbModel.url ttugc_feedImageURL];
        NSString *thumbKey = [[BDWebImageManager sharedManager] requestKeyWithURL:thumbURL];
        [[BDImageCache sharedImageCache] imageForKey:thumbKey withType:BDImageCacheTypeAll withBlock:^(UIImage *image, BDImageCacheType type) {
            if (image) {
                self.adapter.imageView.image = image;
            }
        }];
    }
    
}
    
    - (void)setLargeImageModel:(FRImageInfoModel *)largeImageModel {
        if (largeImageModel == nil) {
            NSLog(@"jqs large nil");
        }
        _largeImageModel = largeImageModel;
    }

//这个是新尝试写的gif逻辑。
- (void)ugc_bd_newSetImageWithGifLargeModel:(FRImageInfoModel *)largeModel
                                 thumbModel:(FRImageInfoModel *)thumbModel {
    self.largeImageModel = largeModel;
    
    NSURL *largeURL = [largeModel.url ttugc_feedImageURL];
    NSURL *thumbURL = [thumbModel.url ttugc_feedImageURL];
    
    NSString *largeKey = [[BDWebImageManager sharedManager] requestKeyWithURL:largeURL];
    if (self.willRecording &&
        ![largeModel isEqual:thumbModel] &&
        largeModel.type == FRImageTypeGif) {
        [TTUGCImageMonitor startWithImageModel:largeModel];
        self.willRecording = NO;
    }
    
    [self _ugc_bd_setImageWithURL:thumbURL
                 placeholderImage:nil
                          options:BDImageRequestDefaultOptions
                        completed:^(BDWebImageRequest *request, UIImage *thumbImage, NSData *data, NSError *error, BDWebImageResultFrom from) {
                            //直接无脑展示缩略图。
                            [[BDImageCache sharedImageCache] imageForKey:largeKey withType:BDImageCacheTypeAll withBlock:^(UIImage *largeImage, BDImageCacheType type) {
                                //先这么改，不确定是否有问题。
                                if (largeImage) {
                                    [self _ugc_bd_setImageWithURL:largeURL
                                                 placeholderImage:thumbImage
                                                          options:nil
                                                        completed:nil];
                                } else {
                                    //没缓存
                                    //启动gif的下载逻辑。
                                    //这回得用bd的方式下载gif。
//                                    [[TTUGCBDGIFLoadManager sharedManager] startDownloadGifImageModel:largeModel];
                                }
                            }];
                        }];
    
}

#pragma mark - 图片逻辑
- (void)ugc_bd_setImageWithModel:(FRImageInfoModel *)model
                placeholderImage:(UIImage *)placeholder
                         options:(BDImageRequestOptions)options {
    if ([[model url_list] count] > 0) {
        //先进行cdn 降权排序
        NSArray *urlList = [[TTWebImageManager shareManger] sortedImageArray:model.url_list];
        //忽略警告强转
        model.url_list = (NSArray <TTImageURLInfoModel>*)urlList;
        [self _ugc_bd_setImageWithModel:model index:0 placeholderImage:placeholder options:options];
    }
    else {
        NSLog(@"TTWarning model url_list count can not be 0 !!!");
    }
}

- (void)ugc_bd_setImageWithLocalPath:(NSString *)localPath {
    [self clearImage];
    if (!isEmptyString(localPath)) {
        NSData *uploadData = [NSData dataWithContentsOfFile:localPath];
        if (uploadData) {
            self.adapter.animatedImageData = uploadData;
        }
    }
}

- (void)_ugc_bd_setImageWithModel:(FRImageInfoModel *)model
                            index:(NSUInteger)index
                 placeholderImage:(UIImage *)placeholder
                          options:(BDImageRequestOptions)options {
    NSUInteger count = [[model url_list] count];
    if (count == 0) {
        NSLog(@"TTWarning :image model url_list count is 0 !!!");
        return;
    }
    if (index >= count) {
        NSLog(@"TTWarning: image count out of boundary");
        return;
    }
    
    FRImageInfoModel * URLModel = model.url_list[index];
    NSString * tURL = URLModel.url;
    
    if (isEmptyString(tURL)) {
        return;
    }
    
    NSURL *imageURL = [tURL ttugc_feedImageURL];
    WeakSelf;
    [self _ugc_bd_setImageWithURL:imageURL
                 placeholderImage:placeholder
                          options:options
                        completed:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
                            if (error) {
                                StrongSelf;
                                //记录失败url
                                [[TTWebImageManager shareManger] recordOneFailItem:[TTStringHelper URLWithURLString:tURL]];
                                NSUInteger idx = index + 1;
                                if (idx < count) {
                                    [self _ugc_bd_setImageWithModel:model index:idx placeholderImage:placeholder options:options];
//                                    [self _ugc_setImageWithModel:model index:idx placeholderImage:placeholder options:options];
                                } else {
                                    // 静图失败节点
                                    if (model == self.largeImageModel) {
                                        [TTUGCImageMonitor requestCompleteWithImageModel:model withSuccess:NO];
                                    }
                                }
                            } else {
                                //记录cost
                                if (self.enablefirstLoadAnimation && BDWebImageResultFromDownloading == from) {
                                    //copy from nick
                                    if ([TTDeviceHelper getDeviceType] == TTDeviceMode568
                                        || [TTDeviceHelper getDeviceType] == TTDeviceMode480) {
                                        //低设备donothing
                                    }else {
                                        [UIView animateWithDuration:0.5 animations:^{
                                            self.adapter.imageView.alpha = 0;
                                            self.adapter.imageView.alpha = 1;
                                        } completion:^(BOOL finished) {
                                            self.adapter.imageView.alpha = 1;
                                        }];
                                    }
                                }
                                
                                
                                [[TTUGCImageRecordManager sharedInstance] trackSetImageForURL:imageURL];
                                
                                if (model == self.largeImageModel) {
                                    [TTUGCImageMonitor requestCompleteWithImageModel:model withSuccess:YES];
                                }
                            }
                        }];
    
}

- (void)_ugc_bd_setImageWithURL:(NSURL *)url
               placeholderImage:(UIImage *)placeholder
                        options:(BDImageRequestOptions)options
                      completed:(BDImageRequestCompletedBlock)completedBlock {
    if (url &&
        [TTKitchen getBOOL:kTTKUGCImageRequestRepeatEnable] &&
        [self.adapter.imageView.bd_imageURL isEqual:url] ) {
        return;
    }
    __weak TTUGCImageView *weakSelf = self;
    
    [self.adapter.imageView bd_setImageWithURL:url
                                   placeholder:placeholder
                                       options:options
                                    completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
                                        if (completedBlock) {
                                            completedBlock(request,image,data,error,from);
                                        }
                                    }];
    
}

#pragma mark - BDGif相关逻辑
- (void)handleBDGifSuccessNotification:(NSNotification *)notification {
    FRImageInfoModel *notiModel = [notification.userInfo tt_objectForKey:kUGCImageViewGifInfoModelKey];
    if ([notiModel isKindOfClass:[FRImageInfoModel class]]
        && [[self bdKeyForImageModel:notiModel] isEqualToString:[self bdKeyForImageModel:self.largeImageModel]]) {
        //匹配上 展示gif
        NSURL *url = [self.largeImageModel.url ttugc_feedImageURL];
        NSString *bdKey = [[BDWebImageManager sharedManager] requestKeyWithURL:url];
//        [self _ugc_bd_setImageWithURL:url placeholderImage:self.adapter.imageView.image options:BDImageRequestDefaultOptions completed:nil];
        
//        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//        [userInfo setValue:weakSelf.largeImageModel forKey:kUGCImageViewGifInfoModelKey];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kUGCImageViewGifDecodeOverNotification object:nil userInfo:userInfo];
        WeakSelf;
        [self _ugc_bd_setImageWithURL:url placeholderImage:self.adapter.imageView.image options:BDImageRequestDefaultOptions completed:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            if (!error) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:wself.largeImageModel forKey:kUGCImageViewGifInfoModelKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:kUGCImageViewGifDecodeOverNotification object:nil userInfo:userInfo];
            }
        }];
    }
}

- (NSString *)bdKeyForImageModel:(FRImageInfoModel *)imageModel {
    NSURL *URL = [imageModel.url ttugc_feedImageURL];
    return [[BDWebImageManager sharedManager] requestKeyWithURL:URL];

}

@end



@implementation TTUGCBDWebImageURLFilter {
    BDWebImageURLFilter *_originFilter;
}

- (instancetype)initWithOriginFilter:(BDWebImageURLFilter *)originFilter {
    self = [super init];
    if (self) {
        _originFilter = originFilter;
    }
    return self;
}

- (NSString *)identifierWithURL:(NSURL *)url {
    if ([url.ttugc_source isEqualToString:kTTUGCImageSource]
        && [TTUGCImageKitchen matchImageCacheOptimizeHost:url.host]) {
        NSString *absoluteString = url.absoluteString;
        NSRange hostRange = [absoluteString rangeOfString:url.host];
        NSRange deleteRange = NSMakeRange(0, hostRange.location + hostRange.length);
        return [absoluteString stringByReplacingCharactersInRange:deleteRange withString:@""];
    } else if (_originFilter) {
        return [_originFilter identifierWithURL:url];
    } else {
        return url.absoluteString;
    }
}

@end
