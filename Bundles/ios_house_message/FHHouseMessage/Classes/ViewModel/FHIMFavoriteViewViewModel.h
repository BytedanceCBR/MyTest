//
//  FHIMFavoriteViewViewModel.h
//  FHHouseMessage
//
//  Created by liuyu on 2020/3/17.
//

#import <Foundation/Foundation.h>
#import "FHMyFavoriteViewController.h"
#import "FHHouseType.h"
#import "IFHMyFavoriteController.h"

NS_ASSUME_NONNULL_BEGIN

#define kCellId @"cell_id"

@interface FHIMFavoriteViewViewModel : NSObject

@property(nonatomic, weak) id<IFHMyFavoriteController> viewController;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) NSMutableArray *removedDataList;
@property(nonatomic, assign) BOOL isDisplay;

- (instancetype)initWithTableView:(UITableView *)tableView controller:(id<IFHMyFavoriteController>)viewController type:(FHHouseType)type;

- (void)requestData:(BOOL)isHead;

- (void)addStayCategoryLog:(NSTimeInterval)stayTime;

-(void)bindTableView:(UITableView*)tableView;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)registerCell:(UITableView*)tableView;

- (NSDictionary *)categoryLogDict;
- (NSString *)categoryName;
-(void)traceDisplayCell;

- (void)addEnterCategoryLog;
- (void)trackRefresh;

@end

NS_ASSUME_NONNULL_END
