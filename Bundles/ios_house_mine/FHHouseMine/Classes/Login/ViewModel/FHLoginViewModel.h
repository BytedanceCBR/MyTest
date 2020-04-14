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
@property(nonatomic, assign) BOOL isHideKeyBoard;
@property(nonatomic, strong) TTAcountFLoginDelegate *loginDelegate;
@property(nonatomic, assign) BOOL needPopVC;
@property(nonatomic, assign) BOOL noDismissVC;
@property(nonatomic, assign) BOOL present;
@property (nonatomic, assign) BOOL fromOneKeyLogin;
@property (nonatomic, assign) BOOL fromOtherLogin;
@property (nonatomic, assign)   BOOL  isNeedCheckUGCAdUser;

- (instancetype)initWithView:(FHLoginView *)view controller:(FHLoginViewController *)viewController;


- (void)addEnterCategoryLog;

@end

NS_ASSUME_NONNULL_END
