//
//  FHHouseRealtorDetailHouseViewModel.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import <Foundation/Foundation.h>
#import "FHHouseRealtorDetailHouseVC.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailHouseViewModel : NSObject
@property (assign, nonatomic) BOOL isRequest;
- (instancetype)initWithController:(FHHouseRealtorDetailHouseVC *)viewController tableView:(UITableView *)tableView realtorInfo:(NSDictionary *)realtorInfo tracerDic:(NSDictionary *)tracerDic;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;
@end

NS_ASSUME_NONNULL_END
