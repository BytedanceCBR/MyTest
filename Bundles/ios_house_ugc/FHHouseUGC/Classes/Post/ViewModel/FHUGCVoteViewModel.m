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
#import "FHHouseUGCAPI.h"
#import <ToastManager.h>
#import <FHUGCVotePublishTypeSelectViewController.h>
#import <TTInstallBaseMacro.h>
#import "FHUGCVoteBottomPopView.h"
#import <WDDefines.h>
#import "FHUGCVoteModel.h"
#import "HMDTTMonitor.h"
#import <TTReachability.h>
#import "FHUserTracker.h"
#import "BTDJSONHelper.h"
#import "FHFeedUGCCellModel.h"
#import "FHPostUGCViewController.h"
#import <TTUGCDefine.h>

#define OPTION_START_INDEX  2
#define DATEPICKER_HEIGHT 200
#define TOP_BAR_HEIGHT 40


@interface FHUGCVoteViewModel() <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,FHUGCVotePublishBaseCellDelegate>
@property (nonatomic, strong) FHUGCVotePublishModel *model;
@property (nonatomic, weak  ) UITableView *tableView;
@property (nonatomic, weak  ) FHUGCVotePublishViewController *viewController;
@property (nonatomic, strong) UIView *addOptionFooterView;
@property (nonatomic, assign) BOOL isDatePickerHidden;
@property (nonatomic, strong) FHUGCVoteBottomPopView *bottomPopView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIView *dateSelectView;
@end

@implementation FHUGCVoteViewModel

- (FHUGCVoteBottomPopView *)bottomPopView {
    if(!_bottomPopView) {
        _bottomPopView = [[FHUGCVoteBottomPopView alloc] initWithFrame:self.viewController.view.bounds];
    }
    return _bottomPopView;
}

- (UIView *)dateSelectView {
    
    if(!_dateSelectView) {
        CGFloat paddingHeight = [TTDeviceHelper isIPhoneXDevice] ? 34 : 0;
        _dateSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TOP_BAR_HEIGHT + DATEPICKER_HEIGHT + paddingHeight)];
        _dateSelectView.backgroundColor = [UIColor whiteColor];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont themeFontRegular:16];
        [cancelButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [cancelButton sizeToFit];
        [cancelButton addTarget:self action:@selector(dateCancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"投票截止日期";
        titleLabel.textColor = [UIColor themeGray1];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont themeFontRegular:16];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        confirmButton.titleLabel.font = [UIFont themeFontRegular:16];
        [confirmButton setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        [confirmButton sizeToFit];
        [confirmButton addTarget:self action:@selector(dateConfirmAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_dateSelectView addSubview:cancelButton];
        [_dateSelectView addSubview:titleLabel];
        [_dateSelectView addSubview:confirmButton];
        
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_dateSelectView).offset(20);
            make.top.equalTo(_dateSelectView).offset(10);
            make.width.mas_offset(50);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.dateSelectView);
            make.centerY.equalTo(cancelButton);
            make.height.equalTo(cancelButton);
        }];
        
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_dateSelectView).offset(-20);
            make.top.equalTo(_dateSelectView).offset(10);
            make.width.mas_offset(50);
        }];
        
        [_dateSelectView addSubview:self.datePicker];
    }
    return _dateSelectView;
}

- (UIDatePicker *)datePicker {
    if(!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, TOP_BAR_HEIGHT, SCREEN_WIDTH, DATEPICKER_HEIGHT)];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.minimumDate = [NSDate date];
        _datePicker.maximumDate = [[NSDate date] dateByAddingTimeInterval:30 * 24 * 60 * 60];
        NSDate *defaultVoteDeadline = [[NSDate date] dateByAddingTimeInterval:7 * 24 * 60 * 60];
        _datePicker.date = defaultVoteDeadline;
    }
    return _datePicker;
}

- (UIView *)addOptionFooterView {
    if(!_addOptionFooterView) {
        _addOptionFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        _addOptionFooterView.backgroundColor = [UIColor themeWhite];
        
        UIImageView *addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        addImageView.image = [UIImage imageNamed:@"fh_ugc_vote_publish_add_option"];
        
        UILabel *addLabel = [UILabel new];
        addLabel.font = [UIFont themeFontRegular:16];
        addLabel.textColor = [UIColor colorWithHexStr:@"#256df2"];
        addLabel.text = @"添加选项";
        
        [_addOptionFooterView addSubview:addImageView];
        [_addOptionFooterView addSubview:addLabel];
        
        [addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(18);
            make.centerY.equalTo(addLabel);
            make.left.equalTo(_addOptionFooterView).offset(20);
        }];
        
        [addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(addImageView.mas_right).offset(5);
            make.top.equalTo(_addOptionFooterView).offset(24);
            make.bottom.equalTo(_addOptionFooterView).offset(-16);
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
    }
    return self;
}

// 从圈子详情页进入投票时带入的圈子信息处理
- (void)configModelForSocialGroupId: (NSString *)socialGroupId socialGroupName: (NSString *)socialGroupName hasFollowed:(BOOL)followed {
    
    if(self.model) {
        FHUGCVotePublishCityInfo *cityInfo = [[FHUGCVotePublishCityInfo alloc] init];
        cityInfo.socialGroupId = socialGroupId;
        cityInfo.socialGroupName = socialGroupName;
        self.model.cityInfos = @[cityInfo];
        self.model.isAllSelected = NO;
        self.model.isPartialSelected = YES;
        self.model.visibleType = VisibleType_Group;
    }
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
    if(indexPath.section == 0) {
        if(indexPath.row == 1) {
            return CELL_HEIGHT;
        }
        else if(indexPath.row == 2) {
            return self.isDatePickerHidden ? CELL_HEIGHT : CELL_HEIGHT + DATEPICKER_HEIGHT;
        }
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            return 70;
        }
        else if(indexPath.row == 1) {
            return 65;
        }
        else {
            return 62;
        }
    }
    return CELL_HEIGHT;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return CGFLOAT_MIN;
    } else {
        return 20;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 1) {
        return 62;
    } else {
        return CGFLOAT_MIN;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(section == 1) {
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
            [self gotoVoteVisibleScopePage];
        }
        else if(indexPath.row == 1) {
            [self gotoVoteTypeSelectPage];
        }
        else if(indexPath.row == 2) {
            [self showDatePicker];
        } else {
        }
    }
    else if(indexPath.section == 1) {
        
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
            + 1     // 投票类型Cell
            + 1     // 截止日期Cell
        );
    }
    else if(section == 1) {
        return (
            + 1     // 投票标题Cell
            + 1     // 投票描述Cell
            + self.model.options.count // 投票选项
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
            NSInteger count = self.model.cityInfos.count;
            FHUGCVotePublishCityCell* cityCell = (FHUGCVotePublishCityCell *)cell;
            
            NSMutableString *title = @"未设置";
            cityCell.cityLabel.textColor = [UIColor themeGray3];
            
            if(self.model.isAllSelected) {
                title = @"全部关注圈子";
                cityCell.cityLabel.textColor = [UIColor themeGray1];
            }
            else if(self.model.isPartialSelected) {
                if(count > 1) {
                    title = [NSMutableString stringWithFormat:@"%@等%@个圈子", self.model.cityInfos.firstObject.socialGroupName, @(count)];
                    cityCell.cityLabel.textColor = [UIColor themeGray1];
                }
                else if(count == 0) {
                    // 默认未设置
                }
                else {
                    title = [NSMutableString stringWithFormat:@"%@", self.model.cityInfos.firstObject.socialGroupName];
                    cityCell.cityLabel.textColor = [UIColor themeGray1];
                }
            }
            ((FHUGCVotePublishCityCell *)cell).cityLabel.text = title;
        }
        else if(indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishVoteTypeCell reusedIdentifier] forIndexPath:indexPath];
            
            [((FHUGCVotePublishVoteTypeCell *)cell) updateWithVoteType:self.model.type];
            
        } else if(indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishDatePickCell reusedIdentifier] forIndexPath:indexPath];
            FHUGCVotePublishDatePickCell *datePickCell = (FHUGCVotePublishDatePickCell *)cell;
            datePickCell.dateLabel.text = [datePickCell.dateFormatter stringFromDate:self.datePicker.date];
            self.model.deadline = self.datePicker.date;
        } else {
            cell = [UITableViewCell new];
        }
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishTitleCell reusedIdentifier] forIndexPath:indexPath];
        } else if(indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishDescriptionCell reusedIdentifier] forIndexPath: indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishOptionCell reusedIdentifier] forIndexPath: indexPath];
            
            NSInteger index = indexPath.row - OPTION_START_INDEX;
            if(index >= 0 && index < self.model.options.count) {
                FHUGCVotePublishOptionCell *optionCell = (FHUGCVotePublishOptionCell *)cell;
                [optionCell updateWithOption:self.model.options[index]];
            }
        }
    }
    cell.delegate = self;
    return cell;
}

// MARK: FHUGCVotePublishBaseCellDelegate

- (NSString *)validStringConvertWith:(NSString *)originString {
    return [[originString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)voteTitleCell:(FHUGCVotePublishTitleCell *)titleCell didInputText:(NSString *)text {
    self.model.voteTitle = [self validStringConvertWith:text];
    [self checkIfEnablePublish];
}

- (void)descriptionCell:(FHUGCVotePublishDescriptionCell *)descriptionCell didInputText:(NSString *)text {
    self.model.voteDescription = [self validStringConvertWith:text];
    [self checkIfEnablePublish];
}

- (void)optionCell:(FHUGCVotePublishOptionCell *)optionCell didInputText:(NSString *)text {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:optionCell];
    NSInteger optionStartIndex = OPTION_START_INDEX;
    NSUInteger index = MIN(MAX(indexPath.row - optionStartIndex, 0), self.model.options.count);
    if(index < self.model.options.count) {
        self.model.options[index].content = [self validStringConvertWith:text];
        [self checkIfEnablePublish];
    }
}

- (void)datePickerCell:(FHUGCVotePublishDatePickCell *)datePickerCell didSelectedDate:(NSDate *)date {
    self.model.deadline = date;
}

- (void)datePickerCell:(FHUGCVotePublishDatePickCell *)datePickerCell toggleWithStatus:(BOOL)isHidden {
    
    self.isDatePickerHidden = isHidden;
    [self reloadTableView];
}

// MARK: UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tableView endEditing:YES];
}

// MARK: 函数
- (void)publish {
    
    NSMutableString *socialGroupIds = [NSMutableString string];
    [self.model.cityInfos enumerateObjectsUsingBlock:^(FHUGCVotePublishCityInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.socialGroupId.length > 0) {
            if(idx == 0) {
                [socialGroupIds appendFormat:@"%@", obj.socialGroupId];
            } else {
                [socialGroupIds appendFormat:@",%@", obj.socialGroupId];
            }
        }
    }];
    NSString *voteTitle = self.model.voteTitle;
    NSString *voteDescription = self.model.voteDescription;
    NSArray *voteOptions = [NSArray arrayWithArray:self.model.options];
    VoteType voteType = self.model.type;
    NSDate *voteDate = self.model.deadline;
    
    // 有效投票
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"title"] = voteTitle;
    params[@"desc"] = voteDescription;
    params[@"content_rich_span"] = @"";
    params[@"social_group_ids"] = socialGroupIds;
    params[@"vote_type"] = @(voteType);
    params[@"visible"] = @(self.model.visibleType);
    params[@"deadline"] = @((NSInteger)[self.model.deadline timeIntervalSince1970]);
    NSMutableArray *optionList = [NSMutableArray array];
    [self.model.options enumerateObjectsUsingBlock:^(FHUGCVotePublishOption * _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
        if(option.content.length > 0) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            dictionary[@"title"] = option.content;
            [optionList addObject:dictionary];
        }
    }];
    params[@"options"] = optionList;
    
    // 判断是否有重复的选项内容
    if(optionList.count > 0) {
        for(int i = 0; i < optionList.count - 1; i++) {
            for(int j = i + 1; j < optionList.count; j++) {
                if([optionList[i][@"title"] isEqualToString:optionList[j][@"title"]]) {
                    [[ToastManager manager] showToast:@"存在相同选项"];
                    return;
                }
            }
        }
    }
    // 判断网络是否连接
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    WeakSelf;
    [FHHouseUGCAPI requestVotePublishWithParam:params completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        // 成功 status = 0 请求失败 status = 1 数据解析失败 status = 2
        if(error) {
            [[ToastManager manager] showToast:@"发布投票失败!"];
            [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_vote_publish" metric:nil category:@{@"status":@(1)} extra:nil];
            return;
        }
        if([model isKindOfClass:[FHUGCVoteModel class]]) {
            FHUGCVoteModel *voteModel = (FHUGCVoteModel *)model;
            if(voteModel.data.length > 0) {
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                
                if (socialGroupIds.length > 0) {
                    userInfo[@"social_group_id"] = socialGroupIds;
                }
                
                [userInfo setValue:@(FHUGCPublishTypeVote) forKey:@"publish_type"];
            
                // 数据转换
                NSString *vote_data = voteModel.data;
                NSString *social_group_ids = socialGroupIds;
                if ([vote_data isKindOfClass:[NSString class]] && vote_data.length > 0) {
                    // 模型转换
                    NSDictionary *dic = [vote_data JSONValue];
                    FHFeedUGCCellModel *cellModel = nil;
                    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                        NSDictionary * rawDataDic = dic[@"raw_data"];
                        // 先转成rawdata
                        NSError *jsonParseError;
                        if (rawDataDic && [rawDataDic isKindOfClass:[NSDictionary class]]) {
                            FHFeedContentRawDataModel *model = [[FHFeedContentRawDataModel alloc] initWithDictionary:rawDataDic error:&jsonParseError];
                            if (model && model.voteInfo) {
                                FHFeedContentModel *ugcContent = [[FHFeedContentModel alloc] init];
                                ugcContent.cellType = [NSString stringWithFormat:@"%d",FHUGCFeedListCellTypeUGCVoteInfo];
                                ugcContent.title = model.title;
                                ugcContent.isStick = model.isStick;
                                ugcContent.stickStyle = model.stickStyle;
                                ugcContent.diggCount = model.diggCount;
                                ugcContent.commentCount = model.commentCount;
                                ugcContent.userDigg = model.userDigg;
                                ugcContent.groupId = model.groupId;
                                ugcContent.logPb = model.logPb;
                                ugcContent.community = model.community;
                                ugcContent.rawData = model;
                                // FHFeedUGCCellModel
                                cellModel = [FHFeedUGCCellModel modelFromFeedContent:ugcContent];
                                
                                if(cellModel) {
                                    userInfo[@"cell_model"] = cellModel;
                                }
                            }
                        }
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostThreadSuccessNotification object:nil userInfo:userInfo];
                [self exitPage];
                [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_vote_publish" metric:nil category:@{@"status":@(0)} extra:nil];
                
                // 如何是在附近列表，发布投票完成后，跳转到关注页面
                [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCForumPostThreadFinish object:nil];
            }
            else {
                [[ToastManager manager] showToast:@"发布投票失败!"];
                [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_vote_publish" metric:nil category:@{@"status":@(2)} extra:nil];
            }
        }
    }];
}

- (void)exitPage {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)addOptionAction:(UITapGestureRecognizer *)tap {
    NSMutableArray<FHUGCVotePublishOption *> *options = [NSMutableArray arrayWithArray:self.model.options];
    [options addObject:[FHUGCVotePublishOption defaultOption]];
    
    if(options.count > OPTION_COUNT_MIN) {
        [options enumerateObjectsUsingBlock:^(FHUGCVotePublishOption * _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
            option.isValid = YES;
        }];
        
        FHUGCVotePublishOptionCell *optionCell0 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:OPTION_START_INDEX inSection:1]];
        [optionCell0 updateWithOption:options[0]];
        
        FHUGCVotePublishOptionCell *optionCell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: OPTION_START_INDEX + 1 inSection:1]];
        
        [optionCell1 updateWithOption:options[1]];
    }
    
    if(options.count <= OPTION_COUNT_MAX) {
        self.model.options = options;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:1] inSection:1];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if(options.count == OPTION_COUNT_MAX) {
            self.addOptionFooterView.alpha = 0;
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        } else {
             [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)deleteOptionCell:(FHUGCVotePublishOptionCell *)optionCell {
    NSMutableArray *options = [NSMutableArray arrayWithArray:self.model.options];
    NSInteger optionStartIndex = OPTION_START_INDEX;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:optionCell];
    if(indexPath.row >= optionStartIndex) {
        NSUInteger index = MIN(MAX(indexPath.row - optionStartIndex, 0), options.count);
        
        if(self.model.options.count <= OPTION_COUNT_MIN + 1) {
            [self.model.options enumerateObjectsUsingBlock:^(FHUGCVotePublishOption * _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
                option.isValid = NO;
            }];
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            for(NSInteger i = 0; i < options.count; i++) {
                if(i == index) {
                    continue;
                }
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i + optionStartIndex inSection:1];
                [indexPaths addObject:indexPath];
            }
            
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *  _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
                FHUGCVotePublishOptionCell *optionCell = [self.tableView cellForRowAtIndexPath:indexPath];
                [optionCell updateWithOption:self.model.options[indexPath.row - optionStartIndex]];
            }];
        }
        // 删除的Cell本身是当前键盘输入点，删除前转移焦点, 防止键盘消失引起抖动
        if([optionCell.optionTextField isFirstResponder]) {
            
            NSIndexPath *nextResponderCellIndexPath = nil;
            // 如果删除的不是最后一个Cell，焦点转移到下一个Cell， 是最后一个Cell，则焦点转移到上一个Cell
            if(index == 0) {
                nextResponderCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            } else if(index == options.count - 1) {
                nextResponderCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            } else {
                nextResponderCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            }
            
            FHUGCVotePublishOptionCell *nextResponderCell = [self.tableView cellForRowAtIndexPath:nextResponderCellIndexPath];
            [nextResponderCell.optionTextField becomeFirstResponder];
        }
        
        [options removeObjectAtIndex:index];
        self.model.options = options;
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if(self.model.options.count < OPTION_COUNT_MAX) {
            self.addOptionFooterView.alpha = 1;
        }
    }
}

- (void)gotoVoteVisibleScopePage {
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"isAllSelected"] = @(self.model.isAllSelected);
    dict[@"isPartialSelected"] = @(self.model.isPartialSelected);
    dict[@"visiableType"] = @(self.model.visibleType);
    dict[@"selectedSocialGroup"] = self.model.cityInfos;
    WeakSelf;
    dict[@"resultBlock"] = ^(NSArray<FHUGCVotePublishCityInfo *> *cityInfos, BOOL isAllSelected, BOOL isPartialSelected) {
        StrongSelf;

        self.model.isPartialSelected = isPartialSelected;
        self.model.isAllSelected = isAllSelected;
        self.model.visibleType = VisibleType_Group;
        self.model.cityInfos = cityInfos;
        [self reloadTableView];
        [self checkIfEnablePublish];
    };
    NSMutableDictionary *tracer = @{}.mutableCopy;
    tracer[UT_ENTER_FROM] = self.viewController.tracerDict[UT_ENTER_FROM];
    tracer[UT_PAGE_TYPE] = @"vote_publisher";
    dict[TRACER_KEY] = tracer;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_vote_publish_visible_scope"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)gotoVoteTypeSelectPage {
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    dict[TRACER_KEY] = traceParam;
    dict[@"voteType"] = @(self.model.type);
    WeakSelf;
    dict[@"resultBlock"] = ^(FHUGCVotePublishVoteTypeModel * selectedModel) {
        StrongSelf;
        self.model.type = selectedModel.type;
        [self reloadTableView];
        [self checkIfEnablePublish];
    };
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_vote_publish_type_select"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)showDatePicker {
    [self.viewController.view endEditing:YES];
    [self.bottomPopView showOnView:self.viewController.view withView:self.dateSelectView];
}

- (void)checkIfEnablePublish {
    
    BOOL hasTitle = self.model.voteTitle.length > 0;
    
    NSMutableArray<NSString *> *validOptions = [NSMutableArray array];
    [self.model.options enumerateObjectsUsingBlock:^(FHUGCVotePublishOption * _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
        if(option.content.length > 0) {
            [validOptions addObject:option.content];
        }
    }];
    
    BOOL hasOption = validOptions.count >= 2;
    BOOL hasVisibleScope = self.model.isAllSelected || self.model.isPartialSelected;
    BOOL hasVoteType = self.model.type != VoteType_Unknown;
    
    BOOL isEnablePublish = hasTitle && hasOption && hasVisibleScope && hasVoteType;
    [self.viewController enablePublish: isEnablePublish];
}


- (void)dateCancelAction:(UIButton *)sender {
    [self.bottomPopView hide];
}

- (void)dateConfirmAction:(UIButton *)sender {
    NSIndexPath *datePickCellIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[datePickCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.bottomPopView hide];
    [self checkIfEnablePublish];
}

- (BOOL)isEditedVote {
    
    __block BOOL ret = NO;
    
    if(self.model.voteTitle.length > 0) {
        ret = YES;
    }
    
    if(self.model.voteDescription.length > 0) {
        ret = YES;
    }
    
    [self.model.options enumerateObjectsUsingBlock:^(FHUGCVotePublishOption * _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
        if(option.content.length > 0) {
            ret = YES;
            *stop = YES;
        }
    }];
    
    if(self.model.isAllSelected || self.model.isPartialSelected) {
        ret = YES;
    }
    
    return ret;
}
@end
