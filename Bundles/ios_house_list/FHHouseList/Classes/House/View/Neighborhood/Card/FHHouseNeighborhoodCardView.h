//
//  FHHouseNeighborhoodCardView.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/9.
//

#import "FHHouseNewComponentView.h"
#import "FHHouseNeighborhoodCardViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseNeighborhoodCardView : FHHouseNewComponentView

- (void)refreshOpacityWithData:(id)viewModel;

@end

NS_ASSUME_NONNULL_END
