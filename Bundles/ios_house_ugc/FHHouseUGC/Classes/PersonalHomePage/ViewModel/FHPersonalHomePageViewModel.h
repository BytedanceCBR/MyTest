//
//  FHPersonalHomePageViewModel.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import <Foundation/Foundation.h>
#import "FHPersonalHomePageViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageViewModel : NSObject
@property (nonatomic,strong) NSString *userId;
-(instancetype)initWithController:(FHPersonalHomePageViewController *)viewController;
- (void)startLoadData;
@end

NS_ASSUME_NONNULL_END
