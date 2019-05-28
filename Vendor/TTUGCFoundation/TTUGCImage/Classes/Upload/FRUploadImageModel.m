//
//  FRUploadImageModel.m
//  Forum
//
//  Created by Zhang Leonardo on 15-4-30.
//
//

#import "FRUploadImageModel.h"
#import "FRUploadImageManager.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <BDWebImage/BDWebImageManager.h>

@interface FRUploadImageModel()
@property(nonatomic, strong)TTUGCImageCompressTask * cacheTask;
@end

@implementation FRUploadImageModel

- (id)initWithCacheTask:(TTUGCImageCompressTask*)task thumbnail:(UIImage *)thumbnailImg
{
    if (!task) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.cacheTask = task;
        self.thumbnailImg = thumbnailImg;
        self.isUploaded = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.webURI = [aDecoder decodeObjectForKey:@"webURI"];
        self.fakeUrl = [aDecoder decodeObjectForKey:@"fakeUrl"];
        if (!isEmptyString(self.fakeUrl)) {
            self.thumbnailImg = [[BDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:self.fakeUrl];
        }
        self.cacheTask = [[TTUGCImageCompressManager sharedInstance] generateTaskWithFilePath:[aDecoder decodeObjectForKey:@"cacheTaskKey"]];
        NSNumber * networkConsume = [aDecoder decodeObjectForKey:@"networkConsume"];
        self.networkConsume = networkConsume.unsignedLongLongValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (!isEmptyString(self.fakeUrl)) {
        [aCoder encodeObject:self.fakeUrl forKey:@"fakeUrl"];
    }
    if (self.cacheTask) {
        [aCoder encodeObject:self.cacheTask.key forKey:@"cacheTaskKey"];
    }
    
    if (self.thumbnailImg && self.fakeUrl.length > 0) {
        [[BDWebImageManager sharedManager].imageCache saveImageToDisk:self.thumbnailImg data:nil forKey:self.fakeUrl];
    }
    
    [aCoder encodeObject:self.webURI forKey:@"webURI"];
    [aCoder encodeObject:@(self.networkConsume) forKey:@"networkConsume"];
}

+ (NSString *)fakeUrl:(NSString *)taskId index:(NSUInteger)index {
    return [NSString stringWithFormat:@"frfake://frfakeimg/%@/%lu",taskId, index];
}

- (BOOL)isGIF {
    return _cacheTask && _cacheTask.assetModel && _cacheTask.assetModel.type == TTAssetModelMediaTypePhotoGif;
}

- (void)clearImageDiskCache {
    if (!isEmptyString(self.fakeUrl)) {
#warning 这个url和key一样吗
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BDImageCacheType type;
                type = BDImageCacheTypeAll;
            [[BDWebImageManager sharedManager].imageCache removeImageForKey:self.fakeUrl withType:type];
        });
    }
}
@end
