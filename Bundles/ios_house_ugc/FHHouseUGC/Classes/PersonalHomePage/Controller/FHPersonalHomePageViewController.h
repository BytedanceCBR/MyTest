//
//  FHPersonalHomePageViewController.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHBaseViewController.h"
#import "FHPersonalHomePageProfileInfoView.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHPersonalHomePageViewController : FHBaseViewController
@property(nonatomic,strong) FHPersonalHomePageProfileInfoView *profileInfoView;
@property(nonatomic,strong) UIScrollView *scrollView;
@end

NS_ASSUME_NONNULL_END
