//
//  FHHouseDeatilRGCCellHeader.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/15.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDeatilRGCCellHeader : UIView
- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel;
- (void)hiddenConnectBtn:(BOOL)hidden;
- (void)setupNewHouseStyle;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic, copy) void (^imClick)(void);
@property(nonatomic, copy) void (^headerClick)(void);
@property(nonatomic, copy) void (^phoneCilck)(void);
@property(nonatomic, copy) void (^headerLicenseBlock)(void);
@end

NS_ASSUME_NONNULL_END
