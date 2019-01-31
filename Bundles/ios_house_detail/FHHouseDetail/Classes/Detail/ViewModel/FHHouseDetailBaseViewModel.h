//
//  FHHouseDetailBaseViewModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>
#import "FHHouseDetailViewController.h"
#import "ToastManager.h"
#import "FHUserTracker.h"
#import "FHHouseTypeManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailBaseViewModel : NSObject

+(instancetype)createDetailViewModelWithHouseType:(FHHouseType)houseType withController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView;
-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView houseType:(FHHouseType)houseType;
@property (nonatomic, assign)   FHHouseType houseType; // 房源类型
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseDetailViewController *detailController;
@property (nonatomic, strong) NSMutableArray *items;// 子类维护的数据源

// 子类实现
- (void)registerCellClasses;
- (Class)cellClassForEntity:(id)model;
- (NSString *)cellIdentifierForEntity:(id)model;
- (void)startLoadData;

// 刷新数据
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
