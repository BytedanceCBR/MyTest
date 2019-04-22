//
//  TSVActivityEntranceCollectionViewCell.h
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import <UIKit/UIKit.h>
#import "TSVActivityEntranceCollectionViewCellViewModel.h"
#import <ExploreOrderedData.h>

@interface TSVActivityEntranceCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TSVActivityEntranceCollectionViewCellViewModel *viewModel;
@property (nonatomic, strong) ExploreOrderedData *cellData;

@end
