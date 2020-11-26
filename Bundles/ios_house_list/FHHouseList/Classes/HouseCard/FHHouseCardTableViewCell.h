//
//  FHHouseCardTableViewCell.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import <UIKit/UIKit.h>
#import "FHHouseNewComponentView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseCardTableViewCellProtocol <FHHouseNewComponentViewProtocol>

//曝光
- (void)cellWillShowAtIndexPath:(NSIndexPath *)indexPath;

//点击
- (void)cellDidClickAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FHHouseCardTableViewCell : UITableViewCell<FHHouseCardTableViewCellProtocol>

@end

NS_ASSUME_NONNULL_END
