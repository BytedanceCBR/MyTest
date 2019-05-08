//
//  TTDetailWebviewGIFManager.m
//  Pods
//
//  Created by xushuangqing on 2017/8/7.
//
//

#import "TTDetailWebviewGIFManager.h"
#import "SSJSBridgeWebView.h"
#import "TTDetailWebviewContainer.h"
#import "TTWebImageManager.h"
#import "NSDictionary+TTAdditions.h"
#import "FLAnimatedImageView+WebCache.h"
#import "TTThemeManager.h"
#import <YYImage/YYImage.h>
#import <CoreGraphics/CoreGraphics.h>
#import <mach/mach.h>
#import "TTDetailWebviewContainer.h"

#pragma mark - Tools

/**
 计算buffer的策略参考自YYImage
 FLAnimationImage默认会将帧数多的gif的buffer设为1帧，导致消耗的CPU比YYImage要高，但内存接近（因buffer中的帧不会占用formular内存）
 由于FLAnimationImage支持pause/resume，故使用FLAnimationImage，同时手动传入buffer大小参数
 */
#define BUFFER_SIZE (10 * 1024 * 1024) // 10MB (minimum memory buffer size)

/**
 获取当前设备总内存，参考_YYDeviceMemoryTotal
 由于[[NSProcessInfo processInfo] physicalMemory]在低端机上较慢，故缓存结果
 */
static int64_t _TTDeviceMemoryTotal() {
    static int64_t mem = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mem = [[NSProcessInfo processInfo] physicalMemory];
    });
    if (mem < -1) mem = -1;
    return mem;
}

/**
 获取当前设备剩余内存，参考_YYDeviceMemoryFree
 经测试该方法速度ok
 */
static int64_t _TTDeviceMemoryFree() {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size;
}

/**
 将GIF中的静帧存到磁盘中，用户传给fe
 */
@interface TTDetailWebviewGIFFramePersistenceHelper : NSObject

+ (NSString *)saveGIFFrameToDiskAsPNG:(UIImage *)image;
+ (void)removeAllGIFFramePersistence;

@end

@implementation TTDetailWebviewGIFFramePersistenceHelper

+ (NSString *)saveGIFFrameToDiskAsPNG:(UIImage *)image {
    @autoreleasepool {
        NSData *pngData = UIImagePNGRepresentation(image);
        @synchronized(self) {
            @try {
                /**
                 存入路径必须在WKWebview的可加载路径之下，否则fe无法载入图片
                 */
                NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                NSString *dictionaryPath = [cachePath stringByAppendingPathComponent:@"tt_detail_gif_frame"];
                BOOL isDirectory = NO;
                NSError * createDireError = nil;
                if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath isDirectory:&isDirectory]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:&createDireError];
                }
                NSString *uuid = [[NSUUID UUID] UUIDString];
                NSString *filename = [dictionaryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", uuid]];
                NSURL *url = [NSURL fileURLWithPath:filename];
                BOOL success = [pngData writeToURL:url atomically:YES];
                if (success) {
                    return [url absoluteString];
                }
                else {
                    return nil;
                }
            }
            @catch (NSException *exception) {
                return nil;
            }
            @finally {
                
            }
        }
    }
}

+ (void)removeAllGIFFramePersistence {
    @synchronized(self) {
        @try {
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            NSString *dictionaryPath = [cachePath stringByAppendingPathComponent:@"tt_detail_gif_frame"];
            [[NSFileManager defaultManager] removeItemAtPath:dictionaryPath error:nil];
            return;
        }
        @catch (NSException *exception) {
            return;
        }
        @finally {
            
        }
    }
}

@end

#pragma mark - TTDetailWebviewGIFModel

@protocol TTDetailWebviewGIFModelDelegate;

@interface TTDetailWebviewGIFModel : NSObject

@property (nonatomic, assign, readonly) NSInteger index; /*index表示的是该详情页第idx张图片，并非第idx张gif*/
@property (nonatomic, weak, readonly) id<TTDetailWebviewGIFModelDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isRealGIF; /*是否是真正的动图，比如小图模式下的gif就不是动图*/
@property (nonatomic, assign, readonly) CGRect frame;/*gif的位置和尺寸信息*/

@property (nonatomic, assign) NSInteger gifFrameIndex;/*当前gif播放到了哪一帧*/
//@property (nonatomic, copy) NSString *gifFrameLocalPath;/*当前gif播放到的那一帧对应的png图像地址，用于传递给fe，这些图像会随着model的销毁而删除*/

@property (nonatomic, assign) BOOL inWindow;/*当前的webview是否可见*/
@property (nonatomic, assign) BOOL inSight;/*当前的gif是否在webview的可见范围内*/

/**
 仅可赋值一次
 */
@property (nonatomic, strong) TTImageInfosModel *imageInfosModel;
@property (nonatomic, strong) NSString *cachePath;
@property (nonatomic, assign) int64_t sizePerFrame;

- (void)handleBecomesRealGIF;

@end

@protocol TTDetailWebviewGIFModelDelegate <NSObject>

@required
- (void)gifModel:(TTDetailWebviewGIFModel *)gifModel didUpdateInSight:(BOOL)inSight;
- (void)gifModel:(TTDetailWebviewGIFModel *)gifModel didUpdateFrame:(CGRect)frame;
- (BOOL)gifModel:(TTDetailWebviewGIFModel *)gifModel isFrameInSight:(CGRect)frame;

@end

@implementation TTDetailWebviewGIFModel

@synthesize cachePath = _cachePath;

- (void)dealloc {
    //NSLog(@"xxx GIFModel dealloc %@", self);
}

- (instancetype)initWithIndex:(NSInteger)index frame:(CGRect)frame inSight:(BOOL)inSight inWindow:(BOOL)inWindow delegate:(id<TTDetailWebviewGIFModelDelegate>)delegate {
    self = [super init];
    if (self) {
        _frame = frame;
        _index = index;
        _delegate = delegate;
        _inWindow = inWindow;
        _inSight = inSight;
        _isRealGIF = NO;
    }
    return self;
}

- (void)setImageInfosModel:(TTImageInfosModel *)imageInfosModel {
    if (_imageInfosModel) {
        //NSLog(@"xxx warining !!! imageInfosModel仅可被赋值一次");
        return;
    }
    _imageInfosModel = imageInfosModel;
}

- (NSString *)cachePath {
    if (!_cachePath) {
        if (self.imageInfosModel) {
            _cachePath = [TTWebImageManager cachePathForModel:self.imageInfosModel];
        }
    }
    return _cachePath;
}

- (void)setCachePath:(NSString *)cachePath {
    if (_cachePath) {
        //NSLog(@"xxx warining !!! cachePath仅可被赋值一次");
        return;
    }
    _cachePath = cachePath;
    WeakSelf;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:cachePath];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
        int64_t bytes = CGImageGetBytesPerRow(image.posterImage.CGImage) * CGImageGetHeight(image.posterImage.CGImage);;
        if (bytes == 0) bytes = 1024;
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf;
            self.sizePerFrame = bytes;
        });
    });
}

- (int64_t)sizePerFrame {
    if (!_cachePath) {
        return 1024;
    }
    if (!_sizePerFrame) {
        NSData *data = [NSData dataWithContentsOfFile:_cachePath];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
        int64_t bytes = CGImageGetBytesPerRow(image.posterImage.CGImage) * CGImageGetHeight(image.posterImage.CGImage);;
        if (bytes == 0) bytes = 1024;
        _sizePerFrame = bytes;
    }
    return _sizePerFrame;
}

- (void)updateFrame:(CGRect)frame {
    
    if (CGRectEqualToRect(_frame, frame)) {
        return;
    }
    
    //先更新frame后更新insight，避免inSight=NO后再更新frame导致view已空
    _frame = frame;
    [self.delegate gifModel:self didUpdateFrame:frame];
    
    BOOL isFrameInSight = [self.delegate gifModel:self isFrameInSight:frame];
    self.inSight = isFrameInSight;
}

- (void)handleBecomesRealGIF {
    //NSLog(@"handleBecomeRealGif %@", self);
    if (_isRealGIF == YES) {
        return;
    }
    _isRealGIF = YES;
    [self.delegate gifModel:self didUpdateInSight:_inSight && _inWindow];
}

- (void)setInSight:(BOOL)inSight {
    if (inSight == _inSight) {
        return;
    }
    _inSight = inSight;
    [self.delegate gifModel:self didUpdateInSight:_inSight && _inWindow];
}

- (void)setInWindow:(BOOL)inWindow {
    if (inWindow == _inWindow) {
        return;
    }
    _inWindow = inWindow;
    [self.delegate gifModel:self didUpdateInSight:_inSight && _inWindow];
}

@end

#pragma mark - TTDetailWebviewGIFView

@interface TTDetailWebviewGIFView : FLAnimatedImageView

@property (nonatomic, assign, readonly) NSInteger index;/*index表示的是该详情页第idx张图片，并非第idx张gif*/
@property (nonatomic, strong, readonly) NSString *cachePath;
//@property (nonatomic, strong) UIView *coverView;/*夜间模式的遮罩*/ //因fe中没有用遮罩，而是采用图片自身降低到50%透明度来实现夜间模式效果，故暂时取消
@property (nonatomic, assign) BOOL hiddenForCssAnimation;/*当前是否在进行css动画，动画期间native gif view应该hidden*/

- (instancetype)initWithIndex:(NSInteger)index frame:(CGRect)frame cachePath:(NSString *)cachePath bytesPerFrame:(int64_t)bytes;
- (void)startAnimatingFromFrame:(NSInteger)frame;
- (void)stopAnimating;

@end

@implementation TTDetailWebviewGIFView

- (void)dealloc {
    //NSLog(@"xxx GIFView dealloc %@", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithIndex:(NSInteger)index frame:(CGRect)frame cachePath:(NSString *)cachePath bytesPerFrame:(int64_t)bytes {
    self = [super initWithFrame:frame];
    if (self) {
        _index = index;
        _cachePath = cachePath;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_customThemeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
        NSData *imageDate = [NSData dataWithContentsOfFile:_cachePath];
        
        //计算optimalFrameCacheSize，策略参考YYImage
        int64_t total = _TTDeviceMemoryTotal();
        int64_t free = _TTDeviceMemoryFree();
        int64_t max = MIN(total * 0.2, free * 0.6);
        max = MAX(max, BUFFER_SIZE);
        double maxBufferCount = (double)max / (double)bytes;
        if (maxBufferCount < 1) maxBufferCount = 1;
        else if (maxBufferCount > 512) maxBufferCount = 512;

        //NSLog(@"xxx maxBufferCount %f", maxBufferCount);
        
        WeakSelf;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //FLAnimatedImage的创建有些耗时，放到异步线程中创建
            FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:imageDate optimalFrameCacheSize:maxBufferCount predrawingEnabled:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongSelf;
                NSInteger frameIndex = self.currentFrameIndex;
                self.animatedImage = image;
                //这里指定了需要播放的帧，虽然没有public接口，但是作者表示也可以访问一下
                //https://github.com/Flipboard/FLAnimatedImage/issues/52
                [self setValue:@(frameIndex) forKey:@"currentFrameIndex"];
            });
        });
        
        [self refreshCoverView];
    }
    return self;
}

- (void)_customThemeChanged:(NSNotification *)notification {
    [self refreshCoverView];
}

//- (void)refreshCoverView {
//    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
//        if (!_coverView) {
//            self.coverView = [[UIView alloc] initWithFrame:self.bounds];
//            _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//            _coverView.backgroundColor = [UIColor colorWithHexString:@"00000080"];
//            _coverView.userInteractionEnabled = NO;
//            [self addSubview:_coverView];
//        }
//        _coverView.hidden = YES;
//        self.alpha = 0.5;
//    }
//    else {
//        _coverView.hidden = YES;
//        self.alpha = 1.0;
//    }
//}

- (void)refreshCoverView {
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        self.backgroundColor = [UIColor colorWithHexString:@"2b2b2b"];
        self.alpha = 0.5;
    }
    else {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 1.0;
    }
}

- (void)startAnimatingFromFrame:(NSInteger)frame {
    //这里指定了需要播放的帧，虽然没有public接口，但是作者表示也可以访问一下
    //https://github.com/Flipboard/FLAnimatedImage/issues/52
    [self setValue:@(frame) forKey:@"currentFrameIndex"];
    if (!self.hiddenForCssAnimation) {
        [self startAnimating];
    }
}

- (void)stopAnimating {
    [super stopAnimating];
}

- (void)setHiddenForCssAnimation:(BOOL)hiddenFarCssAnimation {
    if (_hiddenForCssAnimation == hiddenFarCssAnimation) {
        return;
    }
    _hiddenForCssAnimation = hiddenFarCssAnimation;
    self.hidden = hiddenFarCssAnimation;
    if (hiddenFarCssAnimation) {
        [self stopAnimating];
    }
    else {
        [self startAnimating];
    }
}

@end

#pragma mark -

@interface TTDetailWebviewGIFManager ()<TTDetailWebviewGIFModelDelegate>

//FE认为当前详情页内是gif类型的所有图 || 当前详情页内真正的gif图，前者应该是后者的超集
@property (nonatomic, strong) NSMutableDictionary<NSNumber */*image index*/, TTDetailWebviewGIFModel *> *gifModels;

//当前详情页内所有**在视线范围内**的gif图
@property (nonatomic, strong) NSMutableDictionary<NSNumber */*image index*/, TTDetailWebviewGIFView *> *gifViews;

@property (nonatomic, assign) BOOL inWindow;

@property (nonatomic, assign) BOOL cssAnimating;

@end

@implementation TTDetailWebviewGIFManager

static NSString *const kTTSSCommonLogicDetailGIFNativeKey = @"kTTSSCommonLogicDetailGIFNativeKey";

+ (void)setDetailViewGifNativeEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kTTSSCommonLogicDetailGIFNativeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 只在新浮层上做gif改造
 */
+ (BOOL)isDetailViewGifNativeEnabled {
    static BOOL enabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kTTSSCommonLogicDetailGIFNativeKey];
    });
    BOOL newlyNatantStyleEnabled = [TTDetailWebviewContainer newNatantStyleEnabled];
    return enabled && newlyNatantStyleEnabled;
}

- (void)dealloc {
    //NSLog(@"xxx TTDetailWebviewGIFManager dealloc");
    [TTDetailWebviewGIFFramePersistenceHelper removeAllGIFFramePersistence];
}

- (instancetype)initWithWebview:(SSJSBridgeWebView *)webview isInWindow:(BOOL)inWindow{
    
    if (![TTDetailWebviewGIFManager isDetailViewGifNativeEnabled]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _inWindow = inWindow;
        WeakSelf;
        //注册两个bridge
        //updateGIFPositions: 当gif位置发生瞬时变化时，fe通知所有gif图变化后的位置
        [webview.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
            StrongSelf;
            //NSLog(@"xxx updateGifPosition\n%@", result);
            [self p_handleGIFPositionUpdate:result];
        } forMethodName:@"updateGIFPositions"];
        
        //NativePlayGif: 当css动画发生时，fe通知native进行抽帧、删除gif贴片、加回贴片
        [webview.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
            StrongSelf;
            //NSLog(@"xxx NativePlayGif\n%@", params);
            NSString *action = [params tt_stringValueForKey:@"action"];
            if ([action isEqualToString:@"getFrames"]) {
                [self p_asyncStopAndGetGifFramesWithCompletion:^(NSDictionary<NSNumber *,NSString *> *imagePathStored) {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    [imagePathStored enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                        [array addObject:@[key, obj, @"origin"]];
                    }];
                    //NSLog(@"frames callback\n%@", array);
                    completion(TTRJSBMsgSuccess, @{@"frames":array});
                }];
            }
            if ([action isEqualToString:@"animationWillStart"]) {
                self.cssAnimating = YES;
            }
            if ([action isEqualToString:@"animationDidEnd"]) {
                self.cssAnimating = NO;
                completion(TTRJSBMsgSuccess, nil);
            }
        } forMethodName:@"NativePlayGif"];
    }
    return self;
}

/**
 异步的获取所有gif图的当前静帧，同时暂停播放：如果某gif在可见区域内，则立即抽帧；如果不在可见区域内，则从它消失时保存的帧中获取

 @param completion 完成后将静帧的local url传出
 */
- (void)p_asyncStopAndGetGifFramesWithCompletion:(void (^)(NSDictionary<NSNumber *, NSString *> *imagePathStored))completion {
    
    NSMutableDictionary<NSNumber *, UIImage *> *imagesToBeStore = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSNumber *, NSString *> *imagePathStored = [[NSMutableDictionary alloc] init];
    [self.gifModels enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, TTDetailWebviewGIFModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if (!obj.isRealGIF) {
            return;
        }
        if (obj.inSight) {
            TTDetailWebviewGIFView *gifView = [self.gifViews objectForKey:key];
            if (!gifView) {
                //NSLog(@"xxx warning!!!! should have gifView!!!");
                return;
            }
            [gifView stopAnimating];
            if (gifView) {
                UIImage *currentFrame = [gifView currentFrame];
                if (!currentFrame) {
                    //NSLog(@"xxx warning!!!! should have currentFrame!!!");
                    return;
                }
                [imagesToBeStore setObject:currentFrame forKey:key];
            }
        }
        //把所有图片都加进来可能会导致OOM，为了稳妥先去掉该逻辑
//        else if (obj.gifFrameLocalPath) {
//            [imagePathStored setObject:obj.gifFrameLocalPath forKey:key];
//        }
        else {
            //NSLog(@"xxx no frame %@", key);
        }
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [imagesToBeStore enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIImage * _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *path = [TTDetailWebviewGIFFramePersistenceHelper saveGIFFrameToDiskAsPNG:obj];
            [imagePathStored setObject:path forKey:key];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(imagePathStored);
            }
        });
    });
}


/**
 更新gif位置

 @param result fe传出的所有gif位置
 */
- (void)p_handleGIFPositionUpdate:(NSDictionary *)result {
    [result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //fe无法将key作为number传出来，所以客户端自行转换成number
        if ([key isKindOfClass:[NSString class]]) {
            key = [NSNumber numberWithInteger:[key integerValue]];
        }
        if ([key isKindOfClass:[NSNumber class]] && [obj isKindOfClass:[NSDictionary class]]) {
            TTDetailWebviewGIFModel *gifModel = [self.gifModels objectForKey:key];
            CGRect rect = gifModel.frame;
            if ([obj objectForKey:@"x"]) {
                rect.origin.x = [obj tt_doubleValueForKey:@"x"];
            }
            if ([obj objectForKey:@"y"]) {
                rect.origin.y = [obj tt_doubleValueForKey:@"y"];
            }
            if ([obj objectForKey:@"width"]) {
                rect.size.width = [obj tt_doubleValueForKey:@"width"];
            }
            if ([obj objectForKey:@"height"]) {
                rect.size.height = [obj tt_doubleValueForKey:@"height"];
            }
            BOOL inSight = NO;
            if ([self.delegate respondsToSelector:@selector(gifManager:isFrameInSight:)]) {
                inSight = [self.delegate gifManager:self isFrameInSight:rect];
            }
            if (!gifModel || ![gifModel isKindOfClass:[TTDetailWebviewGIFModel class]]) {
                gifModel = [[TTDetailWebviewGIFModel alloc] initWithIndex:[key integerValue] frame:rect inSight:inSight inWindow:self.inWindow delegate:self];
                [self.gifModels setObject:gifModel forKey:key];
            }
            [gifModel updateFrame:rect];
        }
    }];
}

#pragma mark - public methods

- (void)handleWebviewContainerWillAppear {
    self.inWindow = YES;
}

- (void)handleWebviewContainerDidDisappear {
    self.inWindow = NO;
}

- (void)handleContainerScrollViewScroll:(SSThemedScrollView *)containerScrollView inContainer:(TTDetailWebviewContainer *)container {
    [self.gifModels enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, TTDetailWebviewGIFModel * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL inSight = NO;
        if ([self.delegate respondsToSelector:@selector(gifManager:isFrameInSight:)]) {
            inSight = [self.delegate gifManager:self isFrameInSight:obj.frame];
        }
        obj.inSight = inSight;
    }];
}

- (void)resumeGifView:(UIView *)gifView {
    if (![gifView isKindOfClass:[TTDetailWebviewGIFView class]]) {
        return;
    }
    TTDetailWebviewGIFView *detailGifView = (TTDetailWebviewGIFView *)gifView;
    TTDetailWebviewGIFModel *gifModel = [_gifModels tt_objectForKey:@(detailGifView.index) ofClass:[TTDetailWebviewGIFModel class]];
    [detailGifView startAnimatingFromFrame:gifModel.gifFrameIndex];
}

- (void)pauseGifView:(UIView *)gifView {
    if (![gifView isKindOfClass:[TTDetailWebviewGIFView class]]) {
        return;
    }
    TTDetailWebviewGIFView *detailGifView = (TTDetailWebviewGIFView *)gifView;
    TTDetailWebviewGIFModel *gifModel = [_gifModels tt_objectForKey:@(detailGifView.index) ofClass:[TTDetailWebviewGIFModel class]];
    gifModel.gifFrameIndex = detailGifView.currentFrameIndex;
    
    //将当前帧保存成png图片
//    UIImage *gifFrameImage = [detailGifView currentFrame];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        NSString *gifFramePath = [TTDetailWebviewGIFFramePersistenceHelper saveGIFFrameToDiskAsPNG:gifFrameImage];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            gifModel.gifFrameLocalPath = gifFramePath;
//        });
//    });
    
    [detailGifView stopAnimating];
}

- (BOOL)shouldUseNativeGIFPlayer:(TTImageInfosModel *)model imageIndex:(NSInteger)index {
    
    NSString *cachePath = [TTWebImageManager cachePathForModel:model];
    NSData *data = [NSData dataWithContentsOfFile:cachePath];
    BOOL isGif = [[self class] isGIFData:data];
    
    if (!isGif) {
        return NO;
    }
    
    TTDetailWebviewGIFModel *gifModel = [self.gifModels tt_objectForKey:@(index) ofClass:[TTDetailWebviewGIFModel class]];
    if (!gifModel) {
        gifModel = [[TTDetailWebviewGIFModel alloc] initWithIndex:index frame:CGRectZero inSight:NO inWindow:self.inWindow delegate:self];
        [self.gifModels setObject:gifModel forKey:@(index)];
    }
    
    if (!gifModel.isRealGIF) {
        gifModel.imageInfosModel = model;
        gifModel.cachePath = cachePath;
        [gifModel handleBecomesRealGIF];
    }
    
    BOOL inSight = NO;
    if ([self.delegate respondsToSelector:@selector(gifManager:isFrameInSight:)]) {
        inSight = [self.delegate gifManager:self isFrameInSight:gifModel.frame];
    }
    gifModel.inSight = inSight;
    return YES;
}

#pragma mark - tools

+ (BOOL)isGIFData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    if (c == 0x47) {
        return YES;
    }
    return NO;
}

#pragma mark - accessors

- (void)setInWindow:(BOOL)inWindow {
    if (_inWindow == inWindow) {
        return;
    }
    _inWindow = inWindow;
    [self.gifModels enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, TTDetailWebviewGIFModel * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.inWindow = inWindow;
    }];
}

- (void)setCssAnimating:(BOOL)cssAnimating {
    if (_cssAnimating == cssAnimating) {
        return;
    }
    _cssAnimating = cssAnimating;
    [self.gifViews enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, TTDetailWebviewGIFView * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.hiddenForCssAnimation = cssAnimating;
    }];
}

- (NSMutableDictionary *)gifViews {
    if (!_gifViews) {
        _gifViews = [[NSMutableDictionary alloc] init];
    }
    return _gifViews;
}

- (NSMutableDictionary *)gifModels {
    if (!_gifModels) {
        _gifModels = [[NSMutableDictionary alloc] init];
    }
    return _gifModels;
}

#pragma mark - TTDetailWebviewGIFModelDelegate

- (BOOL)gifModel:(TTDetailWebviewGIFModel *)gifModel isFrameInSight:(CGRect)frame; {
    if (CGRectEqualToRect(frame, CGRectZero)) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(gifManager:isFrameInSight:)]) {
        return [self.delegate gifManager:self isFrameInSight:frame];
    }
    return NO;
}

- (void)gifModel:(TTDetailWebviewGIFModel *)gifModel didUpdateInSight:(BOOL)inSight {
    if (!gifModel.isRealGIF) {
        return;
    }
    if (inSight) {
        NSString *cachePath = gifModel.cachePath;
        TTDetailWebviewGIFView *gifView = [[TTDetailWebviewGIFView alloc] initWithIndex:gifModel.index frame:gifModel.frame cachePath:cachePath bytesPerFrame:gifModel.sizePerFrame];
        gifView.hiddenForCssAnimation = self.cssAnimating;
        [self.gifViews setObject:gifView forKey:@(gifModel.index)];
        if ([self.delegate respondsToSelector:@selector(gifManager:gifViewDidMoveToSight:)]) {
            [self.delegate gifManager:self gifViewDidMoveToSight:gifView];
        }
    }
    else {
        TTDetailWebviewGIFView *gifView = [self.gifViews objectForKey:@(gifModel.index)];
        [self.gifViews removeObjectForKey:@(gifModel.index)];
        if ([self.delegate respondsToSelector:@selector(gifManager:gifViewDidRemovedFromSight:)]) {
            [self.delegate gifManager:self gifViewDidRemovedFromSight:gifView];
        }
    }
}

- (void)gifModel:(TTDetailWebviewGIFModel *)gifModel didUpdateFrame:(CGRect)frame {
    if (!gifModel.isRealGIF) {
        return;
    }
    TTDetailWebviewGIFView *gifView = [self.gifViews objectForKey:@(gifModel.index)];
    if ([self.delegate respondsToSelector:@selector(gifManager:gifView:willUpdateFrame:)]) {
        [self.delegate gifManager:self gifView:gifView willUpdateFrame:frame];
    }
}

@end
