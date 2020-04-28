//
//  FHDouYinBindingCell.h
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import <UIKit/UIKit.h>
#import "FHAccountBindingViewModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^FHDouYinBinding)(UISwitch *);
typedef void(^FHDouYinUnbinding)(UISwitch *);
@interface FHDouYinBindingCell : UITableViewCell
@property (nonatomic, strong) UISwitch *switchButton;

@property(nonatomic, copy) FHDouYinBinding DouYinBinding;
@property(nonatomic, copy) FHDouYinUnbinding DouYinUnbinding;

@end

NS_ASSUME_NONNULL_END
