//
//  TTUGCImageCompressManager.m
//  Article
//
//  Created by SongChai on 05/06/2017.
//
//

#import "TTUGCImageCompressManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <TTImagePickerManager.h>
#import <TTBaseLib/NSStringAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <YYImageCoder.h>
#import "TTUGCImageCompressHelper.h"
#import "TTImagePickerDefineHead.h"
#import "TTImagePickerManager.h"
#import <TTKitchen/TTKitchen.h>
#import "NSData+ImageContentType.h"
#import <TTKitchenExtension/TTKitchenExtension.h>

@interface TTUGCImageCompressTask()

@property (nonatomic, strong) NSMutableArray *completeBlockArray;
@property (nonatomic, strong) TTImagePickerResult *photoResult;

@property (nonatomic, strong) NSMutableArray<iCloudSyncCompletion> *iCloudCompletes;
@property (nonatomic, strong) NSMutableArray<iCloudSyncProgressHandler> *iCloudProgresses;

- (NSString *)realFilePath;

@end

@implementation TTUGCImageCompressTask

- (NSMutableArray<iCloudSyncCompletion> *)iCloudCompletes {
    if (_iCloudCompletes == nil) {
        _iCloudCompletes = [NSMutableArray array];
    }
    return _iCloudCompletes;
}

- (NSMutableArray<iCloudSyncProgressHandler> *)iCloudProgresses {
    if (_iCloudProgresses == nil) {
        _iCloudProgresses = [NSMutableArray array];
    }
    return _iCloudProgresses;
}

- (NSMutableArray *)completeBlockArray {
    if (_completeBlockArray == nil) {
        _completeBlockArray = [NSMutableArray array];
    }
    return _completeBlockArray;
}

- (NSUInteger)hash {
    return [_key hash];
}

- (BOOL)isEqual:(TTUGCImageCompressTask*)object {
    if (self == object) {
        return YES;
    }
    if ([object isKindOfClass:[TTUGCImageCompressTask class]] && [object.key isEqualToString:self.key]) {
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
- (FHiCloudSyncStatus)status
{
    if (!self.assetModel) {
        return FHiCloudSyncStatusNone;
    }
    //icloud已有图
    if (![[TTImagePickerManager manager] isNeedIcloudSync:self.assetModel.asset]) {
        return FHiCloudSyncStatusNone;
    }
    if (!self.photoResult) {
        return FHiCloudSyncStatusExecuting;
    }
    if (!self.photoResult.data && !self.photoResult.image) {
        return FHiCloudSyncStatusFailed;
    }
    return FHiCloudSyncStatusSuccess;
}

- (BOOL)isCompressed {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.realFilePath];
}

- (void)iCloud_addCompleteBlock:(iCloudSyncCompletion)block {
    [self.iCloudCompletes addObject:block];
    
    if (self.status == FHiCloudSyncStatusSuccess) {
        block(YES);
    }
    if (self.status == FHiCloudSyncStatusFailed) {
        block(NO);
    }
}

- (void)iCloud_addProgressBlock:(iCloudSyncProgressHandler)block {
    [self.iCloudProgresses addObject:block];
}

@end


@interface TTUGCImageCompressManager ()

@property (nonatomic, strong) TTUGCImageCompressTask *executingTask;
@property (nonatomic, strong) NSMutableArray *waitingTasks;

@property (nonatomic, strong) dispatch_queue_t compressQueue;

@property (nonatomic, assign) NSInteger maxCacheAge;
@property (nonatomic, assign) NSUInteger maxCacheSize;

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *diskCachePath;
@end

@implementation TTUGCImageCompressManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (TTUGCImageCompressManager *)sharedInstance{
    static TTUGCImageCompressManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTUGCImageCompressManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _compressQueue = dispatch_queue_create("com.bytedance.ios.TTUGCImageCompressManager", DISPATCH_QUEUE_SERIAL);
        
        //初始化，看大小干掉本地缓存数据，粗暴的晴空所有数据
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







- (void)p_releaseWaiting {
    if (_executingTask == nil && _waitingTasks.count) {
        _executingTask = _waitingTasks.firstObject;
        [_waitingTasks removeObject:_executingTask];
        [self p_compress];
    }
}

//走到这一步，资源肯定在内存了，或者是UIImage，或者是data
- (void)p_compress {
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
            for (TTUGCImageCompressCompleteBlock block in completeBlockArray) {
                block(success? _executingTask.realFilePath: nil);
            }
        }
        FHMainSafeExecuteBlock( ^{
            _executingTask = nil;
            [self p_releaseWaiting];
        });
    });
}

- (void)queryFilePathWithTask:(TTUGCImageCompressTask*)task complete:(void (^)(NSString *))block {
    WeakSelf;
    FHMainSafeExecuteBlock( ^{
        StrongSelf;
        if (task) {
            NSString *preCompressFilePath = [NSHomeDirectory() stringByAppendingFormat:@"%@_pre", task.key];
            if ([self.executingTask isEqual:task]) {
                if (block) {
                    [self.executingTask.completeBlockArray addObject:block];
                }
                return;
            }
            
            if ([self.fileManager fileExistsAtPath:task.realFilePath]) {
                if ([self.fileManager fileExistsAtPath:preCompressFilePath]) {
                    task.preCompressFilePath = preCompressFilePath;
                } else {
                    task.preCompressFilePath = task.realFilePath;
                }
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

                    UIImage *imageToPreSave = task.assetModel.thumbImage;
                    if (!imageToPreSave) {
                        imageToPreSave = task.assetModel.cacheImage;
                    }
                    if (imageToPreSave) {
                        [UIImageJPEGRepresentation(imageToPreSave, 0.9) writeToFile:preCompressFilePath atomically:NO];
                        task.preCompressFilePath = preCompressFilePath;
                    }

                    task.photoResult = nil;
                    [self getPhotoWithAssetModel:task.assetModel completion:^(TTImagePickerResult *pickerResult) {
                        task.photoResult = pickerResult;

                        if ([self isPushIntoWatingTask:task]) {
                            [self.waitingTasks addObject:task];
                            if (pickerResult.assetModel.type == TTAssetModelMediaTypePhotoGif) {
                                [pickerResult.data writeToFile:preCompressFilePath atomically:NO];
                            } else {
                                [UIImageJPEGRepresentation(pickerResult.image, 0.9) writeToFile:preCompressFilePath atomically:NO];
                            }
                            task.preCompressFilePath = preCompressFilePath;

                            [self p_releaseWaiting];
                        } else {
                            if (block) {
                                block(nil);
                            }
                        }
                    } task:task];
                } else {
                    if ([task.originalSource isKindOfClass:[UIImage class]]) {
                        [self.waitingTasks addObject:task];
                        [UIImageJPEGRepresentation(task.originalSource, 0.9) writeToFile:preCompressFilePath atomically:NO];
                        task.preCompressFilePath = preCompressFilePath;
                        [self p_releaseWaiting];
                    } else {

                        UIImage *imageToPreSave = task.assetModel.thumbImage;
                        if (!imageToPreSave) {
                            imageToPreSave = task.assetModel.cacheImage;
                        }
                        if (imageToPreSave) {
                            [UIImageJPEGRepresentation(imageToPreSave, 0.9) writeToFile:preCompressFilePath atomically:NO];
                            task.preCompressFilePath = preCompressFilePath;
                        }

                        task.photoResult = nil;
                        TTAssetModel *model = [[TTImagePickerManager manager] assetModelWithAsset:task.originalSource
                                                                                allowPickingVideo:NO
                                                                                allowPickingImage:YES];
                        task.assetModel = model;
                        
                        [self getPhotoWithAssetModel:model completion:^(TTImagePickerResult *pickerResult) {
                            task.photoResult = pickerResult;
                            if ([self isPushIntoWatingTask:task]) {
                                [self.waitingTasks addObject:task];
                                if (pickerResult.assetModel.type == TTAssetModelMediaTypePhotoGif) {
                                    [pickerResult.data writeToFile:preCompressFilePath atomically:NO];
                                } else {
                                    [UIImageJPEGRepresentation(pickerResult.image, 0.9) writeToFile:preCompressFilePath atomically:NO];
                                }
                                task.preCompressFilePath = preCompressFilePath;
                                [self p_releaseWaiting];
                            } else {
                                if (block) {
                                    block(nil);
                                }
                            }
                        } task:task];
                    }
                }
            } else {
                if (block) {
                    TTUGCImageCompressTask* waitTask = [self.waitingTasks objectAtIndex:index];
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

- (void)getPhotoWithAssetModel:(TTAssetModel *)model
                    completion:(void (^)(TTImagePickerResult *pickerResult))completion
                          task:(TTUGCImageCompressTask *)task
{
    if (model.type == TTAssetModelMediaTypePhotoGif) {
        [[TTImagePickerManager manager] getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, BOOL isDegraded) {
            
            if (!isDegraded ) {
                
                for (iCloudSyncCompletion block in task.iCloudCompletes) {
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
            
            for (iCloudSyncProgressHandler block in task.iCloudProgresses) {
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
                for (iCloudSyncCompletion block in task.iCloudCompletes) {
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
            for (iCloudSyncProgressHandler block in task.iCloudProgresses) {
                block(progress, error, stop, info);
            }
        } isIcloudEabled:YES isSingleTask:NO isCached:NO];
    }
}

- (BOOL)isPushIntoWatingTask:(TTUGCImageCompressTask *)task
{
    if (task.assetModel.type == TTAssetModelMediaTypePhotoGif && task.photoResult.data == nil) {
        return NO;
    }
    if (task.assetModel.type != TTAssetModelMediaTypePhotoGif && task.photoResult.image == nil) {
        return NO;
    }
    return YES;
}

- (TTUGCImageCompressTask *)generateTaskWithImage:(UIImage *)image {
    NSString* identifier = [NSString stringWithFormat:@"%p", image];
    NSString *path = [self _filePathWithName:[identifier MD5HashString]];
    TTUGCImageCompressTask* task = [[TTUGCImageCompressTask alloc]init];
    task.key = path;
    task.originalSource = image;
    
    [self p_prepareTask:&task];
    
    return task;
}

- (TTUGCImageCompressTask *)generateTaskWithAssetModel:(TTAssetModel *)assetModel {
    NSString *name = nil;
    if ([assetModel.asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = assetModel.asset;
        name = [[NSString stringWithFormat:@"%@%f", assetModel.assetID, phAsset.modificationDate.timeIntervalSince1970] MD5HashString];
    } else {
        name = [assetModel.assetID MD5HashString];
    }
    NSString *path = [self _filePathWithName:name];
    
    TTUGCImageCompressTask* task = [[TTUGCImageCompressTask alloc]init];
    task.key = path;
    task.originalSource = assetModel.asset;
    task.assetModel = assetModel;
    
    [self p_prepareTask:&task];

    return task;
}

- (TTUGCImageCompressTask *)generateTaskWithFilePath:(NSString *)filePath {
    TTUGCImageCompressTask* task = [[TTUGCImageCompressTask alloc] init];
    task.key = filePath;
    task.originalSource = filePath;

    [self p_prepareTask:&task];
    
    return task;
}

- (void)removeCompressTask:(TTUGCImageCompressTask *)task {
    if (task) {
        FHMainSafeExecuteBlock(^{
            if ([self.waitingTasks containsObject:task]) {
                [self.waitingTasks removeObject:task];
            }
            if ([_executingTask isEqual:task]) {
                [_executingTask.completeBlockArray removeAllObjects];
            }
        });
    }
}


- (void)deleteTask:(TTUGCImageCompressTask *)task {
    if (task) {
        [self removeCompressTask:task];
        FHMainSafeExecuteBlock(^{
            if ([_fileManager fileExistsAtPath:task.realFilePath]) {
                [_fileManager removeItemAtPath:task.realFilePath error:nil];
            }
        });
    }
}

/**
 根据名字返回地址，位置在libraryCache目录，不需要管理磁盘问题，下次启动会被清理掉的
 
 @param name 文件名
 @return 路径
 */
- (NSString*)_filePathWithName:(NSString*)name {
    if (isEmptyString(name)) {
        return nil;
    }
    
    long compressCode = [TTKitchen getInt:kTTKUGCImageCompressLongLongPX] + [TTKitchen getInt:kTTKUGCImageCompressLongShortPX] + [TTKitchen getInt:kTTKUGCImageCompressNormalPX] + [TTKitchen getInt:kTTKUGCImageCompressGifMaxFrameCount];
    
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

#pragma - mark Private method
- (void)p_prepareTask:(TTUGCImageCompressTask **)task {
    FHMainSafeSyncExecuteBlock(^{
        if ([_executingTask isEqual:*task]) {
            *task = _executingTask;
            return;
        }
        NSUInteger index = [self.waitingTasks indexOfObject:*task];
        if (index != NSNotFound) {
            *task = [self.waitingTasks objectAtIndex:index];
        }
    });
    
    [self queryFilePathWithTask:*task complete:nil];
}

#pragma - mark Getter & Setter

- (NSMutableArray *)waitingTasks {
    if (_waitingTasks == nil) {
        _waitingTasks = [NSMutableArray array];
    }
    return _waitingTasks;
}
@end
