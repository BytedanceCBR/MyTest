//
//  FHHomeMainViewModel.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import <Foundation/Foundation.h>

#define kFHHomeMainCellTypeHouse 0
#define kFHHomeMainCellTypeFeed 1

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainViewModel : NSObject

@property(nonatomic , assign) NSInteger currentIndex;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
