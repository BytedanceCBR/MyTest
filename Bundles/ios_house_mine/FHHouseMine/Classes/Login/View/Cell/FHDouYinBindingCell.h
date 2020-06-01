//
//  FHDouYinBindingCell.h
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^FHDouYinBinding)(UISwitch *);
@interface FHDouYinBindingCell : UITableViewCell
@property (nonatomic, strong) UISwitch *switchButton;

@property(nonatomic, copy) FHDouYinBinding douYinBinding;

@end

NS_ASSUME_NONNULL_END
