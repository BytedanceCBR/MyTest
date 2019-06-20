//
//  FHMessageNotificationTipsManager.m
//  Article
//
//  Created by lizhuoli on 17/3/24.
//
//

#import "FHMessageNotificationTipsManager.h"
#import "TTMessageNotificationTipsModel.h"
#import "FHMessageNotificationTipsView.h"

#import "TTRoute.h"
#import "FHMessageNotificationMacro.h"

#import "UIView+CustomTimingFunction.h"


#import <TTAccountBusiness.h>

#import "TTProfileViewController.h"
#import "TTUIResponderHelper.h"
#import "FHUnreadMsgModel.h"
#import "FHMessageTipBubble.h"
#import "FHBubbleTipManager.h"

#import <TTDialogDirector/TTDialogDirector.h>

NSString * const kTTMessageNotificationTipsChangeNotification = @"kTTMessageNotificationTipsChangeNotification";
NSString * const kTTMessageNotificationLastTipSaveKey = @"kTTMessageNotificationLastTipSaveKey";

@interface FHMessageNotificationTipsManager ()
@end

@implementation FHMessageNotificationTipsManager

+ (instancetype)sharedManager
{
    static FHMessageNotificationTipsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHMessageNotificationTipsManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init{
    if(self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTipsWithModel:(FHUnreadMsgDataUnreadModel *)model
{
    if (![model isKindOfClass:[FHUnreadMsgDataUnreadModel class]]) {
        return;
    }

    _tipsModel = model;
    if(self.tipsModel){
        [self tryShowNotifyBubble:self.tipsModel];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kTTMessageNotificationTipsChangeNotification object:nil];
}

- (void)clearTipsModel
{
    BOOL needNotify = (self.tipsModel != nil);
    _tipsModel = nil;
    
    if(needNotify){
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTMessageNotificationTipsChangeNotification object:nil];
    }
}

-(void)tryShowNotifyBubble:(FHUnreadMsgDataUnreadModel*)tipsModel{
    if(!tipsModel || [tipsModel.id isEqualToString:self.lastMsgId]){
        return;
    }
    [self saveLastMsgId];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *timeTip = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[tipsModel.timestamp longValue]]];

    FHBubbleData *bubbleData = [[FHBubbleData alloc] init];
    bubbleData.title = tipsModel.title;
    bubbleData.content = tipsModel.content;
    bubbleData.avatar = tipsModel.lastUserAvatar;
    bubbleData.time = timeTip;
    NSURL *openURL = [NSURL URLWithString:tipsModel.openUrl];

    BubbleClickCallback  clickCallback = ^(FHBubbleData *data, FHMessageTipBubble *bubble) {
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:nil];
            [bubble removeFromSuperview];
            [[FHBubbleTipManager shareInstance] removeWindow];
        }
    };
    [[FHBubbleTipManager shareInstance] tryShowBubbleTip:bubbleData clickCallback:clickCallback appearCallback:nil];
}

- (NSString *)lastMsgId{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTTMessageNotificationLastTipSaveKey];
}

-(void)saveLastMsgId{
    if(isEmptyString(self.tipsModel.id)){
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.tipsModel.id forKey:kTTMessageNotificationLastTipSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)unreadNumber {
    return [self.tipsModel.unread integerValue];
}

@end
