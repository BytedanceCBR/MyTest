//
//  WDImagePathUploadImageModel.m
//  Article
//
//  Created by 王霖 on 15/12/21.
//
//

#import "WDImagePathUploadImageModel.h"
#import "WDPublisherAdapterSetting.h"
#import <TTBaseLib/TTBaseMacro.h>

@interface WDImagePathUploadImageModel ()

@property (nonatomic, copy) NSString *thirdImgUri;

@end

@implementation WDImagePathUploadImageModel

- (instancetype)initWithThirdImgUri:(NSString *)thirdImgUri
{
    self = [super init];
    if (self) {
        self.thirdImgUri = thirdImgUri;
        if (!isEmptyString(thirdImgUri)) {
            NSURL *url = [NSURL URLWithString:thirdImgUri];
            if ([[self class] isToutiaoUrl:url]) {
                self.remoteImgUri = [thirdImgUri lastPathComponent];
            }
        }
    }
    return self;
}

- (instancetype)initWithcompressImgUri:(NSString *)compressImgUri
{
    self = [super init];
    if (self) {
        self.compressImgUri = compressImgUri;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithcompressImgUri:nil];
}

- (void)setRemoteImgUri:(NSString *)remoteImgUri
{
    _remoteImgUri = remoteImgUri;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.thirdImgUri = [aDecoder decodeObjectForKey:@"thirdImgUri"];
        self.compressImgUri = [aDecoder decodeObjectForKey:@"compressImgUri"];
        self.remoteImgUri = [aDecoder decodeObjectForKey:@"remoteImgUri"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.thirdImgUri forKey:@"thirdImgUri"];
    [aCoder encodeObject:self.compressImgUri forKey:@"compressImgUri"];
    [aCoder encodeObject:self.remoteImgUri forKey:@"remoteImgUri"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    typeof(self) uploadImageModel = [[[self class] allocWithZone:zone] init];
    [(WDImagePathUploadImageModel *)uploadImageModel setThirdImgUri:[_thirdImgUri copyWithZone:zone]];
    [(WDImagePathUploadImageModel *)uploadImageModel setCompressImgUri:[_compressImgUri copyWithZone:zone]];
    [(WDImagePathUploadImageModel *)uploadImageModel setRemoteImgUri:[_remoteImgUri copyWithZone:zone]];
    return uploadImageModel;
}

#pragma mark - WDUploadImageModelProtocol

- (WDUploadImageSourceType)sourceType
{
    return WDUploadImageSourceTypePath;
}

#pragma mark - Util

+ (BOOL)isToutiaoUrl:(NSURL *)url
{
    if ([url.host rangeOfString:[[WDPublisherAdapterSetting sharedInstance] toutiaoImageHost]].length > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
