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

@optional
//曝光
- (void)cellWillShowAtIndexPath:(NSIndexPath *)indexPath;

//结束曝光
- (void)cellDidEndShowAtIndexPath:(NSIndexPath *)indexPath;

//点击
- (void)cellDidClickAtIndexPath:(NSIndexPath *)indexPath;

//回到前台
- (void)cellWillEnterForground;

//进入后台
- (void)cellDidEnterBackground;

@end

@interface FHHouseCardTableViewCell : UITableViewCell<FHHouseCardTableViewCellProtocol>

@end

NS_ASSUME_NONNULL_END
