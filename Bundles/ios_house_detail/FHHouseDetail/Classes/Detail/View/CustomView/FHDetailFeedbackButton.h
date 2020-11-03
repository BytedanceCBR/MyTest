//
//  FHDetailFeedbackButton.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/9.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN
@class FHDetailOldDataModel;
@interface FHDetailFeedbackButton : UIButton
//埋点需要
- (void)updateWithDetailTracerDic:(NSDictionary *)detailTracerDic listLogPB:(NSDictionary *)listLogPB houseData:(FHDetailOldDataModel *)houseData houseType:(FHHouseType)type reportUrl:(NSString *)reportUrl;

@end

NS_ASSUME_NONNULL_END
