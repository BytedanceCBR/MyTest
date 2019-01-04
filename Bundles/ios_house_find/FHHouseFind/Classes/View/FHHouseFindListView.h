//
//  FHHouseFindListView.h
//  Pods
//
//  Created by 张静 on 2019/1/2.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindListView : UIView

- (void)updateDataWithHouseType:(FHHouseType)houseType openUrl:(NSString *)openUrl;

@end

NS_ASSUME_NONNULL_END
