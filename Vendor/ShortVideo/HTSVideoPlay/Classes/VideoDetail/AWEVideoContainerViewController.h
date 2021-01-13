//
//  AWEVideoContainerViewController.h
//  Pods
//
//  Created by Zuyang Kou on 18/06/2017.
//
//

#import <UIKit/UIKit.h>

#import "AWEVideoPlayView.h"
#import "FHShortVideoDetailFetchManager.h"
#import "TSVControlOverlayViewController.h"


NS_ASSUME_NONNULL_BEGIN

@class TSVVideoDetailPromptManager;
@class AWEVideoDetailSecondUsePromptManager;

@class TSVDetailViewModel, AWEVideoDetailControlOverlayViewController;

@interface AWEVideoContainerViewController : UIViewController

@property (nonatomic, nullable, strong) FHShortVideoDetailFetchManager *dataFetchManager;
@property (nonatomic, nullable, strong) TSVDetailViewModel *viewModel;
@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;

@property (nonatomic, copy, nullable) void (^didDoubleTap)(void);
@property (nonatomic, copy, nullable) void (^wantToClosePage)(void);
@property (nonatomic, copy, nullable) void (^configureOverlayViewController)(id<TSVControlOverlayViewController> viewController);

@property (nonatomic, assign) BOOL needCellularAlert;
@property (nonatomic, readonly) BOOL loadingCellOnScreen;
@property (nonatomic, nullable, copy) void (^loadMoreBlock)(BOOL preload);
@property (nonatomic, nullable, copy) void (^didScroll)(void);
@property (nonatomic, strong) TSVVideoDetailPromptManager *detailPromptManager;

//外面传的埋点信息 by xsm
@property (nonatomic, strong) NSDictionary *extraDic;

//- (void)replaceDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)dataFetchManager;
- (void)refreshCurrentModel;
- (void)refresh;
- (BOOL)canPullToClose;
- (void)playCurrentVideo;
- (void)pauseCurrentVideo;
- (UIView *)exitScreenshotView;
- (void)videoOverTracer;

@end

NS_ASSUME_NONNULL_END
