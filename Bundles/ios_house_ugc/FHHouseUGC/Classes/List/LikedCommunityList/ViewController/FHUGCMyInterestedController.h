//
//  FHUGCMyInterestedController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/13.
//

#import "FHBaseViewController.h"
#import "FHHouseUGCHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCMyInterestedController : FHBaseViewController

@property(nonatomic, assign) FHUGCMyInterestedType type;
@property(nonatomic, assign) BOOL forbidGoToDetail;
//新的发现页面
@property(nonatomic, assign) BOOL isNewDiscovery;

- (void)viewWillAppear;
- (void)viewWillDisappear;

@end

NS_ASSUME_NONNULL_END
