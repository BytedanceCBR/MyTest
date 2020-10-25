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

//是否显示
@property (nonatomic, assign) BOOL isViewDidDisapper;

@property (nonatomic, strong) NSMutableDictionary *elementShowCaches;

- (void)updateLayout:(BOOL)isInstant;

- (void)refreshSectionModel:(FHNewHouseDetailSectionModel *)sectionModel animated:(BOOL )animated;

@end

NS_ASSUME_NONNULL_END
