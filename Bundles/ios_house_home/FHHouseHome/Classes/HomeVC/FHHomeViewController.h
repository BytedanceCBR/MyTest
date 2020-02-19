//
//  FHHomeViewController.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHBaseViewController.h"
#import "TTVideoFeedListParameter.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIScrollView+Refresh.h"
#import "UIViewController+Track.h"
#import "FHHomeBaseTableView.h"
#import "TTTopBar.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHomeBaseScrollView;

@interface FHHomeViewController : FHBaseViewController <UIViewControllerErrorHandler>

@property (nonatomic, strong)NSString *baseView;
@property (nonatomic, strong) FHHomeBaseTableView *mainTableView;
@property (nonatomic, assign) TTReloadType reloadFromType;
@property (nonatomic, assign) BOOL isMainTabVC;
@property (nonatomic, strong) FHHomeBaseScrollView *scrollView;
@property (nonatomic, assign) BOOL isShowRefreshTip;
@property (nonatomic, strong) TTTopBar *topBar;

- (void)pullAndRefresh;

- (void)willAppear;

- (void)didAppear;

- (void)willDisappear;

- (void)didDisappear;

- (void)setTopEdgesTop:(CGFloat)top andBottom:(CGFloat)bottom;

- (void)showNotify:(NSString *)message;

- (void)hideImmediately;

- (void)resetMaintableView;

- (void)bindIndexChangedBlock;

@end

NS_ASSUME_NONNULL_END
