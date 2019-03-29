//
//  FHPriceValuationResultView.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import <UIKit/UIKit.h>
#import "FHPriceValuationEvaluateModel.h"
#import "FHPriceValuationHistoryModel.h"
#import "FHDetailNeighborhoodModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHPriceValuationResultViewDelegate <NSObject>

- (void)moreInfo;

- (void)goToNeiborhoodDetail;

- (void)evaluate:(NSInteger)type desc:(NSString *)desc;

- (void)houseSale;

- (void)goToCityMarket;

@end

@interface FHPriceValuationResultView : UIView

@property(nonatomic , weak) id<FHPriceValuationResultViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight;

- (void)updateView:(FHPriceValuationEvaluateModel *)model infoModel:(FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *)infoModel;

- (void)updateChart:(FHDetailNeighborhoodModel *)detailModel;

- (void)hideEvaluateView;

@end

NS_ASSUME_NONNULL_END
