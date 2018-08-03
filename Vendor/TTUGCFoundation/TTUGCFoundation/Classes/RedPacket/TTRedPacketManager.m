//
//  TTRedPacketManager.m
//  Article
//
//  Created by lipeilun on 2017/7/11.
//
//

#import "TTRedPacketManager.h"
#import "TTRedPacketViewWrapper.h"
#import "FRApiModel.h"
#import <TTUIResponderHelper.h>
#import "TTRedPacketViewController.h"
#import <TTNavigationController.h>
#import "TTDeviceHelper.h"
#import <TTDialogDirector/TTDialogDirector.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>

NSString * const TTRedpackOpenedNotification = @"TTRedpackOpenedNotification";
NSString * const TTRedpackNotifyKeyStyle = @"redpackStyle";

@implementation TTRedPacketTrackModel

@end

@implementation TTRedPacketManager

+ (TTRedPacketManager *)sharedManager {
    static TTRedPacketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTRedPacketManager alloc] init];
    });
    return manager;
}

- (void)presentRedPacketWithRedpacket:(FRRedpackStructModel *)redpacket
                               source:(TTRedPacketTrackModel *)trackModel
                       viewController:(UIViewController *)fromViewController {
    [self presentRedPacketWithStyle:TTRedPacketViewStyleDefault
                          redpacket:redpacket
                             source:trackModel
                     viewController:fromViewController];
}

- (void)presentRedPacketWithStyle:(TTRedPacketViewStyle)style
                        redpacket:(FRRedpackStructModel *)redpacket
                           source:(TTRedPacketTrackModel *)trackModel
                   viewController:(UIViewController *)fromViewController {
    NSAssert(fromViewController != nil, @"红包的弹出vc不能为空");
    [TTRedPacketManager trackRedPacketPresent:trackModel actionType:@"show"];
    
    TTRedPacketViewController *redPacketViewController = [[TTRedPacketViewController alloc] initWithStyle:style
                                                                                                redpacket:redpacket
                                                                                                    track:trackModel
                                                                                           viewController:fromViewController];
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:redPacketViewController];
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        UIGraphicsBeginImageContext(fromViewController.view.bounds.size);
        [fromViewController.view drawViewHierarchyInRect:fromViewController.view.bounds afterScreenUpdates:NO];
        UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        redPacketViewController.backingImage = screenImage;
    } else {
        navigationController.view.backgroundColor = [UIColor clearColor];
        navigationController.definesPresentationContext = YES;
        navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    
    [TTDialogDirector showInstantlyDialog:navigationController shouldShowMe:nil showMe:^(id  _Nonnull dialogInst) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTOpenRedPackertNotification" object:nil userInfo:nil];
        self.isShowingRedpacketView = YES;
        [fromViewController presentViewController:navigationController animated:NO completion:nil];
    } hideForcedlyMe:nil];
    
    __weak id<NSObject> weakObserver = nil;
    weakObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"TTCloseRedPackertNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (weakObserver) {
            [[NSNotificationCenter defaultCenter] removeObserver:weakObserver name:@"TTCloseRedPackertNotification" object:nil];
        }
        [TTDialogDirector dequeueDialog:navigationController];
    }];
}

+ (void)trackRedPacketPresent:(TTRedPacketTrackModel *)redpacket actionType:(NSString *)actiontype {
    if (!redpacket) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (!SSIsEmptyDictionary(redpacket.gdExtJson)) {
        [params setValuesForKeysWithDictionary:redpacket.gdExtJson];
    }
    [params setValue:actiontype forKey:@"action_type"];
    [params setValue:redpacket.userId forKey:@"user_id"];
    if (!isEmptyString(redpacket.mediaId)) {
        [params setValue:redpacket.mediaId forKey:@"media_id"];
    }
    [params setValue:redpacket.categoryName forKey:@"category_name"];
    [params setValue:redpacket.source forKey:@"source"];
    [params setValue:redpacket.position forKey:@"position"];
    if (redpacket.money > 0) {
        [params setValue:[NSNumber numberWithInteger:redpacket.money] forKey:@"value"];
    }
    [TTTrackerWrapper eventV3:@"red_packet" params:params];
}

@end
