//
//  WDAdapterSetting.h
//  TTWenda
//
//  Created by 延晋 张 on 2017/10/23.
//

#import <Foundation/Foundation.h>
#import <BDTBasePlayer/TTVPlayerControllerState.h>
#import <BDTBasePlayer/TTVPlayerStateAction.h>

/*
 * 1.31 添加视频播放相关方法，壳工程，主工程互相调用
 */

NS_ASSUME_NONNULL_BEGIN

@class WDRedPackStructModel;
@class TTRecordedVideo;

@protocol WDAdapterMethodDelegate <NSObject>

@optional

- (void)adapterShowRedPackViewWithRedPackModel:(WDRedPackStructModel *)wdRedModel
                                     extraDict:(NSDictionary *)dict
                                viewController:(UIViewController *)viewController;

- (void)adapterCommentViewControllerDidSelectedWithInfo:(NSDictionary *)info
                                         viewController:(UIViewController *)viewContorller
                                           dismissBlock:(void(^)(void))dismissBlock;

- (BOOL)adapterCommentToolBarEnable;

- (void)adapterPresentRecordImportVideoViewControllerWithExtraTrack:(NSDictionary *)extraTrack
                                                    completionBlock:(void(^)(BOOL completed, TTRecordedVideo * recordedVideo))completionBlock;

@end

@protocol WDVideoPlayerTransferReceiver <NSObject>

- (void)playerPlaybackState:(TTVVideoPlaybackState)state;
- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action;

@end

@protocol WDVideoPlayerTransferSender <NSObject>

- (UIView *)fetchVideoPlayerViewWithParams:(NSDictionary *)params;
- (void)stopCurrentVideoPlayerViewPlay:(UIView *)playerView;
- (void)removeOtherVideoPlayerViews;

@end

@interface WDAdapterSetting : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) id<WDAdapterMethodDelegate> methodDelegate;
@property (nonatomic, strong) id <WDVideoPlayerTransferSender> sender;
@property (nonatomic, weak) id <WDVideoPlayerTransferReceiver> receiver;

- (void)showRedPackViewWithRedPackModel:(WDRedPackStructModel *)wdRedModel
                              extraDict:(NSDictionary *)dict
                         viewController:(UIViewController *)viewController;

- (void)commentViewControllerDidSelectedWithInfo:(NSDictionary *)info
                                  viewController:(UIViewController *)viewContorller
                                    dismissBlock:(void(^)(void))dismissBlock;

- (BOOL)commentToolBarEnable;

- (void)presentRecordImportVideoViewControllerWithExtraTrack:(NSDictionary *)extraTrack
                                             completionBlock:(void(^)(BOOL completed, TTRecordedVideo * recordedVideo))completionBlock;

+ (void)removeOtherVideoPlayViews;

+ (void)stopCurrentVideoPlayViewPlaying:(UIView *)videoView;

+ (UIView *)createNewVideoPlayViewWithParams:(NSDictionary *)params;

- (void)playerPlaybackState:(TTVVideoPlaybackState)state;

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action;

@end

NS_ASSUME_NONNULL_END
