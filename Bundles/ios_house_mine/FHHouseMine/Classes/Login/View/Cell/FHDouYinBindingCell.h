//
//  FHDouYinBindingCell.h
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import <UIKit/UIKit.h>
#import "FHAccountBindingViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol  FHDouYinBindingCellDelegate<NSObject>

- (BOOL)hasDouYinAccount;
- (BOOL)transformDouYinAccount:(BOOL)isOn;

@end

@interface FHDouYinBindingCell : UITableViewCell

@property(nonatomic, weak)FHAccountBindingViewModel *viewModel;
@property(nonatomic, weak) id<FHDouYinBindingCellDelegate> delegate;
- (void)refreshSwitch;
@end

NS_ASSUME_NONNULL_END
