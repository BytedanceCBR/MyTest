//
//  TTWendaMethodDelegate.m
//  Article
//
//  Created by 延晋 张 on 2017/10/23.
//

#import "TTWendaMethodDelegate.h"

//#import "TTRedPacketManager.h"
#import "FRApiModel.h"
#import "UIViewController+BDTAccountModalPresentor.h"
#import "TTCommentDetailViewController.h"
#import <TTKitchen/TTKitchenMgr.h>
#import <TTKitchen/TTKitchenHeader.h>

#import <TTUIWidget/TTModalContainerController.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <AKWDPlugin/WDAdapterSetting.h>
#import <AKWDPlugin/WDApiModel.h>

#import "TTVPlayVideo.h"
#import "TTVDemandPlayer.h"
#import "TTVPlayerTipShareCreater.h"
#import "TTVVideoPlayerModel.h"
#import "TTVVideoPlayerStateStore.h"
//#import <BDTBasePlayer/TTVDemanderTrackerManager.h>
#import "FHDemanderTrackerManager.h"
#import <TTServiceKit/TTModuleBridge.h>

@interface TTWendaMethodDelegate () <WDAdapterMethodDelegate, TTModalContainerDelegate, TTVDemandPlayerDelegate, WDVideoPlayerTransferSender>

@property (nonatomic, copy) void(^selectedBlock)(void);

@end

@implementation TTWendaMethodDelegate

+ (void)load
{
    [WDAdapterSetting sharedInstance].methodDelegate = [TTWendaMethodDelegate new];
    [WDAdapterSetting sharedInstance].sender = [TTWendaMethodDelegate new];
}

#pragma mark - RedPack

- (void)adapterShowRedPackViewWithRedPackModel:(WDRedPackStructModel *)wdRedModel
                                     extraDict:(NSDictionary *)dict
                                viewController:(UIViewController *)viewController
{
//    TTRedPacketTrackModel * redPacketTrackModel = [TTRedPacketTrackModel new];
//    redPacketTrackModel.userId = [dict tt_stringValueForKey:@"user_id"];
//    redPacketTrackModel.categoryName = [dict tt_stringValueForKey:@"category"];
//    redPacketTrackModel.source = [dict tt_stringValueForKey:@"source"];
//    redPacketTrackModel.position = [dict tt_stringValueForKey:@"position"];
//    redPacketTrackModel.gdExtJson = [dict tt_dictionaryValueForKey:@"gd_ext_json"];
//
//    FRRedpackStructModel *frRedPack = [[self class] frRedPackModelWithWDRedPackModel:wdRedModel];
//    [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:frRedPack
//                                                               source:redPacketTrackModel
//                                                       viewController:viewController];
}

#pragma mark  Util

+ (FRRedpackStructModel *)frRedPackModelWithWDRedPackModel:(WDRedPackStructModel *)wdRedModel
{
    FRRedpackStructModel *structModel = [FRRedpackStructModel new];
    structModel.redpack_id = wdRedModel.redpack_id;
    structModel.token = wdRedModel.token;
    structModel.button_style = wdRedModel.button_style;
    structModel.user_info = [self frUserInfoWithWDUserStruct:wdRedModel.user_info];
    structModel.subtitle = wdRedModel.subtitle;
    structModel.content = wdRedModel.content;
    return structModel;
}

+ (FRCommonUserInfoStructModel *)frUserInfoWithWDUserStruct:(WDUserStructModel *)userStruct
{
    FRCommonUserInfoStructModel *infoModel = [FRCommonUserInfoStructModel new];
    infoModel.user_id = userStruct.user_id;
    infoModel.name = userStruct.uname;
    infoModel.desc = userStruct.user_intro;
    infoModel.schema = userStruct.user_schema;
    infoModel.avatar_url = userStruct.avatar_url;
    infoModel.user_auth_info = userStruct.user_auth_info;
    return infoModel;
}

#pragma mark - CommentSelectedWithInfo

- (void)adapterCommentViewControllerDidSelectedWithInfo:(NSDictionary *)info
                                         viewController:(UIViewController *)viewContorller
                                           dismissBlock:(void(^)(void))dismissBlock
{
    TTCommentDetailViewController *detailRoot = [[TTCommentDetailViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(info.copy)];
    TTModalContainerController *navVC = [[TTModalContainerController alloc] initWithRootViewController:detailRoot];
    navVC.containerDelegate = self;
    self.selectedBlock = dismissBlock;
    [viewContorller presentViewController:navVC animated:NO completion:nil];
}

#pragma mark - TTModalContainerDelegate

- (void)didDismissModalContainerController:(TTModalContainerController *)container
{
    [[UIApplication sharedApplication] setStatusBarStyle:[[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay? UIStatusBarStyleDefault: UIStatusBarStyleLightContent];
    if (self.selectedBlock) {
        self.selectedBlock();
        self.selectedBlock = nil;
    }
}

#pragma mark - CommentDetailBar

- (BOOL)adapterCommentToolBarEnable
{
    return [KitchenMgr getBOOL:KKCCommentRepostFirstDetailEnable];
}

#pragma mark - WDVideoPlayerTransferSender

- (UIView *)fetchVideoPlayerViewWithParams:(NSDictionary *)params {
    CGRect frame = CGRectFromString([params tt_stringValueForKey:@"frame"]);
    
    NSString *videoTitle = [params tt_stringValueForKey:@"videoTitle"];
    NSDictionary *logoImageDict = [params tt_dictionaryValueForKey:@"logoImageDict"];
    
    NSString *categoryID = [params tt_stringValueForKey:@"categoryID"];
    NSString *groupID = [params tt_stringValueForKey:@"groupID"];
    NSString *videoID = [params tt_stringValueForKey:@"videoID"];
    NSDictionary *fullTrack = [params tt_dictionaryValueForKey:@"fullTrack"];
    
    BOOL isInDetail = [[params tt_objectForKey:@"isInDetail"] boolValue];
    
    TTVVideoPlayerModel *model = [[TTVVideoPlayerModel alloc] init];
    model.categoryID = categoryID;
    model.groupID = groupID;
    model.videoID = videoID;
    model.authorId = [fullTrack tt_stringValueForKey:@"author_id"];
    model.enterFrom = [fullTrack tt_stringValueForKey:@"enter_from"];
    model.categoryName = [fullTrack tt_stringValueForKey:@"category_name"];
    
    TTVPlayVideo *video = [[TTVPlayVideo alloc] initWithFrame:frame playerModel:model];
    
    video.player.enableRotate = YES;
    video.player.showTitleInNonFullscreen = YES;
    [video setVideoLargeImageDict:logoImageDict];
    
    video.player.tipCreator = [[TTVPlayerTipShareCreater alloc] init];
    
    video.player.playerStateStore.state.isInDetail = isInDetail;
    [video.player.commonTracker addExtra:fullTrack forEvent:@"video_play"];
    [video.player.commonTracker addExtra:fullTrack forEvent:@"video_over"];
    
    video.player.delegate = self;
    [video.player readyToPlay];
    [video.player setVideoTitle:videoTitle];
    
    [video.player play];
    
    return video;
}

- (void)stopCurrentVideoPlayerViewPlay:(UIView *)playerView {
    if ([playerView isKindOfClass:[TTVPlayVideo class]]) {
        TTVPlayVideo *video = (TTVPlayVideo *)playerView;
        video.player.delegate = nil;
        [video exitFullScreen:NO completion:nil];
        [video stop];
    }
}

- (void)removeOtherVideoPlayerViews {
    [TTVPlayVideo removeAll];
}

#pragma mark - TTVDemandPlayerDelegate

- (void)playerPlaybackState:(TTVVideoPlaybackState)state {
    [[WDAdapterSetting sharedInstance] playerPlaybackState:state];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action {
    if (![action isKindOfClass:[TTVPlayerStateAction class]]) {
        return;
    }
    [[WDAdapterSetting sharedInstance] actionChangeCallbackWithAction:action];
}

@end
