//
//  AWEVideoContainerViewController.h
//  Pods
//
//  Created by Zuyang Kou on 18/06/2017.
//
//

#import <UIKit/UIKit.h>

#import "AWEVideoPlayView.h"
#import "TSVShortVideoDataFetchManagerProtocol.h"
#import "TSVControlOverlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class TSVVideoDetailPromptManager;
@class AWEVideoDetailSecondUsePromptManager;

@class TSVDetailViewModel, AWEVideoDetailControlOverlayViewController, AWEVideoContainerCollectionViewCell;

@interface AWEVideoContainerViewController : UIViewController

@property (nonatomic, nullable, strong) id<TSVShortVideoDataFetchManagerProtocol> dataFetchManager;
@property (nonatomic, nullable, strong) TSVDetailViewModel *viewModel;
@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;

@property (nonatomic, copy, nullable) void (^didDoubleTap)(void);
@property (nonatomic, copy, nullable) void (^wantToClosePage)(void);
@property (nonatomic, copy, nullable) void (^configureOverlayViewController)(id<TSVControlOverlayViewController> viewController);

@property (nonatomic, assign) BOOL needCellularAlert;
@property (nonatomic, readonly) BOOL loadingCellOnScreen;
@property (nonatomic, nullable, copy) void (^loadMoreBlock)(BOOL preload);
@property (nonatomic, strong) TSVVideoDetailPromptManager *detailPromptManager;

- (void)replaceDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)dataFetchManager;
- (void)refreshCurrentModel;

- (void)refresh;
- (BOOL)canPullToClose;

- (void)playCurrentVideo;
- (void)pauseCurrentVideo;

- (UIView *)exitScreenshotView;

@end

NS_ASSUME_NONNULL_END
