//
//  FHMineViewModel.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import <Foundation/Foundation.h>
#import "FHMineViewController.h"
#import "FHMineDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMineViewModel : NSObject

@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, assign) BOOL isShowLogIn;

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMineViewController *)viewController;

- (void)requestData;

- (void)showInfo;

- (void)updateHeaderView;

- (void)goToSystemSetting;

- (void)callPhone;

- (void)requestMineConfig;

- (void)updateFocusTitles;

@end

NS_ASSUME_NONNULL_END
