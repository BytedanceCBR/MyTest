//
//  FHHouseRecommendReasonView.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/3/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHSearchHouseDataItemsRecommendReasonsModel;
@interface FHHouseRecommendReasonView : UIView

-(void)setReasons:(NSArray <FHSearchHouseDataItemsRecommendReasonsModel *> *)reasons;

@end

NS_ASSUME_NONNULL_END
