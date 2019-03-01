//
//  FHMessageListViewController.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageListViewController : FHBaseViewController

- (NSDictionary *)categoryLogDict;

- (NSString *)categoryName;

- (NSString *)originFrom;

@end

NS_ASSUME_NONNULL_END
