//
//  FHCommunityFeedListController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHBaseViewController.h"
#import "FHHouseUGCHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityFeedListController : FHBaseViewController

@property(nonatomic, assign) FHCommunityFeedListType listType;
//附加在feed上面的自定义view
@property(nonatomic, strong) UIView *tableHeaderView;

@end

NS_ASSUME_NONNULL_END
