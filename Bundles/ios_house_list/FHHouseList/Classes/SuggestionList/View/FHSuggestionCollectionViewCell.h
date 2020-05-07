//
//  FHSuggestionCollectionViewCell.h
//  FHHouseList
//
//  Created by xubinbin on 2020/4/17.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"
#import "FHChildSuggestionListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) FHChildSuggestionListViewController *vc;
@property(nonatomic, assign) FHHouseType houseType;

- (void)cellDisappear;
- (void)refreshData:(id)data andHouseType:(FHHouseType)houseType;
@end

NS_ASSUME_NONNULL_END
