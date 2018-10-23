//
//  TTImagePickerIcloudDownloader.m
//  Pods
//
//  Created by tyh on 2017/7/13.
//
//

#import "TTImagePickerIcloudDownloader.h"
#import "TTImagePickerIcloudDownloaderOperation.h"
#import "TTImagePickerManager.h"

@interface TTImagePickerIcloudDownloader()

@property (nonatomic,strong)NSOperationQueue *singleQueue;
@property (nonatomic,strong)NSOperationQueue *downloaderQueue;

@end

@implementation TTImagePickerIcloudDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.singleQueue = [[NSOperationQueue alloc]init];
        self.singleQueue.maxConcurrentOperationCount = 1;
        self.downloaderQueue = [[NSOperationQueue alloc]init];
        self.downloaderQueue.maxConcurrentOperationCount = 2;
        
    }
    return self;
}

- (void)getIcloudPhotoWithAsset:(PHAsset *)asset completion:(IcloudCompletion)completion progressHandler:(IcloudProgressHandler)progressHandler isSingleTask:(BOOL)isSingleTask
{
    
    dispatch_async(creat_icloud_handle_queue(), ^{
        if (!asset || ![[TTImagePickerManager manager] getAssetIdentifier:asset]) {
            return;
        }
        NSOperationQueue *taskQueue = nil;
        if (isSingleTask) {
            taskQueue = self.singleQueue;
            //如果是预览，每次都会清空所有任务
            [self.singleQueue cancelAllOperations];
        }else{
            taskQueue = self.downloaderQueue;
            
            for (TTImagePickerIcloudDownloaderOperation *op in taskQueue.operations) {
                //同一个任务 直接合并
                if ([[[TTImagePickerManager manager] getAssetIdentifier:op.asset] isEqualToString:[[TTImagePickerManager manager] getAssetIdentifier:asset]] ) {
                    [op addCompletion:completion progressHandler:progressHandler];
                    
                    return;
                }
            }
        }
        TTImagePickerIcloudDownloaderOperation *op = [[TTImagePickerIcloudDownloaderOperation alloc]initWithAsset:asset];
        [op addCompletion:completion progressHandler:progressHandler];
        
        [taskQueue addOperation:op];
    });
    
}

- (BOOL)cancelDownloadIcloudPhotoWithAsset:(PHAsset *)asset
{
    dispatch_async(creat_icloud_handle_queue(), ^{
        for (TTImagePickerIcloudDownloaderOperation *op in self.downloaderQueue.operations) {
            //同一个任务 直接合并
            if ([[[TTImagePickerManager manager] getAssetIdentifier:op.asset] isEqualToString:[[TTImagePickerManager manager] getAssetIdentifier:asset]] ) {
                [op cancel];
                break;
            }
        }
    });
    return YES;
}


- (void)cancelSingleIcloud
{
    dispatch_async(creat_icloud_handle_queue(), ^{
        [self.singleQueue cancelAllOperations];
    });
}

static dispatch_queue_t creat_icloud_handle_queue() {
    static dispatch_queue_t icloud_handle_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        icloud_handle_queue = dispatch_queue_create("tt_icloud_handle_queue", DISPATCH_QUEUE_SERIAL);
    });
    return icloud_handle_queue;
}



@end
