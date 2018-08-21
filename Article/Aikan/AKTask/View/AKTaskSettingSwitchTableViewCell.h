//
//  SKTaskSettingSwitchTableViewCell.h
//  Article
//
//  Created by chenjiesheng on 2018/3/1.
//

#import <UIKit/UIKit.h>

@class AKTaskSettingCellModel;
@interface AKTaskSettingSwitchTableViewCell : UITableViewCell

@property (nonatomic, copy)void(^switchButtonClickBlock)(AKTaskSettingCellModel * cellModel, UISwitch *swich);

- (void)setupContentWith:(AKTaskSettingCellModel *)cellModel;
@end
