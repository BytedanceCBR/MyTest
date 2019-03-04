//
//  FHLoginViewModel.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import <Foundation/Foundation.h>
#import "FHLoginViewController.h"
#import "FHLoginView.h"
#import "TTAccountLoginManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHLoginViewModel : NSObject

//屏蔽TTNavigationViewController带来的键盘变化
@property(nonatomic , assign) BOOL isHideKeyBoard;
@property (nonatomic, strong)     TTAcountFLoginDelegate       *loginDelegate;

- (instancetype)initWithView:(FHLoginView *)tableView controller:(FHLoginViewController *)viewController;

- (void)viewWillAppear;

- (void)viewWillDisappear;

@end

NS_ASSUME_NONNULL_END
