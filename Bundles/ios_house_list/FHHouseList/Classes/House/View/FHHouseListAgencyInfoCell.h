//
//  FHHouseListAgencyInfoCell.h
//  FHHouseList
//
//  Created by 张静 on 2019/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListAgencyInfoCell : UITableViewCell

@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UIButton *allWebHouseBtn;
@property(nonatomic, copy)void (^btnClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
