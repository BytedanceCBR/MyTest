//
//  FHPersonalHomePageHeaderView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import <UIKit/UIKit.h>
#import "FHPersonalHomePageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageHeaderView : UIView

- (void)updateData:(FHPersonalHomePageModel *)model tracerDic:(NSDictionary *)tracerDic;

@end

NS_ASSUME_NONNULL_END
