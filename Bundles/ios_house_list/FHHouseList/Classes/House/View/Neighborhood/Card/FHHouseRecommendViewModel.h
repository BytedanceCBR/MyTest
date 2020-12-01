//
//  FHHouseRecommendViewModel.h
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseNewComponentViewModel.h"
#import "FHSearchHouseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRecommendViewModel : FHHouseNewComponentViewModel

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *url;

- (instancetype)initWithModel:(FHHouseListHouseAdvantageTagModel *)model;

- (CGFloat)showHeight;

- (CGFloat)showSecondHouseHeight;

- (CGFloat)showNewHouseHeight;

- (BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
