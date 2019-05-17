//
//  TTAdResourceDefine.h
//  Article
//
//  Created by carl on 2017/5/28.
//
//


@class ExploreOrderedData;

typedef void(^TTAdDownloadCompletedBlock)(NSData * _Nullable data, NSError * _Nullable error, BOOL finished);
typedef void(^TTAdPreloaderCompletedBlock)(BOOL result, NSError*_Nullable error);

@protocol TTAdPreloader <NSObject>
- (void)preloadResource:(ExploreOrderedData *_Nullable)orderData completed:(TTAdPreloaderCompletedBlock _Nullable )successBlock;
+ (BOOL)needPreloadResource:(ExploreOrderedData *_Nullable)orderData;
@end
