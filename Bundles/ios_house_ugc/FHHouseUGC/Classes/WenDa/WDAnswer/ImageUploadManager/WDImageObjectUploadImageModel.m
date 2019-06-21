//
//  WDImageObjectUploadImageModel.m
//  Article
//
//  Created by 延晋 张 on 16/7/20.
//
//

#import "WDImageObjectUploadImageModel.h"

@implementation WDImageObjectUploadImageModel

- (instancetype)initWithcompressImg:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithcompressImg:nil];
}

- (void)loadImageWithURL:(NSURL *)imageURL
{
    if (![imageURL isKindOfClass:[NSURL class]]) {
        NSAssert(NO, @"imageURL is not NSURL instance");
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        self.image = [UIImage imageWithData:data];
    });
}

- (BOOL)imageReady
{
    if (self.image) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - WDUploadImageModelProtocol

- (WDUploadImageSourceType)sourceType
{
    return WDUploadImageSourceTypeImage;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.remoteImgUri = [aDecoder decodeObjectForKey:@"remoteImgUri"];
        self.thirdImgUri = [aDecoder decodeObjectForKey:@"thirdImgUri"];
        self.compressImgUri = [aDecoder decodeObjectForKey:@"compressImgUri"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.remoteImgUri forKey:@"remoteImgUri"];
    [aCoder encodeObject:self.thirdImgUri forKey:@"thirdImgUri"];
    [aCoder encodeObject:self.compressImgUri forKey:@"compressImgUri"];
}

@end
