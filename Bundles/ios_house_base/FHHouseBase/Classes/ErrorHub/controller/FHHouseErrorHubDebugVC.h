//
//  FHHouseErrorHubDebugVC.h
//  FHHouseBase
//
//  Created by liuyu on 2020/4/16.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseErrorHubDebugVC : FHBaseViewController

@end

@interface FHHouseErrorHubCell : UITableViewCell
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *errorMessage;
@property (copy, nonatomic) NSString *currentTime;
@end

NS_ASSUME_NONNULL_END
