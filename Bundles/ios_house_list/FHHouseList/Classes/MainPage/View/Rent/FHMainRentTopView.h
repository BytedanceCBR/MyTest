//
//  FHMainRentTopView.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import <UIKit/UIKit.h>
#import <FHHouseBase/FHConfigModel.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHMainRentTopViewDelegate;
@interface FHMainRentTopView : UIView

@property(nonatomic , strong) NSArray<FHConfigDataRentOpDataItemsModel *> *items;
@property(nonatomic , strong) NSString *bannerUrl;
@property(nonatomic , weak)   id<FHMainRentTopViewDelegate> delegate;

+(CGFloat)bannerHeight:(FHConfigDataRentBannerModel *)rentBannerModel;

-(instancetype)initWithFrame:(CGRect)frame banner:(FHConfigDataRentBannerModel *)rentBanner;

@end

@protocol FHMainRentTopViewDelegate <NSObject>

-(void)selecteRentItem:(FHConfigDataRentOpDataItemsModel *)item;

-(void)tapRentBanner;

@end

NS_ASSUME_NONNULL_END
