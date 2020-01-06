//
//  FHHomeScrollBannerCell.h
//  FHHouseHome
//
//  Created by 张元科 on 2019/4/2.
//

#import <UIKit/UIKit.h>
#import "FHHomeBaseTableCell.h"
#import <FHHomeBannerView.h>
#import "FHConfigModel.h"

NS_ASSUME_NONNULL_BEGIN
@class FHHomeScrollBannerView;
// 首页轮播banner
@interface FHHomeScrollBannerCell : FHHomeBaseTableCell

@property (nonatomic, strong)   FHHomeScrollBannerView       *bannerView;
+ (CGFloat)cellHeight;
-(void)updateWithModel:(FHConfigDataMainPageBannerOpDataModel *)model;
+ (BOOL)hasValidModel:(FHConfigDataMainPageBannerOpDataModel *)mainPageOpData;
+ (BOOL)isValidModel:(FHConfigDataRentOpDataItemsModel *)tModel;
@end



NS_ASSUME_NONNULL_END
