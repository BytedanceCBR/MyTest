//
//  TSVRecUserSinglePersonCollectionViewCell.h
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import <UIKit/UIKit.h>
#import "TSVRecUserSinglePersonCollectionViewCellViewModel.h"

typedef void(^TSVSinglePersonCellHandleFollowBtnTapBlock)();

@interface TSVRecUserSinglePersonCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TSVRecUserSinglePersonCollectionViewCellViewModel *viewModel;
@property (nonatomic, copy) TSVSinglePersonCellHandleFollowBtnTapBlock handleFollowBtnTapBlock;

@end
