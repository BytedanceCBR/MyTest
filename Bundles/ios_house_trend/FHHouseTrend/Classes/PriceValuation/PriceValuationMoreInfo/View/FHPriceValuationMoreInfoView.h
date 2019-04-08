//
//  FHPriceValuationMoreInfoView.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/27.
//

#import <UIKit/UIKit.h>
#import "FHPriceValuationItemView.h"
#import "FHPriceValuationHistoryModel.h"
#import "FHPriceValuationSelectionView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHPriceValuationMoreInfoViewDelegate <NSObject>

- (void)confirm;

- (void)chooseBuildYear;

- (void)chooseOrientations;

- (void)chooseFloor;

- (void)selectBuildType:(NSString *)type;

- (void)selectDecorateType:(NSString *)type;

@end

@interface FHPriceValuationMoreInfoView : UIView

@property(nonatomic, strong) FHPriceValuationItemView *buildYearItemView;
@property(nonatomic, strong) FHPriceValuationItemView *orientationsItemView;
@property(nonatomic, strong) FHPriceValuationItemView *floorItemView;
@property(nonatomic, strong) FHPriceValuationSelectionView *buildTypeView;
@property(nonatomic, strong) UILabel *buildTypeLabel;
@property(nonatomic, strong) UILabel *decorateTypeLabel;
@property(nonatomic , weak) id<FHPriceValuationMoreInfoViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight;
- (void)updateView:(FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *)infoModel;

- (NSString *)getOrientations:(NSString *)type;
- (NSString *)getBuildType:(NSString *)type;
- (NSString *)getDecorationType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
