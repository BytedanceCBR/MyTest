//
//  TSVActivityBannerCollectionViewCell.h
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import <UIKit/UIKit.h>
#import "TSVActivityBannerCollectionViewCellViewModel.h"
#import <ExploreOrderedData.h>

@interface TSVActivityBannerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TSVActivityBannerCollectionViewCellViewModel *viewModel;
@property (nonatomic, strong) ExploreOrderedData *cellData;

@end
