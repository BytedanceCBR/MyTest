//
//  FHNewHouseDetailViewController.h
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHBaseViewController.h"
#import "FHNewHouseDetailViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailViewController : FHBaseViewController

//是否显示拨打电话
@property (nonatomic, assign) BOOL isPhoneCallShow;
//正在拨打电话的经纪人id
@property (nonatomic, copy, nullable) NSString *phoneCallRealtorId;
//正在拨打电话对应请求虚拟电话的请求ID
@property (nonatomic, copy, nullable) NSString *phoneCallRequestId;
//ViewModel
@property (nonatomic, strong) FHNewHouseDetailViewModel *viewModel;
//bizTrace
@property (nonatomic, copy) NSString *bizTrace;

//是否显示
@property (nonatomic, assign) BOOL isViewDidDisapper;

- (void)updateLayout:(BOOL)isInstant;

@end

NS_ASSUME_NONNULL_END
