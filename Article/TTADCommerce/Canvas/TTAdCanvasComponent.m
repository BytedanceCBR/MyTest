//
//  TTAdCanvasComponent.m
//  Article
//
//  Created by carl on 2017/11/13.
//

#import "TTAdCanvasComponent.h"
#import "TTPhotoDetailAdModel.h"
#import "TTImageInfosModel.h"

@implementation TTAdCanvasComponent

- (NSString *)componentType {
    return nil;
}

- (NSString *)componentName {
    return nil;
}

- (NSDictionary *)exportComponent {
    NSMutableDictionary *component = [NSMutableDictionary dictionary];
    [component setValue:[self componentType] forKey:@"type"];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:[self componentName] forKey:@"name"];
    [data setValue:self.styles forKey:@"styles"];
    [data setValue:self.data forKey:@"data"];
    [component setValue:data forKey:@"data"];
    return component;
}

@end

@implementation TTAdCanvasComponentPicture

- (NSString *)componentType {
    return @"image";
}

- (NSString *)componentName {
    return @"RCTPicturex";
}

- (instancetype)initWithImageModel:(TTImageInfosModel *)imageModel {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    if (imageModel == nil) {
        return nil;
    }
    
    if (SSIsEmptyArray(imageModel.urlWithHeader)) {
        return nil;
    }
    
    NSDictionary *firstURL = imageModel.urlWithHeader.firstObject;
    if (SSIsEmptyDictionary(firstURL) || firstURL[@"url"] == nil) {
        return nil;
    }
    
    NSMutableDictionary *styles = [NSMutableDictionary dictionary];
    [styles setValue:@(imageModel.width) forKey:@"width"];
    [styles setValue:@(imageModel.height) forKey:@"height"];
    self.styles = [styles copy];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:firstURL[@"url"] forKey:@"imgsrc"];

    self.data = [data copy];
    return self;
}

@end

@implementation TTAdCanvasComponentVideo

- (NSString *)componentType {
    return @"video";
}

- (NSString *)componentName {
    return @"RCTVideox";
}

- (instancetype)initWithImageModel:(TTImageInfosModel *)imageModel  videoID:(NSString *)videoID {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    if (imageModel == nil) {
        return nil;
    }
    if (SSIsEmptyArray(imageModel.urlWithHeader)) {
        return nil;
    }
    NSDictionary *firstURL = imageModel.urlWithHeader.firstObject;
    if (SSIsEmptyDictionary(firstURL) || firstURL[@"url"] == nil) {
        return nil;
    }
    
    NSMutableDictionary *styles = [NSMutableDictionary dictionary];
    [styles setValue:@(imageModel.width) forKey:@"width"];
    [styles setValue:@(imageModel.height) forKey:@"height"];
    self.styles = [styles copy];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
//    NSString *videoURL = [NSString stringWithFormat:@"http://i.snssdk.com/video/playcode/1/toutiao/%@?auto_play=%@",videoInfo[@"video_id"], videoInfo[@"direct_play"]];
   // [data setValue:videoURL forKey:@"url"];
    [data setValue:firstURL[@"url"] forKey:@"coverUrl"];
    [data setValue:videoID forKey:@"videoId"];
    [data setValue:@"horizontal" forKey:@"portraitMode"];
    [data setValue:imageModel.URI forKey:@"coverTag"];
    
    self.data = [data copy];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)videoInfo error:(NSError *__autoreleasing *)err {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    NSDictionary *detail_video_large_image = videoInfo[@"detail_video_large_image"];
    TTAdImageModel *imageModel = [[TTAdImageModel alloc] initWithDictionary:detail_video_large_image error:err];
    if (imageModel == nil) {
        return nil;
    }
    NSMutableDictionary *styles = [NSMutableDictionary dictionary];
    [styles setValue:imageModel.width forKey:@"width"];
    [styles setValue:imageModel.height forKey:@"height"];
    self.styles = [styles copy];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSString *videoURL = [NSString stringWithFormat:@"http://i.snssdk.com/video/playcode/1/toutiao/%@?auto_play=%@",videoInfo[@"video_id"], videoInfo[@"direct_play"]];
    [data setValue:videoURL forKey:@"url"];
    [data setValue:imageModel.url forKey:@"coverUrl"];
    [data setValue:videoInfo[@"video_id"] forKey:@"videoId"];
    [data setValue:@"horizontal" forKey:@"portraitMode"];
    [data setValue:imageModel.uri forKey:@"coverTag"];
    self.data = [data copy];
    return self;
}

@end
