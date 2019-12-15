//
//  FHMainOldTopView.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHConfigDataOpDataItemsModel,FHConfigDataModel,FHConfigDataRentOpDataItemsModel;
@protocol FHMainOldTopViewDelegate;



@interface FHMainOldTopView : UIView

@property(nonatomic , weak) id<FHMainOldTopViewDelegate> delegate;
- (void)updateWithConfigData:(FHConfigDataModel *)configModel;
+ (BOOL)showBanner;

+ (CGFloat)bannerHeight;
+ (CGFloat)entranceHeight;
+ (CGFloat)totalHeight;


@end

@protocol FHMainOldTopViewDelegate <NSObject>

-(void)selecteOldItem:(FHConfigDataOpDataItemsModel *)item;
-(void)clickBannerItem:(FHConfigDataRentOpDataItemsModel *)item withIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
