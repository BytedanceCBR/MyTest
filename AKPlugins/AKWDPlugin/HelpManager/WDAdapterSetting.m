//
//  WDAdapterSetting.m
//  TTWenda
//
//  Created by 延晋 张 on 2017/10/23.
//

#import "WDAdapterSetting.h"

@implementation WDAdapterSetting

+ (instancetype)sharedInstance
{
    static WDAdapterSetting *setting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[WDAdapterSetting alloc] init];
    });
    return setting;
}

- (void)showRedPackViewWithRedPackModel:(WDRedPackStructModel *)wdRedModel
                              extraDict:(NSDictionary *)dict
                         viewController:(UIViewController *)viewController
{
    if ([self.methodDelegate respondsToSelector:@selector(adapterShowRedPackViewWithRedPackModel:extraDict:viewController:)]) {
        [self.methodDelegate adapterShowRedPackViewWithRedPackModel:wdRedModel extraDict:dict viewController:viewController];
    }
}

- (void)commentViewControllerDidSelectedWithInfo:(NSDictionary *)info
                                  viewController:(UIViewController *)viewContorller
                                    dismissBlock:(void(^)(void))dismissBlock
{
    if ([self.methodDelegate respondsToSelector:@selector(adapterCommentViewControllerDidSelectedWithInfo:viewController:dismissBlock:)]) {
        [self.methodDelegate adapterCommentViewControllerDidSelectedWithInfo:info viewController:viewContorller dismissBlock:dismissBlock];
    }
}

- (BOOL)commentToolBarEnable
{
    if ([self.methodDelegate respondsToSelector:@selector(adapterCommentToolBarEnable)]) {
        return [self.methodDelegate adapterCommentToolBarEnable];
    }
    return YES;
}

- (void)presentRecordImportVideoViewControllerWithExtraTrack:(NSDictionary *)extraTrack
                                             completionBlock:(void(^)(BOOL completed, TTRecordedVideo * recordedVideo))completionBlock; {
//    if ([self.methodDelegate respondsToSelector:@selector(adapterPresentRecordImportVideoViewControllerWithExtraTrack:completionBlock:)]) {
//        [self.methodDelegate adapterPresentRecordImportVideoViewControllerWithExtraTrack:extraTrack completionBlock:completionBlock];
//    }
}

+ (void)removeOtherVideoPlayViews {
    if ([[WDAdapterSetting sharedInstance].sender respondsToSelector:@selector(removeOtherVideoPlayerViews)]) {
        [[WDAdapterSetting sharedInstance].sender removeOtherVideoPlayerViews];
    }
}

+ (UIView *)createNewVideoPlayViewWithParams:(NSDictionary *)params {
    if ([[WDAdapterSetting sharedInstance].sender respondsToSelector:@selector(fetchVideoPlayerViewWithParams:)]) {
        return [[WDAdapterSetting sharedInstance].sender fetchVideoPlayerViewWithParams:params];
    }
    return nil;
}

+ (void)stopCurrentVideoPlayViewPlaying:(UIView *)videoView {
    if ([[WDAdapterSetting sharedInstance].sender respondsToSelector:@selector(stopCurrentVideoPlayerViewPlay:)]) {
        [[WDAdapterSetting sharedInstance].sender stopCurrentVideoPlayerViewPlay:videoView];
    }
}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state {
    if ([self.receiver respondsToSelector:@selector(playerPlaybackState:)]) {
        [self.receiver playerPlaybackState:state];
    }
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action {
    if ([self.receiver respondsToSelector:@selector(actionChangeCallbackWithAction:)]) {
        [self.receiver actionChangeCallbackWithAction:action];
    }
}

@end
