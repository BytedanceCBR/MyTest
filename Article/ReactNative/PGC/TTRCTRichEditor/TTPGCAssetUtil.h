//
//  TTPGCAssetUtil.h
//  Article
//
//  Created by liaozhijie on 2017/7/21.
//
//

#ifndef TTAssetUtil_h
#define TTAssetUtil_h

#import <Photos/PHAsset.h>

@interface TTPGCAssetUtil : NSObject

// 根据asset(PHAsset | ALAsset) 获取asset url
+ (NSURL *_Nullable)getURLStringFromAsset:(id _Nullable )asset;

// 根据asser url 获取图片
+ (void)getImageDataFromURL:(NSURL*_Nullable)url
              resultHandler:(void(^_Nullable)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))resultHandler;

// 根据 PHAsset 获取图片
+ (void)getImageDataFromPHAsset:(PHAsset *_Nullable)asset
                  resultHandler:(void(^_Nullable)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))resultHandler;
@end

#endif /* TTAssetUtil_h */
