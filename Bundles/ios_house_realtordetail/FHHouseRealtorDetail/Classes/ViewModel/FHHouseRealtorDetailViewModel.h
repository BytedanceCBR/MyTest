//
//  FHHouseRealtorDetailViewModel.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/12.
//

#import <Foundation/Foundation.h>
#import "FHHouseRealtorDetailController.h"
#import "FHHouseRealtorDetailInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailViewModel : NSObject

@property (assign, nonatomic) BOOL isRequest;
@property (nonatomic, assign) CGFloat showHeaderViewHeight;

- (instancetype)initWithController:(FHHouseRealtorDetailController *)viewController tableView:(UITableView *)tableView realtorInfo:(NSDictionary *)realtorInfo tracerDic:(NSDictionary *)tracerDic;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;
@end

NS_ASSUME_NONNULL_END
