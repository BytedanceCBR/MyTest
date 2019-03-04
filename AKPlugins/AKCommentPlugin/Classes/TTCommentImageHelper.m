//
//  TTCommentImageHelper.m
//  Article
//
//  Created by chenjiesheng on 2017/2/16.
//
//

#import "TTCommentImageHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <TTThemeManager.h>
#import <TTVerifyKit/UIImage+Masking.h>
#import <TTImageInfosModel.h>
#import <TTImageView.h>
#import <objc/runtime.h>

@implementation UIImage (TTThreadImageCategory)

- (NSString *)identifier
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setIdentifier:(NSString *)identifier{
    objc_setAssociatedObject(self, @selector(identifier), identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface TTCommentImageHelper ()

@property (nonatomic, strong)NSMutableArray <TTImageView *> *reuseImageViews;
@property (nonatomic, strong)NSMutableArray <TTImageView *> *busyImageViews;
@property (nonatomic, strong)NSMutableDictionary            *imageCacheDict;
@end

@implementation TTCommentImageHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reuseImageViews = @[].mutableCopy;
        _busyImageViews = @[].mutableCopy;
        _imageCacheDict = @{}.mutableCopy;
    }
    return self;
}

+ (instancetype)shareInstance{
    static TTCommentImageHelper *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[TTCommentImageHelper alloc] init];
    });
    
    return shareInstance;
}

- (TTImageView *)imageView{
    TTImageView *imageView = _reuseImageViews.firstObject;
    if (imageView){
        
        [_reuseImageViews removeObject:imageView];
        
    }else{
        imageView = [[TTImageView alloc] init];
    }
    
    [_busyImageViews addObject:imageView];
    
    return imageView;
}

- (void)setupObjectImageWithInfoModel:(TTImageInfosModel *)infoModel object:(NSObject *)object callback:(completionBlock)callback{
    NSString *imageURL = [infoModel urlStringAtIndex:0];
    NSString *dayURL = [NSString stringWithFormat:@"%@_day", imageURL];
    if ([_imageCacheDict valueForKey:dayURL]){
        UIImage * image = [_imageCacheDict valueForKey:dayURL];
        if ([object respondsToSelector:@selector(setImage:)]){
            [object performSelector:@selector(setImage:) withObject:image];
        }
        if (callback){
            callback(image);
        }
        return;
    }
    
    TTImageView *imageView = [self imageView];
    WeakSelf;
    __weak TTImageView *weakImageView = imageView;
    [imageView setImageWithModel:infoModel placeholderImage:nil options:SDWebImageAvoidAutoSetImage success:^(UIImage *image, BOOL cached) {
        StrongSelf;
        __strong TTImageView *strongImageView = weakImageView;
        image.identifier = imageURL;
        if (![_imageCacheDict valueForKey:dayURL]){
            [_imageCacheDict setValue:image forKey:dayURL];
        }
        [self.busyImageViews removeObject:strongImageView];
        [self.reuseImageViews addObject:strongImageView];
        if ([object respondsToSelector:@selector(setImage:)]){
            [object performSelector:@selector(setImage:) withObject:image];
        }
        if (callback){
            callback(image);
        }
    } failure:^(NSError *error) {
        if (callback){
            callback(nil);
        }
    }];
    
}



- (void)loadImageWithURL:(NSURL *)URL{
    
}

+ (UIImage *)nightImageWithOriginImage:(UIImage *)originImage{
    return [[self shareInstance] nightImageWithOriginImage:originImage];
}

+ (UIImage *)dayImageWithOriginImage:(UIImage *)originImage{
    return [[self shareInstance] dayImageWithOriginImage:originImage];
}

- (UIImage *)dayImageWithOriginImage:(UIImage *)originImage{
    if (!originImage.identifier){
        return originImage;
    }
    NSString *url = [NSString stringWithFormat:@"%@_day", originImage.identifier];;
    UIImage *image = [_imageCacheDict valueForKey:url];
    if (!image){
        image = originImage;
    }
    return image;
}

- (UIImage *)nightImageWithOriginImage:(UIImage *)originImage{
    if (!originImage.identifier){
        return originImage;
    }
    NSString *url = [NSString stringWithFormat:@"%@_night", originImage.identifier];;
    UIImage *image = [_imageCacheDict valueForKey:url];
    if (!image && originImage && url){
        image = [originImage tt_nightImage];
        image.identifier = originImage.identifier;
        [_imageCacheDict setValue:image forKey:url];
    }
    return image;
}


+ (void)setupObjectImageWithInfoModel:(TTImageInfosModel *)infoModel object:(NSObject *)object callback:(completionBlock)callback{
    [[self shareInstance] setupObjectImageWithInfoModel:infoModel object:object callback:callback];
}
@end
