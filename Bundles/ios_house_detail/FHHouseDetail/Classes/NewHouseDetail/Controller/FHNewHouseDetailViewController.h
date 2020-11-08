//
//  FHNewHouseDetailViewController.h
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHBaseViewController.h"
#import "FHNewHouseDetailViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHNewHouseDetailSectionModel;
@interface FHNewHouseDetailViewController : FHBaseViewController
//ViewModel
@property (nonatomic, strong) FHNewHouseDetailViewModel *viewModel;
//bizTrace
@property (nonatomic, copy) NSString *bizTrace;
/// 一个曝光埋点的通用缓存，用于FHNewHouseDetailSectionController中及其子类
/// key的命名，期望使用 classname+index的形式，越复杂越保证单一性
@property (nonatomic, strong) NSMutableDictionary *elementShowCaches;

@end

NS_ASSUME_NONNULL_END
