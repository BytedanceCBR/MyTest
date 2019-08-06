//
//  FHDetectiveItemView.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/7/2.
//

#import <UIKit/UIKit.h>
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel;

@interface FHDetectiveItemView : UIView

@property(nonatomic , copy) void(^actionBlock)(id reasonInfoData);

- (void)updateWithModel:(FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel *)model;
- (void)showBottomLine:(BOOL)isShow;
+ (CGFloat)heightForTile:(NSString *)title tip:(NSString *)tip;
@end

NS_ASSUME_NONNULL_END
