//
//  FHNeighborhoodDetailViewController.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/9.
//

#import "FHBaseViewController.h"
#import "FHNeighborhoodDetailViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@class FHNeighborhoodDetailViewModel;
@class FHNeighborhoodDetailSectionModel;
@interface FHNeighborhoodDetailViewController : FHBaseViewController
//是否显示拨打电话
@property (nonatomic, assign) BOOL isPhoneCallShow;
//正在拨打电话的经纪人id
@property (nonatomic, copy, nullable) NSString *phoneCallRealtorId;
//正在拨打电话对应请求虚拟电话的请求ID
@property (nonatomic, copy, nullable) NSString *phoneCallRequestId;
//ViewModel
@property (nonatomic, strong) FHNeighborhoodDetailViewModel *viewModel;
//bizTrace
@property (nonatomic, copy) NSString *bizTrace;

//是否显示
@property (nonatomic, assign) BOOL isViewDidDisapper;

@property (nonatomic, strong) NSMutableDictionary *elementShowCaches;

- (void)updateLayout:(BOOL)isInstant;

- (void)refreshSectionModel:(FHNeighborhoodDetailSectionModel *)sectionModel animated:(BOOL )animated;

@end

NS_ASSUME_NONNULL_END
