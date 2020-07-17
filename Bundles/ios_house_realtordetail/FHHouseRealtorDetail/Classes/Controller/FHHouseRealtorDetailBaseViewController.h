//
//  FHHouseRealtorDetailBaseViewController.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailBaseViewController : FHBaseViewController
@property (strong, nonatomic)UITableView *tableView;
//圈子详情页使用
//空态页具体顶部offset
@property (nonatomic, assign) CGFloat errorViewTopOffset;
@property (nonatomic, assign) CGFloat errorViewHeight;
@property (strong, nonatomic) NSDictionary *realtorInfo;
@property (copy, nonatomic) NSString *tabName;
@end

NS_ASSUME_NONNULL_END
