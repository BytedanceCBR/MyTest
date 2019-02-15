//
//  FHHouseFindMainCell.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHHouseFindMainCellDelegate;
@interface FHHouseFindMainCell : UICollectionViewCell

@property(nonatomic , strong) UICollectionView *collectionView;

@property(nonatomic , weak) id<FHHouseFindMainCellDelegate> delegate;

-(void)showErrorView:(BOOL)showError;

@end

@protocol FHHouseFindMainCellDelegate <NSObject>

-(void)refreshInErrorView:(FHHouseFindMainCell *)cell;

@end

NS_ASSUME_NONNULL_END
