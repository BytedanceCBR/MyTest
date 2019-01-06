//
//  FHHouseFindBaseView.h
//  Pods
//
//  Created by 张静 on 2019/1/2.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseFindSectionItem;

@interface FHHouseFindBaseView : UIView

@property(nonatomic , copy) void (^changeHouseTypeBlock)(FHHouseType houseType);

- (void)updateDataWithItem: (FHHouseFindSectionItem *)item needRefresh: (BOOL)needRefresh;

@end

NS_ASSUME_NONNULL_END
