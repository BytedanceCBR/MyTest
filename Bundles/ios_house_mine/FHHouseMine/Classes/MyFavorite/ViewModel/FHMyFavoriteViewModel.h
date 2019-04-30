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

#define kCellId @"cell_id"
#define kFHFavoriteListPlaceholderCellId @"FHFavoriteListPlaceholderCellId"
@interface FHMyFavoriteViewModel : NSObject

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) NSMutableArray *removedDataList;

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMyFavoriteViewController *)viewController type:(FHHouseType)type;

- (void)requestData:(BOOL)isHead;

- (void)addStayCategoryLog:(NSTimeInterval)stayTime;

-(void)bindTableView:(UITableView*)tableView;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)registerCell:(UITableView*)tableView;
@end

NS_ASSUME_NONNULL_END
