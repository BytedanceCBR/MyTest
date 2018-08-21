//
//  TSVRecUserCardCollectionViewCell.h
//  Article
//
//  Created by 王双华 on 2017/9/26.
//

#import <UIKit/UIKit.h>
#import "TSVRecUserCardCollectionViewCellViewModel.h"
#import "TSVWaterfallCollectionViewCellProtocol.h"

@interface TSVRecUserCardCollectionViewCell : UICollectionViewCell<TSVWaterfallCollectionViewCellProtocol>

@property (nonatomic, strong) TSVRecUserCardCollectionViewCellViewModel *viewModel;
- (void)willDisplay;
- (void)didEndDisplaying;

@end
