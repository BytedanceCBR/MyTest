//
//  FHMessageViewModel.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHMessageViewController;

@interface FHMessageViewModel : NSObject

@property(nonatomic, strong) NSMutableArray *dataList;

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageViewController *)viewController;

- (void)requestData;

-(void)addStayCategoryLog:(NSTimeInterval)stayTime;

@end

NS_ASSUME_NONNULL_END
