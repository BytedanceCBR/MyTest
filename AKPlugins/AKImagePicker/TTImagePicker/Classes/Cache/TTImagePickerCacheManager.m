//
//  TTImagePickerCacheManager.m
//  Article
//
//  Created by tyh on 2017/4/23.
//
//

#import "TTImagePickerCacheManager.h"
#import "TTImagePickerCacheImage.h"


@interface TTImagePickerCacheManager()

@property (nonatomic, strong) NSMutableDictionary <NSString* , TTImagePickerCacheImage*> *cachedImages;
@property (nonatomic, assign) UInt64 currentMemoryUsage;
@property (nonatomic, strong) dispatch_queue_t synchronizationQueue;

@end


@implementation TTImagePickerCacheManager

#pragma mark - Life Cycle

- (instancetype)init {
    
    /// 默认为内存100M，后者为缓存溢出后保留的内存 50M
    /// 实际UIImage只占用很小的内存，而这个内存大小为全部add到View上显示，或者转成NSData所需内存，所以，不要担心内存问题。
    return [self initWithMemoryCapacity:100 * 1024 * 1024 preferredMemoryCapacity:50 * 1024 * 1024];
}

- (instancetype)initWithMemoryCapacity:(UInt64)memoryCapacity preferredMemoryCapacity:(UInt64)preferredMemoryCapacity {
    if (self = [super init]) {
        //内存大小
        self.memoryCapacity = memoryCapacity;
        self.preferredMemoryUsageAfterPurge = preferredMemoryCapacity;
        //cache的字典
        self.cachedImages = [[NSMutableDictionary alloc] init];
        
        //并行的queue
        self.synchronizationQueue = dispatch_queue_create("TTImagePickerCacheManagerCacheQueue", DISPATCH_QUEUE_CONCURRENT);
        
        //添加通知，收到内存警告的通知
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(removeAllImages)
         name:UIApplicationDidReceiveMemoryWarningNotification
         object:nil];
        
    }
    return self;
}



#pragma mark - Set Cache

- (void)setImage:(UIImage *)image withAssetID:(NSString *)assetID
{
    if (!assetID) {
        return;
    }
    
    //用dispatch_barrier_async，来同步这个并行队列
    dispatch_barrier_async(self.synchronizationQueue, ^{

        TTImagePickerCacheImage *cacheImage = [[TTImagePickerCacheImage alloc] initWithImage:image assetID:assetID];
        TTImagePickerCacheImage *previousCachedImage = self.cachedImages[assetID];
        //如果有被缓存过，会更新缓存
        if (previousCachedImage != nil) {
            self.currentMemoryUsage -= previousCachedImage.totalBytes;
        }
        //把新cache的image加上去
        self.cachedImages[assetID] = cacheImage;
        self.currentMemoryUsage += cacheImage.totalBytes;
        
    });
    
    //做缓存溢出的清除，清除的是早期的缓存
    dispatch_barrier_async(self.synchronizationQueue, ^{

        if (self.currentMemoryUsage > self.memoryCapacity) {

            UInt64 bytesToPurge = self.currentMemoryUsage - self.preferredMemoryUsageAfterPurge;
            //拿到所有缓存的数据
            NSMutableArray <TTImagePickerCacheImage*> *sortedImages = [NSMutableArray arrayWithArray:self.cachedImages.allValues];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastCacheDate" ascending:YES];
            
            [sortedImages sortUsingDescriptors:@[sortDescriptor]];
            UInt64 bytesPurged = 0;
            //移除早期的cache
            for (TTImagePickerCacheImage *cachedImage in sortedImages) {
                [self.cachedImages removeObjectForKey:cachedImage.assetID];
                bytesPurged += cachedImage.totalBytes;
                if (bytesPurged >= bytesToPurge) {
                    break ;
                }
            }
            self.currentMemoryUsage -= bytesPurged;
        }
    });

}

#pragma mark - Get Cache

- (UIImage *)getImageWithAssetID:(NSString *)assetID
{
    if (!assetID) {
        return nil;
    }
    __block UIImage *image = nil;

    dispatch_sync(self.synchronizationQueue, ^{
        TTImagePickerCacheImage *cachedImage = self.cachedImages[assetID];
        image = [cachedImage refreshCacheAndGetImage];
    });

    
    return image;
}

#pragma mark - Remove Cache

- (BOOL)removeImageWithAssetID:(NSString *)assetID
{
    if (!assetID) {
        return NO;
    }
    __block BOOL removed = NO;
    
    dispatch_barrier_sync(self.synchronizationQueue, ^{
        TTImagePickerCacheImage *cachedImage = self.cachedImages[assetID];
        if (cachedImage != nil) {
            [self.cachedImages removeObjectForKey:assetID];
            self.currentMemoryUsage -= cachedImage.totalBytes;
            removed = YES;
        }
    });
    return removed;
}

//移除所有图片
- (BOOL)removeAllImages {
    __block BOOL removed = NO;
    dispatch_barrier_sync(self.synchronizationQueue, ^{
        if (self.cachedImages.count > 0) {
            [self.cachedImages removeAllObjects];
            self.currentMemoryUsage = 0;
            removed = YES;
        }
    });
    return removed;
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
