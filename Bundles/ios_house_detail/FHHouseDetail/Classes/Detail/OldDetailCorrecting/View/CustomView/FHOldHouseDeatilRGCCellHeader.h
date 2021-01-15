//
//  FHOldHouseDeatilRGCCellHeader.h
//  FHHouseDetail
//
//  Created by wangxinyu on 2021/1/10.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHOldHouseDeatilRGCCellHeader : UIView
- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel;
- (void)hiddenConnectBtn:(BOOL)hidden;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic, copy) void (^imClick)(void);
@property(nonatomic, copy) void (^headerClick)(void);
@property(nonatomic, copy) void (^phoneCilck)(void);
@property(nonatomic, copy) void (^headerLicenseBlock)(void);
@end

NS_ASSUME_NONNULL_END
