//
//  FHMyFavoriteViewModel.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/15.
//

#import <Foundation/Foundation.h>
#import "FHMyFavoriteViewController.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMyFavoriteViewModel : NSObject

@property(nonatomic, strong) NSMutableArray *dataList;

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMyFavoriteViewController *)viewController type:(FHHouseType)type;

- (void)requestData:(BOOL)isHead;

- (void)addStayCategoryLog:(NSTimeInterval)stayTime;

@end

NS_ASSUME_NONNULL_END
