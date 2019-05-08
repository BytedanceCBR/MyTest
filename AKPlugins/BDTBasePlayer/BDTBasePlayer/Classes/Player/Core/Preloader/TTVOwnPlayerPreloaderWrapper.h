//
//  TTVOwnPlayerPreloaderWrapper.h
//  BDTBasePlayer
//
//  Created by peiyun on 2017/12/24.
//

#import <Foundation/Foundation.h>
#import <TTPreloaderSDK/TTAVPreloader.h>

extern int TTVOwnPlayerPreloaderDefaultResolution;

@class TTAdPlayerPreloadModel;

@interface TTVOwnPlayerPreloaderWrapper : NSObject

@property (nonatomic, strong, readonly) TTAVPreloader *preloader;

+ (instancetype)sharedPreloader;

- (HandleType)preloadVideoID:(NSString *)videoID;
- (HandleType)preloadVideoID:(NSString *)videoID group:(NSString *)group;
- (void)cancelTaskForVideoID:(NSString *)videoID;
- (void)cancelGroup:(NSString *)group;
- (void)cancel;
- (void)clear;

- (void)addAdPreloadItem:(TTAdPlayerPreloadModel *)model;

@end

@interface TTAdPlayerPreloadModel: NSObject

@property (nonatomic, strong) NSString *ad_id;
@property (nonatomic, strong) NSString *log_extra;
@property (nonatomic, assign) HandleType hanlder;

- (instancetype)initWithAdId:(NSString *)ad_id logExtra:(NSString *)logExtra handleType:(HandleType)hanlder;

@end


