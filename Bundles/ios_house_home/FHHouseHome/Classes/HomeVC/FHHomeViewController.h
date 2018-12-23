//
//  FHHomeViewController.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHBaseViewController.h"
#import "TTVideoFeedListParameter.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeViewController : FHBaseViewController

@property (nonatomic, strong)NSString *baseView;

@property (nonatomic, assign) TTReloadType reloadFromType;

- (void)pullAndRefresh;

- (void)willAppear;

- (void)didAppear;

- (void)willDisappear;

- (void)didDisappear;

- (void)setTopEdgesTop:(CGFloat)top andBottom:(CGFloat)bottom;

@end

NS_ASSUME_NONNULL_END
