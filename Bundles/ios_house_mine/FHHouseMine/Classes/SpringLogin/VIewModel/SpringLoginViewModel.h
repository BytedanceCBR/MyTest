//
//  SpringLoginViewModel.h
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/12/16.
//

//#import <Foundation/Foundation.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface SpringLoginViewModel : NSObject
//
//@end
//
//NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>
#import "SpringLoginViewController.h"
#import "SpringLoginView.h"
#import "TTAccountLoginManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpringLoginViewModel : NSObject

//屏蔽TTNavigationViewController带来的键盘变化
@property(nonatomic, assign) BOOL isHideKeyBoard;
@property(nonatomic, strong) TTAcountFLoginDelegate *loginDelegate;
@property(nonatomic, assign) BOOL needPopVC;
@property(nonatomic, assign) BOOL noDismissVC;
@property(nonatomic, assign) BOOL present;
@property (nonatomic, assign)   BOOL  isNeedCheckUGCAdUser;

- (instancetype)initWithView:(SpringLoginView *)view controller:(SpringLoginViewController *)viewController;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)addEnterCategoryLog;

@end

NS_ASSUME_NONNULL_END
