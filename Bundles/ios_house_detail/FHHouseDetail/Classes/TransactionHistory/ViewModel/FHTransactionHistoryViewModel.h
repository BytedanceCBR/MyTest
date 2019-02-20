//
//  FHTransactionHistoryViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/20.
//

#import <Foundation/Foundation.h>
#import "FHTransactionHistoryController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHTransactionHistoryViewModel : NSObject

@property(nonatomic, strong) NSMutableArray *dataList;

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHTransactionHistoryController *)viewController neighborhoodId:(NSString *)neighborhoodId;

- (void)requestData:(BOOL)isHead;

- (void)addStayCategoryLog:(NSTimeInterval)stayTime;

@end

NS_ASSUME_NONNULL_END
