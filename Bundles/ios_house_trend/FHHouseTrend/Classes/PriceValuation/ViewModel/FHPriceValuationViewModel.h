//
//  FHPriceValuationViewModel.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/19.
//

#import <Foundation/Foundation.h>
#import "FHPriceValuationViewController.h"
#import "FHPriceValuationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationViewModel : NSObject

//屏蔽TTNavigationViewController带来的键盘变化
@property(nonatomic , assign) BOOL isHideKeyBoard;

- (instancetype)initWithView:(FHPriceValuationView *)tableView controller:(FHPriceValuationViewController *)viewController;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)goToHistory;

@end

NS_ASSUME_NONNULL_END
