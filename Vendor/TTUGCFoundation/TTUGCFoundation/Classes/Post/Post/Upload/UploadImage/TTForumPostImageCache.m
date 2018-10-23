//
//  TTForumPostImageCache.m
//  Article
//
//  Created by SongChai on 05/06/2017.
//
//

#import "TTForumPostImageCache.h"
#import "TTAccountManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TTImagePickerManager.h"
#import "NSStringAdditions.h"
#import <YYImageCoder.h>
#import "TTUGCImageCompressHelper.h"
#import "TTImagePickerDefineHead.h"
#import "TTImagePickerManager.h"
#import "TTKitchenHeader.h"

@interface TTForumPostImageCacheTask()
@property(nonatomic, strong) NSMutableArray* completeBlockArray;
@property(nonatomic, strong) TTImagePickerResult* photoResult;

- (NSString*) realFilePath;
@end

@implementation TTForumPostImageCacheTask

- (NSMutableArray *)completeBlockArray {
    if (_completeBlockArray == nil) {
        _completeBlockArray = [NSMutableArray array];
    }
    return _completeBlockArray;
}

- (NSUInteger)hash {
    return [_key hash];
}

- (BOOL)isEqual:(TTForumPostImageCacheTask*)object {
    if (self == object) {
        return YES;
    }
    if ([object isKindOfClass:[TTForumPostImageCacheTask class]] && [object.key isEqualToString:self.key]) {
        return YES;
    }
    return NO;
}

- (NSString *)realFilePath {
    if (isEmptyString(self.key)) {
        return @"";
    }
    return [NSHomeDirectory() stringByAppendingString:self.key];
}

- (NSString *)description {
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"key="];
    [str appendString:(self.key? :@"")];
    [str appendString:@",org="];
    [str appendString:(_originalSource? NSStringFromClass([_originalSource class]): @"")];
    if (_assetModel) {
        [str appendFormat:@",type=%ld,assetId=%@", _assetModel.type, _assetModel.assetID];
    }
    if (_photoResult) {
        [str appendFormat:@",hasResut=true"];
    }
    
    return str;
}
- (IcloudSyncStatus)status
{
    if (!self.assetModel) {
        return IcloudSyncNone;
    }
    //icloud已有图
    if (![[TTImagePickerManager manager] isNeedIcloudSync:self.assetModel.asset]) {
        return IcloudSyncNone;
    }
    if (!self.photoResult) {
        return IcloudSyncExecuting;
    }
    if (!self.photoResult.data && !self.photoResult.image) {
        return IcloudSyncFailed;
    }
    return IcloudSyncComplete;
}

- (void)setIcloudCompletes:(NSArray<PostIcloudCompletion> *)icloudCompletes
{
    _icloudCompletes = icloudCompletes;
    if (self.status == IcloudSyncComplete) {
        for (PostIcloudCompletion block in icloudCompletes) {
            block(YES);
        }
    }
    if (self.status == IcloudSyncFailed) {
        for (PostIcloudCompletion block in icloudCompletes) {
            block(NO);
        }
    }
}

@end

@interface TTForumPostImageCache ()
<
TTAccountMulticastProtocol
> {
    NSFileManager* _fileManager;
    NSString* _diskCachePath;
}
@property(nonatomic, strong) TTForumPostImageCacheTask * executingTask;
@property(nonatomic, strong) NSMutableArray* waitingTasks;
@property(nonatomic, strong) dispatch_queue_t compressQueue;

@property (assign, nonatomic) NSInteger maxCacheAge;
@property (assign, nonatomic) NSUInteger maxCacheSize;
@end

@implementation TTForumPostImageCache

+ (TTForumPostImageCache*)sharedInstance{
    static TTForumPostImageCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTForumPostImageCache alloc] init];
    });
    return instance;
    
}

- (NSMutableArray *)waitingTasks {
    if (_waitingTasks == nil) {
        _waitingTasks = [NSMutableArray array];
    }
    return _waitingTasks;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _compressQueue = dispatch_queue_create("com.bytedance.ios.TTForumPostImageCache", DISPATCH_QUEUE_SERIAL);
        
        //初始化，看大小干掉本地缓存数据，粗暴的晴空所有数据
        [TTAccount addMulticastDelegate:self];
        
        _fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"forumPostCache"];
        
        BOOL dir;
        if (![_fileManager fileExistsAtPath:_diskCachePath isDirectory:&dir]) {
            [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        } else if (dir == NO) {
            [_fileManager removeItemAtPath:_diskCachePath error:nil];
            [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        self.maxCacheAge = 60 * 60 * 24 * 7; // 1 week
        self.maxCacheSize = 30 * 1024 * 1024; //30m 缓存
        
        [self cleanDisk];
    }
    return self;
}

- (void)_releaseWaiting {
    if (_executingTask == nil && _waitingTasks.count) {
        _executingTask = _waitingTasks.firstObject;
        [_waitingTasks removeObject:_executingTask];
        [self _compress];
    }
}

//走到这一步，资源肯定在内存了，或者是UIImage，或者是data
- (void)_compress {
    dispatch_async(_compressQueue, ^{
        //此处做图片的压缩
        
        if (_executingTask) {
            NSData* imageData = nil;
            if ([_executingTask.originalSource isKindOfClass:[PHAsset class]] || [_executingTask.originalSource isKindOfClass:[ALAsset class]]) {
                if (_executingTask.photoResult) {
                    if (_executingTask.photoResult.assetModel.type == TTAssetModelMediaTypePhotoGif) { //gif图压缩
                        imageData = [TTUGCImageCompressHelper compressGif:_executingTask.photoResult.data];
                        if (imageData == nil) {
                            imageData = [TTUGCImageCompressHelper compressImage:_executingTask.photoResult.image];
                        }
                    } else {
                        imageData = [TTUGCImageCompressHelper compressImage:_executingTask.photoResult.image];
                    }
                }
            } else if ([_executingTask.originalSource isKindOfClass:[UIImage class]]) {
                imageData = [TTUGCImageCompressHelper compressImage:_executingTask.originalSource];
            }
            
            BOOL success = NO;
            if (imageData != nil) {
                success = [imageData writeToFile:_executingTask.realFilePath atomically:YES];
            }
            NSMutableArray* completeBlockArray = _executingTask.completeBlockArray;
            for (TTForumPostImageCacheComplete block in completeBlockArray) {
                block(success? _executingTask.realFilePath: nil);
            }
        }
        TTMainSafeExecuteBlock( ^{
            _executingTask = nil;
            [self _releaseWaiting];
        });
    });
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    // 清空所有正在运行和等待的task
   
}

- (void)queryFilePathWithSource:(TTForumPostImageCacheTask*)task complete:(void (^)(NSString *))block {
    TTMainSafeExecuteBlock( ^{
        if (task) {
            if ([_executingTask isEqual:task]) {
                if (block) {
                    [_executingTask.completeBlockArray addObject:block];
                }
                return;
            }
            
            if ([_fileManager fileExistsAtPath:task.realFilePath]) {
                if (block) {
                    block(task.realFilePath);
                }
                return;
            }
            
            if ([task.originalSource isKindOfClass:[NSString class]]) { //文件不存在，还是string，则肯定没数据了
                if (block) {
                    block(nil);
                }
                return;
            }
            
            NSUInteger index = [self.waitingTasks indexOfObject:task];
            if (index == NSNotFound) {
                if (block) {
                    [task.completeBlockArray addObject:block];
                }
                
                if (task.assetModel) {
                    task.photoResult = nil;
                    [self getPhotoWithAssetModel:task.assetModel completion:^(TTImagePickerResult *pickerResult) {
                        task.photoResult = pickerResult;
                     
                        if ([self isPushIntoWatingTask:task]) {
                            [self.waitingTasks addObject:task];
                            [self _releaseWaiting];
                        }else{
                            if (block) {
                                block(nil);
                            }
                        }
                     
                    } task:task];
                    

                } else {
                    if ([task.originalSource isKindOfClass:[UIImage class]]) {
                        [self.waitingTasks addObject:task];
                        [self _releaseWaiting];
                    } else {
                        task.photoResult = nil;

                        TTAssetModel *model = [[TTImagePickerManager manager] assetModelWithAsset:task.originalSource allowPickingVideo:NO allowPickingImage:YES];
                        task.assetModel = model;
                        
                        [self getPhotoWithAssetModel:model completion:^(TTImagePickerResult *pickerResult) {
                            task.photoResult = pickerResult;
                            if ([self isPushIntoWatingTask:task]) {
                                [self.waitingTasks addObject:task];
                                [self _releaseWaiting];
                            }else{
                                if (block) {
                                    block(nil);
                                }
                            }
                            
                        } task:task];

                    }
                }
            } else {
                if (block) {
                    TTForumPostImageCacheTask* waitTask = [self.waitingTasks objectAtIndex:index];
                    [waitTask.completeBlockArray addObject:block];
                }
            }
        } else {
            if (block) {
                block(nil);
            }
        }
        
    });
}

- (BOOL)fileExist:(TTForumPostImageCacheTask *)task {
    return [_fileManager fileExistsAtPath:task.realFilePath];
}

- (void)getPhotoWithAssetModel:(TTAssetModel *)model
                                completion:(void (^)(TTImagePickerResult *pickerResult))completion
                                      task:(TTForumPostImageCacheTask *)task
{
    if (model.type == TTAssetModelMediaTypePhotoGif) {
        [[TTImagePickerManager manager] getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, BOOL isDegraded) {
            
            if (!isDegraded ) {
                
                for (PostIcloudCompletion block in task.icloudCompletes) {
                    if (data) {
                        block(YES);
                    }else{
                        block(NO);
                    }
                }
              
                TTImagePickerResult* result = [[TTImagePickerResult alloc] init];
                result.image = [UIImage imageWithData:data];
                result.data = data;
                result.assetModel = model;
                completion(result);
             
            }

        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            
            for (PostIcloudProgressHandler block in task.icloudProgresses) {
                block(progress, error, stop, info);
            }
          
        }];
        
    }else{
        CGFloat limitWidth = TTImagePickerImageWidthDefault * 3;
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)model.asset;
            limitWidth = [TTUGCImageCompressHelper getLimitSizeWithImageSize:CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight)].width;
        }
        [[TTImagePickerManager manager] getPhotoWithAssetNonScale:model.asset photoWidth:limitWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (!isDegraded) {
                for (PostIcloudCompletion block in task.icloudCompletes) {
                    if (photo) {
                        block(YES);
                    }else{
                        block(NO);
                    }
                }
                TTImagePickerResult* result = [[TTImagePickerResult alloc] init];
                result.image = photo;
                result.assetModel = model;
                completion(result);
              
            }
          
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            for (PostIcloudProgressHandler block in task.icloudProgresses) {
                block(progress, error, stop, info);
            }
        } isIcloudEabled:YES isSingleTask:NO isCached:NO];
    }
}

- (BOOL)isPushIntoWatingTask:(TTForumPostImageCacheTask *)task
{
    if (task.assetModel.type == TTAssetModelMediaTypePhotoGif && task.photoResult.data == nil) {
        return NO;
    }
    if (task.assetModel.type != TTAssetModelMediaTypePhotoGif && task.photoResult.image == nil) {
        return NO;
    }
    return YES;
}

- (NSArray<TTForumPostImageCacheTask*>*)saveCacheWithAssets:(NSArray<TTAssetModel *>*)models {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:models.count];
    for (TTAssetModel* model in models) {
        TTForumPostImageCacheTask* task = [self _taskFromOriginalSource:model];
        if (task) {
            [self queryFilePathWithSource:task complete:nil];
            [result addObject:task];
        }
    }
    return result;
}

- (TTForumPostImageCacheTask*)saveCacheSource:(id)originalSource {
    __block TTForumPostImageCacheTask* task = [self _taskFromOriginalSource:originalSource];
    
    TTMainSafeSycnExecuteBlock(^{
        if ([_executingTask isEqual:task]) {
            task = _executingTask;
            return;
        }
        //?
        NSUInteger index = [self.waitingTasks indexOfObject:task];
        if (index != NSNotFound) {
            task = [self.waitingTasks objectAtIndex:index];
        }
    });
    
    [self queryFilePathWithSource:task complete:nil];
    return task;
}

- (void)removeCacheSource:(id)originalSource {
    [self removeTask:[self _taskFromOriginalSource:originalSource]];
}

- (void)removeTask:(TTForumPostImageCacheTask *)task {
    if (task) {
        TTMainSafeExecuteBlock(^{
            if ([self.waitingTasks containsObject:task]) {
                [self.waitingTasks removeObject:task];
            }
            if ([_executingTask isEqual:task]) {
                [_executingTask.completeBlockArray removeAllObjects];
            }
        });
    }
}

- (void)deleteCacheSource:(id)originalSource {
    [self deleteTask:[self _taskFromOriginalSource:originalSource]];
}

- (void)deleteTask:(TTForumPostImageCacheTask *)task {
    if (task) {
        TTMainSafeExecuteBlock(^{
            if ([self.waitingTasks containsObject:task]) {
                [self.waitingTasks removeObject:task];
            }
            if ([_executingTask isEqual:task]) {
                [_executingTask.completeBlockArray removeAllObjects];
            }
            if ([_fileManager fileExistsAtPath:task.realFilePath]) {
                [_fileManager removeItemAtPath:task.realFilePath error:nil];
            }
        });
    }
}

- (TTForumPostImageCacheTask*) _taskFromOriginalSource:(id)originalSource {
    NSString* path = nil;
    if ([originalSource isKindOfClass:[PHAsset class]] || [originalSource isKindOfClass:[ALAsset class]]) {
        TTAssetModel *model = [[TTImagePickerManager manager] assetModelWithAsset:originalSource allowPickingVideo:NO allowPickingImage:YES];
        originalSource = model;
        
        NSString *name = nil;
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = model.asset;
            name = [[NSString stringWithFormat:@"%@%ld", model.assetID, phAsset.modificationDate.timeIntervalSince1970] MD5HashString];
        } else {
            name = [model.assetID MD5HashString];
        }
        path = [self _filePathWithName:name];
    } else if ([originalSource isKindOfClass:[TTAssetModel class]]) {
        TTAssetModel *model = (TTAssetModel *)originalSource;
        NSString *name = nil;
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = model.asset;
            name = [[NSString stringWithFormat:@"%@%ld", model.assetID, phAsset.modificationDate.timeIntervalSince1970] MD5HashString];
        } else {
            name = [model.assetID MD5HashString];
        }
        path = [self _filePathWithName:name];
    } else if ([originalSource isKindOfClass:[UIImage class]]) {
        NSString* identifier = [NSString stringWithFormat:@"%p", originalSource];
        path = [self _filePathWithName:[identifier MD5HashString]];
    } else if ([originalSource isKindOfClass:[NSString class]]) { //已经是一个地址了
        path = originalSource;
    }
    if (!isEmptyString(path)) {
        TTForumPostImageCacheTask* task = [[TTForumPostImageCacheTask alloc]init];
        task.key = path;
        if ([originalSource isKindOfClass:[TTAssetModel class]]) {
            task.assetModel = originalSource;
            task.originalSource = ((TTAssetModel*)originalSource).asset;
        } else {
            task.originalSource = originalSource;
        }
        return task;
    }
    return nil;
}

/**
 根据名字返回地址，位置在libraryCache目录，不需要管理磁盘问题，下次启动会被清理掉的
 
 @param name 文件名
 @return 路径
 */
- (NSString*) _filePathWithName :(NSString*) name {
    if (isEmptyString(name)) {
        return nil;
    }
    
    long compressCode = [KitchenMgr getInt:kKCUGCImageCompressLongLongPX] + [KitchenMgr getInt:kKCUGCImageCompressLongShortPX] + [KitchenMgr getInt:kKCUGCImageCompressNormalPX] + [KitchenMgr getInt:kKCUGCImageCompressGifMaxFrameCount];
    
    name = [NSString stringWithFormat:@"%@(%ld)", name, compressCode];
    return [@"/Library/Caches/forumPostCache" stringByAppendingPathComponent:name];
}

- (void)cleanDisk {
    dispatch_async(self.compressQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:_diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        
        for (NSURL *fileURL in urlsToDelete) {
            [_fileManager removeItemAtURL:fileURL error:nil];
        }
        
        if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
            const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            for (NSURL *fileURL in sortedFiles) {
                if ([_fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
    });
}
@end
