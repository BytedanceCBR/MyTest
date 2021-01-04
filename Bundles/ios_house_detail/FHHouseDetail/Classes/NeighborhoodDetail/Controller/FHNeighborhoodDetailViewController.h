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

//ViewModel
@property (nonatomic, strong) FHNeighborhoodDetailViewModel *viewModel;
//bizTrace
@property (nonatomic, copy) NSString *bizTrace;

@property (nonatomic, strong) NSMutableDictionary *elementShowCaches;

- (void)updateLayout;

- (void)hiddenPlaceHolder;

@end

NS_ASSUME_NONNULL_END
