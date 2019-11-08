//
//  FHUGCVoteViewModel.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import "FHUGCVoteViewModel.h"
#import "FHUGCVotePublishViewController.h"
#import "FHUGCVotePublishModel.h"
#import "FHUGCVotePublishCell.h"
#import <FHCommonDefines.h>
#import "FHUGCScialGroupModel.h"
#import "FHCommunityList.h"


#define OPTION_START_INDEX  3

@interface FHUGCVoteViewModel() <UITableViewDelegate, UITableViewDataSource, FHUGCVotePublishBaseCellDelegate>
@property (nonatomic, strong) FHUGCVotePublishModel *model;
@property (nonatomic, weak  ) UITableView *tableView;
@property (nonatomic, weak  ) FHUGCVotePublishViewController *viewController;
@property (nonatomic, strong) UIView *addOptionFooterView;
@property (nonatomic, assign) BOOL isDatePickerHidden;
@property (nonatomic, assign) BOOL isVoteTypePickerHidden;
@end

@implementation FHUGCVoteViewModel

- (UIView *)addOptionFooterView {
    if(!_addOptionFooterView) {
        _addOptionFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        _addOptionFooterView.backgroundColor = [UIColor themeWhite];
        
        UIImageView *addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        addImageView.backgroundColor = [UIColor themeRed3];
        
        UILabel *addLabel = [UILabel new];
        addLabel.font = [UIFont themeFontMedium:18];
        addLabel.textColor = [UIColor themeBlue1];
        addLabel.text = @"添加选项";
        
        [_addOptionFooterView addSubview:addImageView];
        [_addOptionFooterView addSubview:addLabel];
        
        [addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(50);
            make.centerY.equalTo(_addOptionFooterView);
            make.left.equalTo(_addOptionFooterView).offset(20);
        }];
        
        [addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(addImageView);
            make.left.equalTo(addImageView.mas_right).offset(5);
            make.top.bottom.equalTo(_addOptionFooterView);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addOptionAction:)];
        
        [_addOptionFooterView addGestureRecognizer:tap];
    }
    return _addOptionFooterView;
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

-(instancetype)initWithTableView:(UITableView *)tableView ViewController:(FHUGCVotePublishViewController *)viewController {
    if(self = [super init]) {
        self.tableView = tableView;
        [self registerCells];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.viewController = viewController;
        self.model = [FHUGCVotePublishModel new];
        self.isDatePickerHidden = YES;
        self.isVoteTypePickerHidden = YES;
    }
    return self;
}

- (void)registerCells {
    
    [self.tableView registerClass:[FHUGCVotePublishCityCell class] forCellReuseIdentifier:[FHUGCVotePublishCityCell reusedIdentifier]];
    
    [self.tableView registerClass:[FHUGCVotePublishTitleCell class] forCellReuseIdentifier:[FHUGCVotePublishTitleCell reusedIdentifier]];
    
    [self.tableView registerClass:[FHUGCVotePublishDescriptionCell class] forCellReuseIdentifier:[FHUGCVotePublishDescriptionCell reusedIdentifier]];
    
    [self.tableView registerClass:[FHUGCVotePublishOptionCell class] forCellReuseIdentifier:[FHUGCVotePublishOptionCell reusedIdentifier]];
    
    [self.tableView registerClass:[FHUGCVotePublishVoteTypeCell class] forCellReuseIdentifier:[FHUGCVotePublishVoteTypeCell reusedIdentifier]];
    
    [self.tableView registerClass:[FHUGCVotePublishDatePickCell class] forCellReuseIdentifier:[FHUGCVotePublishDatePickCell reusedIdentifier]];
}

// MARK: UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            return self.isVoteTypePickerHidden ? CELL_HEIGHT : CELL_HEIGHT + VOTE_TYPE_PICKTER_VIEW_HEIGHT;
        }
        else if(indexPath.row == 1) {
            return self.isDatePickerHidden ? CELL_HEIGHT : CELL_HEIGHT + DATEPICKER_HEIGHT;
        }
    }
    return CELL_HEIGHT;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return CGFLOAT_MIN;
    } else {
        return 37;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 0) {
        return CELL_HEIGHT;
    } else {
        return CGFLOAT_MIN;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(section == 0) {
        return self.addOptionFooterView;
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            [self gotoCommunityListPage];
        } else if(indexPath.row == 1) {
            
        } else if(indexPath.row == 2) {
            
        } else if(indexPath.row == 3) {
            
        } else {
            
        }
    }
    else if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            FHUGCVotePublishVoteTypeCell *voteTypeCell = [tableView cellForRowAtIndexPath:indexPath];
            [voteTypeCell toggleTypePicker];
        }
        else if(indexPath.row == 1) {
            FHUGCVotePublishDatePickCell *datePickerCell = [tableView cellForRowAtIndexPath:indexPath];
            [datePickerCell toggleDatePicker];
        }
        else {
            
        }
    }
    else {
        
    }
}

// MARK: UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return (
            1       // 可见范围Cell
            + 1     // 投票标题Cell
            + 1     // 投票描述Cell
            + self.model.options.count // 投票选项
        );
    }
    else if(section == 1) {
        return (
            1       // 投票类型Cell
            + 1     // 截止日期Cell
        );
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FHUGCVotePublishBaseCell *cell = nil;
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishCityCell reusedIdentifier] forIndexPath:indexPath];
            ((FHUGCVotePublishCityCell *)cell).cityLabel.text = self.model.cityInfo.socialGroupName;
        } else if(indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishTitleCell reusedIdentifier] forIndexPath:indexPath];
        } else if(indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishDescriptionCell reusedIdentifier] forIndexPath: indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishOptionCell reusedIdentifier] forIndexPath: indexPath];
        }
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishVoteTypeCell reusedIdentifier] forIndexPath:indexPath];
        } else if(indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishDatePickCell reusedIdentifier] forIndexPath:indexPath];
        } else {
            cell = [UITableViewCell new];
        }
    }
    cell.delegate = self;
    return cell;
}

// MARK: FHUGCVotePublishBaseCellDelegate

- (void)voteTitleCell:(FHUGCVotePublishTitleCell *)titleCell didInputText:(NSString *)text {
    self.model.voteTitle = text;
}

- (void)descriptionCell:(FHUGCVotePublishDescriptionCell *)descriptionCell didInputText:(NSString *)text {
    self.model.voteDescription = text;
}

- (void)optionCell:(FHUGCVotePublishOptionCell *)optionCell didInputText:(NSString *)text {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:optionCell];
    NSInteger optionStartIndex = OPTION_START_INDEX;
    NSUInteger index = MIN(MAX(indexPath.row - optionStartIndex, 0), self.model.options.count);
    if(index < self.model.options.count) {
        self.model.options[index] = text;
    }
}

- (void)voteTypeCell:(FHUGCVotePublishVoteTypeCell *)voteTypeCell toggleTypeStatus:(BOOL)isHidden {
    self.isVoteTypePickerHidden = isHidden;
    
    [self.tableView beginUpdates];
    [self reloadTableView];
    [self.tableView endUpdates];
}

- (void)voteTypeCell:(FHUGCVotePublishVoteTypeCell *)voteTypeCell didSelectedType:(VoteType)type {
    self.model.type = type;
}

- (void)datePickerCell:(FHUGCVotePublishDatePickCell *)datePickerCell didSelectedDate:(NSDate *)date {
    self.model.deadline = date;
}

- (void)deleteOptionCell:(id)optionCell {
    NSMutableArray *options = [NSMutableArray arrayWithArray:self.model.options];
    NSInteger optionStartIndex = OPTION_START_INDEX;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:optionCell];
    if(indexPath.row >= optionStartIndex) {
        NSUInteger index = MIN(MAX(indexPath.row - optionStartIndex, 0), options.count);
        [options removeObjectAtIndex:index];
        self.model.options = options;
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (void)datePickerCell:(FHUGCVotePublishDatePickCell *)datePickerCell toggleWithStatus:(BOOL)isHidden {
    
    self.isDatePickerHidden = isHidden;
    
    [self.tableView beginUpdates];
    [self reloadTableView];
    [self.tableView endUpdates];
}

// MARK: 函数
- (void)publish {
    
    NSString *socialGroupName = self.model.cityInfo.socialGroupName;
    NSString *socialGroupId = self.model.cityInfo.socialGroupId;
    NSString *voteTitle = self.model.voteTitle;
    NSString *voteDescription = self.model.voteDescription;
    NSArray *voteOptions = [NSArray arrayWithArray:self.model.options];
    VoteType voteType = self.model.type;
    NSDate *voteDate = self.model.deadline;
    
    // 有效投票
    if(voteTitle.length > 0 && voteOptions.count > 0) {

    }
    // 提示
    else {
        
    }
    // For Debug
    NSLog(@"\n voteCityName: %@, voteCityId: %@", self.model.cityInfo.socialGroupName, self.model.cityInfo.socialGroupId);
    NSLog(@"\n voteTitle: %@\n voteDescription: %@", self.model.voteTitle, self.model.voteDescription);
    [self.model.options enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"voteOption%@: %@", @(idx), obj);
    }];
    NSLog(@"\n vote Type: %@", @(self.model.type));
    NSLog(@"\n vote Deadlint: %@", self.model.deadline);
}

- (void)addOptionAction:(UITapGestureRecognizer *)tap {
    NSMutableArray *options = [NSMutableArray arrayWithArray:self.model.options];
    [options addObject:@""];
    
    self.model.options = options;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)gotoCommunityListPage {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"action_type"] = @(FHCommunityListTypeChoose);
    NSHashTable *chooseDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [chooseDelegateTable addObject:self];
    dict[@"choose_delegate"] = chooseDelegateTable;
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    dict[TRACER_KEY] = traceParam;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)selectedItem:(FHUGCScialGroupDataModel *)item {
    // 选择 小区圈子
    if (item) {
        self.model.cityInfo.socialGroupId = item.socialGroupId;
        self.model.cityInfo.socialGroupName = item.socialGroupName;
        [self reloadTableView];
    }
}
@end
