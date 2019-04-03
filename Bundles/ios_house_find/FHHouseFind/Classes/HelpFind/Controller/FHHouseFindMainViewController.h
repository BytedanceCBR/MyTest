//
//  FHHouseFindMainViewController.h
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import "FHBaseViewController.h"
#import <FHHouseBase/FHHouseSuggestionDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindMainViewController : FHBaseViewController

@property (nonatomic, weak) id<FHHouseSuggestionDelegate> helpDelegate;
@property (nonatomic, weak) UIViewController *backListVC; // 需要返回到的页面

- (void)addHouseFindHelpVC;
- (void)addHouseFindResultVC;
- (void)jump2HouseFindHelpVC;
- (void)jump2HouseFindResultVC;

@end

NS_ASSUME_NONNULL_END
