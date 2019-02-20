//
//  FHDetailBaseCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHUserTracker.h"
#import "FHHouseTypeManager.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

// 子Cell的命名规则，FHDetailXXXCell，比如FHDetailOldMapViewCell
@interface FHDetailBaseCell : UITableViewCell

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;

// 当前方法不需重写
+ (Class)cellViewClass;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;

// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

// element_show 的时候:element_type，返回为空不上报，houseType为了区分同一个cell复用的情况
- (NSString *)elementTypeString:(FHHouseType)houseType;

// 详情页baseViewModel，可以从中拿到需要的数据(高效但是不美观)
@property (nonatomic, weak)     FHHouseDetailBaseViewModel       *baseViewModel;

@end

// FHDetailBaseCollectionCell
@interface FHDetailBaseCollectionCell : UICollectionViewCell

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;

// 当前方法不需重写
+ (Class)cellViewClass;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;

// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

@end

// FHDetailScrollViewDidScrollProtocol-详情页滑动时 house_show 埋点问题解决
@protocol FHDetailScrollViewDidScrollProtocol <NSObject>

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView;

@end

NS_ASSUME_NONNULL_END
