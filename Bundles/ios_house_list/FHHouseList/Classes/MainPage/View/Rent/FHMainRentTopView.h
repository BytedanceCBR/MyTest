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

@property(nonatomic , strong) NSString *bannerUrl;
@property(nonatomic , weak)   id<FHMainRentTopViewDelegate> delegate;

+(CGFloat)bannerHeight:(FHConfigDataRentBannerModel *)rentBannerModel;

+(UIImage *)cacheImageForRentBanner:(FHConfigDataRentBannerModel *)rentBannerModel;

-(instancetype)initWithFrame:(CGRect)frame banner:(FHConfigDataRentBannerModel *)rentBanner;
- (void)updateWithConfigData:(FHConfigDataModel *)configModel;

+ (CGFloat)entranceHeight;
+ (CGFloat)totalHeight;
+ (BOOL)showEntrance;

@end

@protocol FHMainRentTopViewDelegate <NSObject>

-(void)selecteRentItem:(FHConfigDataOpDataItemsModel *)item;

-(void)tapRentBanner;

//-(void)rentBannerLoaded:(UIView *)bannerView;

@end

NS_ASSUME_NONNULL_END
