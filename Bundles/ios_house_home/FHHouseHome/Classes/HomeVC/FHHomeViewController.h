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

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeViewController : FHBaseViewController <UIViewControllerErrorHandler>

@property (nonatomic, strong)NSString *baseView;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, assign) TTReloadType reloadFromType;
@property (nonatomic, assign) BOOL isMainTabVC;

- (void)pullAndRefresh;

- (void)willAppear;

- (void)didAppear;

- (void)willDisappear;

- (void)didDisappear;

- (void)setTopEdgesTop:(CGFloat)top andBottom:(CGFloat)bottom;

- (void)showNotify:(NSString *)message;

- (void)hideImmediately;

@end

NS_ASSUME_NONNULL_END
