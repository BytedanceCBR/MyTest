//
//  FHHouseRecommendViewModel.h
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseNewComponentView.h"

NS_ASSUME_NONNULL_BEGIN

@class FHSearchHouseItemModel;
@interface FHHouseRecommendViewModel : FHHouseNewComponentView

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *url;

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model;

- (CGFloat)showHeight;

- (BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
