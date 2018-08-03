//
//  TTDislikeManager.m
//  Article
//
//  Created by zhaoqin on 28/12/2016.
//
//

#import "TTDislikeManager.h"
#import "ExploreItemActionManager.h"
#import "ExploreMixListDefine.h"
#import "TTMonitor.h"
#import "ExploreOrderedData+TTAd.h"

static TTDislikeManager *sharedInstance;
NSString *const TTDISLIKEMANAGER_SEND_DISLIKE = @"TTDISLIKEMANAGER_SEND_DISLIKE";

@interface TTDislikeManager ()
@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;
@end

@implementation TTDislikeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTDislikeManager alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendDislikeRequest:) name:TTDISLIKEMANAGER_SEND_DISLIKE object:nil];
    }
    return self;
}

- (void)sendDislikeRequest:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    ExploreOrderedData *orderData = [userInfo tt_objectForKey:@"orderData"];
    NSMutableDictionary *adExtra = [[NSMutableDictionary alloc] init];
    [adExtra setValue:orderData.log_extra forKey:@"log_extra"];
    if ([userInfo tt_objectForKey:kExploreMixListNotInterestWordsKey]) {
        
        NSNumber *adID = isEmptyString(orderData.ad_id) ? nil : @(orderData.ad_id.longLongValue);
        [self.itemActionManager startSendDislikeActionType:DetailActionTypeNewVersionDislike source:[userInfo tt_intValueForKey:@"dislike_source"] groupModel:[userInfo tt_objectForKey:@"groupModel"] filterWords:[userInfo tt_objectForKey:kExploreMixListNotInterestWordsKey] cardID:nil actionExtra:orderData.actionExtra adID:adID adExtra:adExtra widgetID:nil threadID:nil finishBlock:nil];
        [[TTMonitor shareManager] trackService:@"article_detail_dislike" status:1 extra:userInfo];
    }
    else {
        [[TTMonitor shareManager] trackService:@"article_detail_dislike" status:0 extra:userInfo];
    }
}

@end
