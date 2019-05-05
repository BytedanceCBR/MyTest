//
//  FHHouseAgencyListViewModel.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/5.
//

#import "FHHouseAgencyListViewModel.h"
#import "FHHouseAgencyItemTableViewCell.h"
#import <FHHouseBase/FHHouseAgencyListSugDelegate.h>
#import <FHHouseBase/FHFillFormAgencyListItemModel.h>

@interface FHHouseAgencyListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong , nullable) NSArray<FHFillFormAgencyListItemModel *> *agencyList;
@property(nonatomic, strong) TTRouteParamObj *paramObj;
@property (nonatomic, weak) id<FHHouseAgencyListSugDelegate>    delegate;

@end

@implementation FHHouseAgencyListViewModel

- (instancetype)initWithTableView:(UITableView *)tableView paramObj:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        _tableView = tableView;
        _paramObj = paramObj;
        NSHashTable<FHHouseAgencyListSugDelegate> *temp_delegate = paramObj.allParams[@"delegate"];
        self.delegate = temp_delegate.anyObject;
        if ([paramObj.allParams[@"choose_agency_list"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *mutable = @[].mutableCopy;
            NSArray<FHFillFormAgencyListItemModel *> *agencyList = paramObj.allParams[@"choose_agency_list"];
            for (FHFillFormAgencyListItemModel *item in agencyList) {
                FHFillFormAgencyListItemModel *itemModel = [item copy];
                [mutable addObject:itemModel];
            }
            self.agencyList = mutable;
        }
        tableView.delegate  = self;
        tableView.dataSource = self;
        [tableView registerClass:[FHHouseAgencyItemTableViewCell class] forCellReuseIdentifier:@"FHHouseAgencyItemTableViewCell"];
        if (@available(iOS 11.0 , *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        tableView.estimatedRowHeight = 50;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
    }
    return self;
}

- (void)confirmAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(agencySelected:)]) {
        [self.delegate agencySelected:self.agencyList];
        [self.viewController.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.agencyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.agencyList.count) {
        FHHouseAgencyItemTableViewCell *cell = (FHHouseAgencyItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FHHouseAgencyItemTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        FHFillFormAgencyListItemModel *model  = self.agencyList[indexPath.row];
        cell.titleLabel.text = model.agencyName;
        cell.selectIcon.image = model.checked ? [UIImage imageNamed:@"detail_circle_selected"] : [UIImage imageNamed:@"detail_circle_normal"];
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.agencyList.count) {
        FHFillFormAgencyListItemModel *model  = self.agencyList[indexPath.row];
        model.checked = !model.checked;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
@end
