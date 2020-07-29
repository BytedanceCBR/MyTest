//
//  FHHouseRealtorDetailVM.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import <Foundation/Foundation.h>
#import <FHUGCShareManager.h>
#import "FHRealtorDetailBottomBar.h"

@class FHHouseRealtorDetailVC;
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailVM : NSObject
@property (nonatomic , strong) NSMutableDictionary *tracerDict;
- (instancetype)initWithController:(FHHouseRealtorDetailVC *)viewController tracerDict:(NSDictionary*)tracerDict realtorInfo:(NSDictionary *)realtorInfo bottomBar:(FHRealtorDetailBottomBar *)bottomBar;
- (void)requestDataWithRealtorId:(NSString *)realtorId refreshFeed:(BOOL)refreshFeed;
- (void)addGoDetailLog;
- (void)updateNavBarWithAlpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
