//
//  FHHouseTitleAndTagViewModel.h
//  FHHouseList
//
//  Created by bytedance on 2020/11/11.
//

#import "FHHouseNewComponentViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseTagViewModel;
@class FHSearchHouseItemModel;
@interface FHHouseTitleAndTagViewModel : FHHouseNewComponentViewModel

@property (nonatomic, copy, readonly) NSAttributedString *attributedTitle;
@property (nonatomic, copy, readonly) NSArray<FHHouseTagViewModel *> *tags;
@property (nonatomic, assign) CGFloat maxWidth;

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model;

- (UIFont *)titleFont;

@end

NS_ASSUME_NONNULL_END
