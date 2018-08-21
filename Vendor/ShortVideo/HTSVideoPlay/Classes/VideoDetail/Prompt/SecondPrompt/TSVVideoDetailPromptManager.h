//
//  TSVVideoDetailPromptManager.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/8/25.
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN;

@interface TSVVideoDetailPromptManager : NSObject

@property (nonatomic, weak) id<TSVShortVideoDataFetchManagerProtocol> dataFetchManager;
@property (nonatomic, weak) UIViewController *containerViewController;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) NSDictionary *commonTrackingParameter;

- (void)videoDidPlayOneLoop;

- (void)videoDidPlayWithSwipe:(BOOL)swipe;

- (void)hidePrompt;

- (void)updateVisibleFloatingViewCountForVisibility:(BOOL)isVisible;

@end

NS_ASSUME_NONNULL_END;
