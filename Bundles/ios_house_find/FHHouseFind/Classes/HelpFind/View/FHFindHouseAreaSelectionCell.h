//
//  FHFindHouseAreaSelectionCell.h
//  FHHouseFind
//
//  Created by wangxinyu on 2021/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFindHouseAreaSelectionCell : UITableViewCell

@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UIButton* checkboxBtn;
@property (nonatomic, strong) UIView* redDot;
- (void)showCheckbox:(BOOL)showCheckBox;
- (void)setCellSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
