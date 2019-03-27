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
@property(nonatomic , weak)   id<FHMainRentTopViewDelegate> delegate;

@end

@protocol FHMainRentTopViewDelegate <NSObject>

-(void)selecteRentItem:(FHConfigDataRentOpDataItemsModel *)item;

@end

NS_ASSUME_NONNULL_END
