//
//  AWEVideoDetailBottomControlOverlayViewController.h
//  Pods
//
//  Created by Zuyang Kou on 20/06/2017.
//
//

#import <UIKit/UIKit.h>
#import "TSVDetailViewModel.h"
#import "TSVControlOverlayViewModel.h"
#import "TSVControlOverlayViewController.h"
#import "FHFeedUGCCellModel.h"
@class AWEVideoDetailControlOverlayViewController;
@class TSVVideoDetailPromptManager;

NS_ASSUME_NONNULL_BEGIN;

@interface AWEVideoDetailControlOverlayViewController : UIViewController<TSVControlOverlayViewController>

@property (nonatomic, strong, nullable) FHFeedUGCCellModel *model;
@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;
@property (nonatomic, strong, nullable) TSVControlOverlayViewModel *viewModel;
@property (nonatomic, copy, nullable) void (^closeButtonDidClick)();
@property(nonatomic, strong)ExploreMovieMiniSliderView * miniSlider;
@property (weak, nonatomic, nullable) id<IESVideoPlayerProtocol> playerController;
@property (nonatomic, strong) TSVVideoDetailPromptManager *detailPromptManager;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;

- (void)diggShowAnima:(BOOL)showAnima;

- (void)tapToFoldRecCard;

@end

NS_ASSUME_NONNULL_END;
