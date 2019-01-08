//
//  FHCitySearchItemCell.h
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCitySearchItemCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *cityNameLabel;
@property (nonatomic, strong)   UILabel       *descLabel;
@property (nonatomic, assign)   BOOL       enabled;

@end

NS_ASSUME_NONNULL_END
