//
//  FHCityListCell.h
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCityItemCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *cityNameLabel;
@property (nonatomic, strong)   UILabel       *descLabel;

@end

@interface FHCityHotItemCell : UITableViewCell

@property (nonatomic, strong , nullable) NSArray *cityList; // 城市名称数组

@end

@interface FHCityItemHeaderView : UIView

@property (nonatomic, strong)   UILabel       *label;

@end

@interface FHCityHotItemButton : UIControl

@property (nonatomic, strong)   UILabel       *label;

@end

NS_ASSUME_NONNULL_END
