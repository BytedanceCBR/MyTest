//
//  FHDetailFeedbackButton.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailFeedbackButton : UIButton
//埋点需要
- (void)updateWithDetailTracerDic:(NSDictionary *)detailTracerDic listLogPB:(NSDictionary *)listLogPB jsonDic:(NSDictionary *)jsonDic reportUrl:(NSString *)reportUrl;

@end

NS_ASSUME_NONNULL_END
