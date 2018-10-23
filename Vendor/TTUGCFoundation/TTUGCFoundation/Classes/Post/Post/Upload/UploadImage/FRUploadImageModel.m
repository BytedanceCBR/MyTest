//
//  FRUploadImageModel.m
//  Forum
//
//  Created by Zhang Leonardo on 15-4-30.
//
//

#import "FRUploadImageModel.h"
#import "FRUploadImageManager.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "TTBaseMacro.h"
#import "SDWebImageAdapter.h"

@interface FRUploadImageModel()
@property(nonatomic, strong)TTForumPostImageCacheTask * cacheTask;
@end

@implementation FRUploadImageModel

- (id)initWithCacheTask:(TTForumPostImageCacheTask*)task thumbnail:(UIImage *)thumbnailImg
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
            self.thumbnailImg = [[SDWebImageAdapter sharedAdapter]imageFromDiskCacheForKey:self.fakeUrl];
        }
        self.cacheTask = [[TTForumPostImageCache sharedInstance]saveCacheSource:[aDecoder decodeObjectForKey:@"cacheTaskKey"]];
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
        [[SDWebImageAdapter sharedAdapter] saveImageToCache:self.thumbnailImg forURL:[NSURL URLWithString:self.fakeUrl]];
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

@end
