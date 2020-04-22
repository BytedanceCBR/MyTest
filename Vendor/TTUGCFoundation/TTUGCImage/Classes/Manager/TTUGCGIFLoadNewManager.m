//
//  TTUGCGIFLoadNewManager.m
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/10/18.
//

#import "TTUGCGIFLoadNewManager.h"
#import <TTWebImageManager.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <FRImageInfoModel.h>
#import "BDWebImageManager.h"
#import <pthread/pthread.h>
#import <TTUGCImageView.h>
#import "TTUGCImageHelper.h"

#import <TTBaseLib/NetworkUtilities.h>

@interface TTUGCGifDownloadModel ()

@property (nonatomic, strong) FRImageInfoModel *gifInfoModel;

@end

@implementation TTUGCGifDownloadModel

- (instancetype)initWithGifInfoModel:(FRImageInfoModel *)gifInfoModel {
    self = [super init];
    if (self) {
        _gifInfoModel = gifInfoModel;
    }
    return self;
}

@end

@interface TTUGCGIFLoadNewManager ()

@end

@implementation TTUGCGIFLoadNewManager {
    pthread_mutex_t _lock;
    NSMutableArray *_waitingQueue;
    NSMutableSet *_requestingSet;
}

//原则，所有涉及到预加载的，都判断network状态和流量模式。

+ (instancetype)sharedInstance {
    static TTUGCGIFLoadNewManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTUGCGIFLoadNewManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        _requestingSet =[[NSMutableSet alloc] init];
        _waitingQueue = [NSMutableArray arrayWithCapacity:10];
        
    }
    return self;
}

- (void)enterWorkingRangeForGifArray:(NSArray <FRImageInfoModel *> *)gifArray {
    if ([gifArray count] == 0 || !TTNetworkWifiConnected()) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    
    for (NSUInteger i = 0; i < [gifArray count]; i++) {
        FRImageInfoModel *model = gifArray[i];
        if ([model isKindOfClass:[FRImageInfoModel class]]) {
            //判重
            BOOL alreadyInQueue = NO;
            for (TTUGCGifDownloadModel *downloadModel in _requestingSet) {
                if ([model.uri isEqualToString:downloadModel.gifInfoModel.uri]) {
                    //正在请求的话，直接退出。
                    alreadyInQueue = YES;
                    break;
                }
            }
            if (alreadyInQueue) continue;
            for (TTUGCGifDownloadModel *downloadModel in _waitingQueue) {
                if ([model.uri isEqualToString:downloadModel.gifInfoModel.uri]) {
                    //队列中有的话，直接退出。
                    alreadyInQueue = YES;
                    break;
                }
            }
            if (alreadyInQueue) continue;
            
            TTUGCGifDownloadModel *downloadModel = [[TTUGCGifDownloadModel alloc] initWithGifInfoModel:model];
            if (0 == i) {
                downloadModel.priority = TTUGCGifPriorityNormal;
            } else {
                downloadModel.priority = TTUGCGifPriorityLow;
                
            }
            
            if (i >= 1) {
                //记录下一个不靠谱，得记录上一个
                FRImageInfoModel *preModel = gifArray[i-1];
                downloadModel.preGifKey = [self keyForImageInfoModel:preModel];
            }
            [_waitingQueue addObject:downloadModel];
            
        }
    }
    
    [self sortwaitingQueue];
    
    
    pthread_mutex_unlock(&_lock);
    [self startDownloadIfNeeded];
    
}

- (void)handleRequestCompleteForURL:(NSURL *)URL error:(NSError *)error {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&_lock);
        TTUGCGifDownloadModel *removeModel;
        for (TTUGCGifDownloadModel *model in _requestingSet) {
            if ([[self keyForImageInfoModel:model.gifInfoModel] isEqualToString:[[BDWebImageManager sharedManager] requestKeyWithURL:URL]]) {
                removeModel = model;
                break;
            }
        }
        if (removeModel) {
            [_requestingSet removeObject:removeModel];
        }
        FRImageInfoModel *gifModel = removeModel.gifInfoModel;
        if (!error) {
            //发出通知
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:gifModel forKey:kUGCImageViewGifInfoModelKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kUGCImageViewBDGifRequestOverNotification object:nil userInfo:userInfo];
                
            });
        }
        
        pthread_mutex_unlock(&_lock);
        [self startDownloadIfNeeded];
    });
    
}

- (void)startDownloadIfNeeded {
    pthread_mutex_lock(&_lock);
    
    while ([_requestingSet count] < 2 && [_waitingQueue count]) {
        TTUGCGifDownloadModel *model = [_waitingQueue firstObject];
        
        [_requestingSet addObject:model];
        [_waitingQueue removeObject:model];
        
        //prefetch命令不能用，因为没有回调.
        NSArray<TTImageURLInfoModel> *urlList = [[TTWebImageManager shareManger] sortedImageArray:model.gifInfoModel.url_list];
        NSURL *firstUrl = [((TTImageURLInfoModel *)[urlList firstObject]).url ttugc_feedImageURL];
        //先暂时不弄重试，后续再弄的时候很容易。
        WeakSelf;
        
        [[BDWebImageManager sharedManager] requestImage:firstUrl options:BDImageRequestDefaultOptions complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            //感觉可以无脑的出set.
            StrongSelf;
            [self handleRequestCompleteForURL:firstUrl error:error];
            
        }];
        
    }
    
    
    pthread_mutex_unlock(&_lock);
}


- (void)cellAppearForGifArray:(NSArray <FRImageInfoModel *> *)gifArray {
    if ([gifArray count] == 0 || !TTNetworkWifiConnected()) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    //对于gifarray中的，如果优先级不够，则升为normal优先级
    for (FRImageInfoModel *infoModel in gifArray) {
        BOOL findFlag = NO;
        for (TTUGCGifDownloadModel *downloadModel in _requestingSet) {
            if ([[self keyForImageInfoModel:downloadModel.gifInfoModel] isEqualToString:[self keyForImageInfoModel:infoModel]] ) {
                findFlag = YES;
                break;
            }
        }
        if (findFlag) continue;
        TTUGCGifDownloadModel *findDownloadModel = nil;
        for (TTUGCGifDownloadModel *downloadModel in _waitingQueue) {
            if ([[self keyForImageInfoModel:downloadModel.gifInfoModel] isEqualToString:[self keyForImageInfoModel:infoModel]] ) {
                findFlag = YES;
                findDownloadModel = downloadModel;
                break;
            }
        }
        if (findDownloadModel) {
            findDownloadModel.priority = findDownloadModel.priority < TTUGCGifPriorityNormal ? TTUGCGifPriorityNormal:findDownloadModel.priority;
        } else {
            TTUGCGifDownloadModel *downloadModel = [[TTUGCGifDownloadModel alloc] initWithGifInfoModel:infoModel];
            downloadModel.priority = TTUGCGifPriorityNormal;
            [_waitingQueue addObject:downloadModel];
        }
        
    }
    [self sortwaitingQueue];
    pthread_mutex_unlock(&_lock);
    [self startDownloadIfNeeded];
    
}

- (void)cellDisappearForGifArray:(NSArray <FRImageInfoModel *> *)gifArray {
    if ([gifArray count] == 0) {
        return;
    }
    pthread_mutex_lock(&_lock);
    for (FRImageInfoModel *infoModel in gifArray) {
        BOOL findFlag = NO;
        for (TTUGCGifDownloadModel *downloadModel in _requestingSet) {
            if ([[self keyForImageInfoModel:downloadModel.gifInfoModel] isEqualToString:[self keyForImageInfoModel:infoModel]] ) {
                findFlag = YES;
                break;
            }
        }
        if (findFlag) continue;
        
        
        NSInteger removeIndex = -1;
        for (NSUInteger i = 0; i< _waitingQueue.count; i++) {
            if ([[self keyForImageInfoModel:((TTUGCGifDownloadModel *)_waitingQueue[i]).gifInfoModel] isEqualToString:[self keyForImageInfoModel:infoModel]] ) {
                removeIndex = i;
                break;
            }
        }
        if (removeIndex >= 0) {
            [_waitingQueue removeObjectAtIndex:removeIndex];
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)imediatelyStartDownloadForGifModel:(FRImageInfoModel *)gifModel {
    if (!gifModel) {
        return;
    }
    pthread_mutex_lock(&_lock);
    //requestingset 里面有的话，不处理.
    //排队中有的话，直接出队，并且加入requesting set，并且请求。
    //没有的话，直接差set，并且请求。
    BOOL findFlag = NO;
    for (TTUGCGifDownloadModel *downloadModel in _requestingSet) {
        if ([[self keyForImageInfoModel:downloadModel.gifInfoModel] isEqualToString:[self keyForImageInfoModel:gifModel]] ) {
            findFlag = YES;
            break;
        }
    }
    if (!findFlag) {
        //requesting中没找到，才需要处理
        NSInteger removeIndex = -1;
        TTUGCGifDownloadModel *findModel = nil;
        for (NSUInteger i = 0; i< _waitingQueue.count; i++) {
            if ([[self keyForImageInfoModel:((TTUGCGifDownloadModel *)_waitingQueue[i]).gifInfoModel] isEqualToString:[self keyForImageInfoModel:gifModel]] ) {
                findModel = _waitingQueue[i];
                removeIndex = i;
                break;
            }
        }
        if (removeIndex >= 0 && findModel) {
            //找到的情况
            [_waitingQueue removeObjectAtIndex:removeIndex];
            
        } else {
            //没找到的话生成呀一个model用于计算
            findModel = [[TTUGCGifDownloadModel alloc] initWithGifInfoModel:gifModel];
            findModel.priority = TTUGCGifPriorityHigh;
        }
        
        [_requestingSet addObject:findModel];
        
        //prefetch命令不能用，因为没有回调.
        
        NSArray<TTImageURLInfoModel> *urlList = [[TTWebImageManager shareManger] sortedImageArray:findModel.gifInfoModel.url_list];
        NSURL *firstUrl = [((TTImageURLInfoModel *)[urlList firstObject]).url ttugc_feedImageURL];
        //先暂时不弄重试，后续再弄的时候很容易。
        WeakSelf;
        
        [[BDWebImageManager sharedManager] requestImage:firstUrl options:BDImageRequestDefaultOptions complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            //感觉可以无脑的出set.
            StrongSelf;
            [self handleRequestCompleteForURL:firstUrl error:error];
            
        }];
        
        
    }
    
    
    pthread_mutex_unlock(&_lock);
}

- (void)configPriority:(TTUGCGifPriority)priority forGifModel:(FRImageInfoModel *)gifModel {
    if (!gifModel) {
        return;
    }
    pthread_mutex_lock(&_lock);
    
    for (TTUGCGifDownloadModel *downloadModel in _waitingQueue) {
        if ([[self keyForImageInfoModel:downloadModel.gifInfoModel] isEqualToString:[self keyForImageInfoModel:gifModel]]) {
            downloadModel.priority = priority;
            break;
        }
    }
    [self sortwaitingQueue];
    pthread_mutex_unlock(&_lock);
}

//把一个gif的后面的那个升为超高优先级，并且，直接调整顺序放到队列最前端。
- (void)enhanceNextGifHighPriorityForGifModel:(FRImageInfoModel *)gifModel {
    if (!gifModel) return;
    pthread_mutex_lock(&_lock);
    TTUGCGifDownloadModel *findModel = nil;
    for (TTUGCGifDownloadModel *downloadModel in _waitingQueue) {
        if ([downloadModel.preGifKey isEqualToString:[self keyForImageInfoModel:gifModel]]) {
            findModel = downloadModel;
            break;
        }
    }
    if (findModel) {
        [_waitingQueue removeObject:findModel];
        findModel.priority = TTUGCGifPriorityHigh;
        [_waitingQueue insertObject:findModel atIndex:0];
    }
    pthread_mutex_unlock(&_lock);
    [self startDownloadIfNeeded];
}

- (void)sortwaitingQueue {
    [_waitingQueue sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(TTUGCGifDownloadModel* _Nonnull obj1, TTUGCGifDownloadModel*  _Nonnull obj2) {
        if (obj1.priority > obj2.priority) return NSOrderedAscending;
        if (obj1.priority < obj2.priority) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}


- (NSString *)keyForImageInfoModel:(FRImageInfoModel *)imageModel {
    NSURL *URL = [imageModel.url ttugc_feedImageURL];
    return [[BDWebImageManager sharedManager] requestKeyWithURL:URL];
}

@end

