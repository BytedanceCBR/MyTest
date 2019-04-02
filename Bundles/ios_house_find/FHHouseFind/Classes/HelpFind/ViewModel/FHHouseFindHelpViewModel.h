//
//  FHHouseFindHelpViewModel.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "FHHouseFindRecommendModel.h"

NS_ASSUME_NONNULL_BEGIN


@class FHBaseViewController;
@interface FHHouseFindHelpViewModel : NSObject

//屏蔽TTNavigationViewController带来的键盘变化
@property(nonatomic , assign) BOOL isHideKeyBoard;
@property(nonatomic , copy) void (^showNoDataBlock)(BOOL noData,BOOL isAvaiable);
@property(nonatomic, weak) FHBaseViewController *viewController;
@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView recommendModel:(FHHouseFindRecommendDataModel *)recommendModel;

@end

NS_ASSUME_NONNULL_END
