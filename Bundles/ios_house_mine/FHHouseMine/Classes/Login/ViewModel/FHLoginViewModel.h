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
#import "FHLoginDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHLoginViewModel : NSObject<FHLoginViewDelegate>

- (instancetype)initWithController:(FHLoginViewController *)viewController;

@property (nonatomic, assign) FHLoginProcessType processType;

//屏蔽TTNavigationViewController带来的键盘变化
@property (nonatomic, assign) BOOL isHideKeyBoard;
@property (nonatomic, strong) TTAcountFLoginDelegate *loginDelegate;
@property (nonatomic, assign) BOOL needPopVC;
@property (nonatomic, assign) BOOL noDismissVC;
@property (nonatomic, assign) BOOL present;
@property (nonatomic, assign) BOOL isOneKeyLogin;
@property (nonatomic, assign) BOOL isOtherLogin;
@property (nonatomic, assign)   BOOL  isNeedCheckUGCAdUser;
@property (nonatomic , copy) NSString *mobileNumber;

@property (nonatomic, copy) void (^configureSubview)(FHLoginViewType type,NSDictionary *infoDict);

@property (nonatomic, copy) void (^updateTimeCountDownValue)(NSInteger secondsValue);


- (void)startLoadData;
- (void)addEnterCategoryLog;

@end

NS_ASSUME_NONNULL_END
