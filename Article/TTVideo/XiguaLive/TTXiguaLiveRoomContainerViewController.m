//
//  TTXiguaLiveRoomContainerViewController.m
//  Article
//
//  Created by lishuangyang on 2017/12/20.
//

#import "TTXiguaLiveRoomContainerViewController.h"
#import <TTRoute/TTRoute.h>
#import "TTXiguaLiveManager.h"
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import "TTIndicatorView.h"
@interface TTXiguaLiveRoomContainerViewController ()

@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSString *userID;

@end

@implementation TTXiguaLiveRoomContainerViewController

+(void)load{
    RegisterRouteObjWithEntryName(@"xigua_live");
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttHideNavigationBar = YES;
        self.ttDisableDragBack = YES;
        self.hidesBottomBarWhenPushed = YES;
        [self setUpWithBaseCondition:paramObj.allParams];
    }
    if (_userID || _roomID) {
        return self;
    }else{
        return nil;
    }
}


- (void)setUpWithBaseCondition:(NSDictionary *)baseCondition{
    _roomID = [baseCondition tta_stringForKey:@"room_id"];
    _userID = [baseCondition tta_stringForKey:@"user_id"];
    UIViewController *liveRoom = nil;
    NSMutableDictionary *mbaseCondition = [NSMutableDictionary dictionaryWithDictionary:baseCondition];
    [mbaseCondition removeObjectForKey:@"room_id"];
    [mbaseCondition removeObjectForKey:@"user_id"];

    if ([[TTXiguaLiveManager sharedManager] isAlreadyInThisRoom:_roomID userID:_userID]){
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"您已经在该直播间内", nil)
                                 indicatorImage:nil
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;

    }else{
        if(_userID){
            liveRoom = [[TTXiguaLiveManager sharedManager] audienceRoomWithUserID:_userID extraInfo:[mbaseCondition copy]];
        }else if (_roomID) {
            liveRoom = [[TTXiguaLiveManager sharedManager] audienceRoomWithRoomID:_roomID extraInfo:[mbaseCondition copy]];
        }
        if (liveRoom) {
            [self addChildViewController:liveRoom];
            [liveRoom didMoveToParentViewController:self];
            [self.view addSubview:liveRoom.view];
        }else{
            // 兼容roomID & USerID 都获取不到room的情况
            _roomID = nil;
            _userID = nil;
        }
    }

}

@end
