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

NS_ASSUME_NONNULL_BEGIN

// 子Cell的命名规则，FHDetailXXXCell，比如FHDetailOldMapViewCell
@interface FHDetailBaseCell : UITableViewCell

// 当前方法不需重写
+ (Class)cellViewClass;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;

@end

NS_ASSUME_NONNULL_END
