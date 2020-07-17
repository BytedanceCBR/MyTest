//
//  FHHouseRealtorDetailVM.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import <Foundation/Foundation.h>
#import <FHUGCShareManager.h>

@class FHHouseRealtorDetailVC;
@class FHHouseRealtorDetailHeaderView;
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailVM : NSObject
@property (nonatomic , strong) NSMutableDictionary *tracerDict;
@property (nonatomic, copy)     NSDictionary       *shareTracerDict;// 分享埋点数据

- (instancetype)initWithController:(FHHouseRealtorDetailVC *)viewController tracerDict:(NSDictionary*)tracerDict realtorInfo:(NSDictionary *)realtorInfo;

- (void)requestDataWithRealtorId:(NSString *)realtorId refreshFeed:(BOOL)refreshFeed;

- (void)viewWillAppear;

- (void)viewDidAppear;

- (void)viewWillDisappear;

- (void)addGoDetailLog;

- (void)addStayPageLog:(NSTimeInterval)stayTime;


- (void)updateNavBarWithAlpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
