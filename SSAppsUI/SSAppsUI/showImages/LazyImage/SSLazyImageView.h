//
//  SSLazyImageView.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
/*
    1.该类中使用的SSImageInfosModel可以没有高宽
*/

#import <UIKit/UIKit.h>
#import "SSImageInfosModel.h"

@protocol SSLazyImageViewDelegate;

typedef enum {
    //default
    SSLazyImageViewClipTypeNone = 0,
    SSLazyImageViewClipTypeRemainTop = 1,
    SSLazyImageViewClipTypeRemainCenter = 2
}SSLazyImageViewClipType;

@interface SSLazyImageView : UIView

@property(nonatomic, assign) id<SSLazyImageViewDelegate> delegate;
@property (nonatomic, retain, readonly) UIImageView * netImageView;
@property(nonatomic, retain) UIView * defaultView;
//@property(nonatomic, assign) float borderWidth;
@property(nonatomic, assign) SSLazyImageViewClipType clipType;
@property (nonatomic, assign) CGFloat cornerRadius;

+ (CGSize)CaculateImageMatchCurrentDevice:(CGSize)imageSize;

//- (void)setBorderColor:(UIColor *)borderColor;
- (void)cancelImageRequest;

- (void)setLayerConerRadius:(CGFloat)radius;

//设置方法
//接下来三个方法中，前两个方法会将URL信息转换为model, 使用setLayerConerRadius:获取当前MODEL
- (void)setNetImageUrl:(NSString *)URLString;
- (void)setNetImageURL:(NSString *)URLstring withHeader:(NSDictionary *)header;
- (void)setNetImageInfosModel:(SSImageInfosModel *)model;

//获取
- (SSImageInfosModel *)currentImageModel;

@end

@protocol SSLazyImageViewDelegate <NSObject>

@optional

- (void)lazyImageView:(SSLazyImageView *)imageView didDownloadImageData:(NSData *)data;
- (void)lazyImageView:(SSLazyImageView *)imageView requestFailed:(NSError *)error;
- (void)lazyImageView:(SSLazyImageView *)imageView requestProgress:(float)progress;


@end