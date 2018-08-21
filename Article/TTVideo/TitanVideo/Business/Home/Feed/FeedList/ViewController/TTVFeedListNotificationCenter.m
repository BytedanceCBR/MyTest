//
//  TTVFeedListNotificationCenter.m
//  Article
//
//  Created by lijun.thinker on 2017/4/18.
//
//

#import "TTVFeedListNotificationCenter.h"
#import "TTVFeedListViewController.h"
#import "TTAccountManager.h"
#import "NewsListLogicManager.h"
#import "TTVVideoDetailViewController.h"
#import "ExploreEntryManager.h"
#import "TTVideoArticleService.h"
#import "ExploreMixListDefine.h"
#import "TTVideoUserInfoService.h"
#import "TTVFeedListViewModel.h"
#import "TTVFeedListItem.h"
#import "TTReachability.h"
#import "PBModelHeader.h"
#import "TTVFeedWebCellContentView.h"
#import "TTUserSettingsManager+FontSettings.h"

extern NSString *const TTMovieDidExitFullscreenNotification;

@interface TTVFeedListNotificationCenter()

@property (nonatomic, weak) id <TTVFeedListNotificationCenterDelegate> delegate;

@end

@implementation TTVFeedListNotificationCenter

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (void)registerNotificationsWithTarget:(id)target {
    
    self.delegate = target;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_clearCacheNotification:) name:@"SettingViewClearCachdNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_readModeChangedNotification:) name:kReadModeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_connectionChangedNotification:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_fontChangedNotification:) name:kSettingFontSizeChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receiveShowRemoteReloadTipNotification:) name:kNewsListFetchedRemoteReloadTipNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receiveFetchRemoteReloadTipNotification:) name:kNewsListShouldFetchedRemoteReloadTipNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receiveFirstRefreshTipNotification:) name:kFirstRefreshTipsSettingEnabledNotification object:nil];
    
    //ugc视频 分享面板举报变为删除
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_deleteVideoNotification:) name:TTVideoDetailViewControllerDeleteVideoArticle object:nil];

    //订阅状态变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_subscribeStatusChangedNotification:) name:kEntrySubscribeStatusChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_appDidBeComeactiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_appDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receiveWebCellDidUpdateNotification:) name:kTTVWebCellDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receiveExitFullScreenNotification:) name:TTMovieDidExitFullscreenNotification object:nil];
}

#pragma mark - Private Methods

//- (void)p_performSelector:(SEL)aSelector withObject:(id)object {
//    
//    if ([self.target respondsToSelector:aSelector]) {
//        
//        ((void (*)(id, SEL, id))[self.target methodForSelector:aSelector])(self.target, aSelector, object);
//    }
//}

- (void)p_clearCacheNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenterClearCache:)]) {
        
        [_delegate feedListNotificationCenterClearCache:self];
    }
}

- (void)p_readModeChangedNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenterReadModeChanged:)]) {
        
        [_delegate feedListNotificationCenterReadModeChanged:self];
    }
    
}

- (void)p_connectionChangedNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenterConnectionChanged:)]) {
        
        [_delegate feedListNotificationCenterConnectionChanged:self];
    }
}

- (void)p_fontChangedNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenterFontChanged:)]) {
        
        [_delegate feedListNotificationCenterFontChanged:self];
    }

}

- (void)p_receiveShowRemoteReloadTipNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenter:receiveShowRemoteReloadTipInfo:)]) {
        
        [_delegate feedListNotificationCenter:self receiveShowRemoteReloadTipInfo:notification.userInfo];
    }
}

- (void)p_receiveFetchRemoteReloadTipNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenter:receiveFetchRemoteReloadTipInfo:)]) {
        
        [_delegate feedListNotificationCenter:self receiveFetchRemoteReloadTipInfo:notification.userInfo];
    }

}

- (void)p_receiveFirstRefreshTipNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenter:receiveFirstRefreshTipInfo:)]) {
        
        [_delegate feedListNotificationCenter:self receiveFirstRefreshTipInfo:notification.userInfo];
    }
}

- (void)p_deleteVideoNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenter:deleteVideoInfo:)]) {
        
        [_delegate feedListNotificationCenter:self deleteVideoInfo:notification.userInfo];
    }
}

- (void)p_subscribeStatusChangedNotification:(NSNotification *)notification {
    
    ExploreEntry * item = [notification.userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    [[[TTServiceCenter sharedInstance] getService:[TTVideoUserInfoService class]] updateFollow:item.subscribed.boolValue userId:item.userID.longLongValue];
}

- (void)p_appDidBeComeactiveNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenterAppDidBeComeactive:)]) {
        
        [_delegate feedListNotificationCenterAppDidBeComeactive:self];
    }
}

- (void)p_appDidEnterBackgroundNotification:(NSNotification *)notification {
    
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenterAppDidEnterBackground:)]) {
        
        [_delegate feedListNotificationCenterAppDidEnterBackground:self];
    }
}

- (void)p_receiveWebCellDidUpdateNotification:(NSNotification *)notification {
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenterWebCellDidUpdate:relatedWebItem:)]) {
        
        [_delegate feedListNotificationCenterWebCellDidUpdate:self relatedWebItem:notification.object];
    }
}

- (void)p_receiveExitFullScreenNotification:(NSNotification *)notification {
    if ([_delegate respondsToSelector:@selector(feedListNotificationCenterExitFullScreen:)]) {
        
        [_delegate feedListNotificationCenterExitFullScreen:self];
    }
}

@end
