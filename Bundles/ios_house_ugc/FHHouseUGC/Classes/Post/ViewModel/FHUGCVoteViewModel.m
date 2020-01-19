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
#import <FHUGCVoteDatePickerView.h>

#define DATEPICKER_HEIGHT 200
#define TOP_BAR_HEIGHT 40

@interface FHUGCVoteViewModel() <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,FHUGCVotePublishBaseViewDelegate, FHUGCVotePublishOptionCellDelegate>

@property (nonatomic, strong) FHUGCVotePublishModel *model;
@property (nonatomic, weak  ) UIScrollView *scrollView;
@property (nonatomic, weak  ) FHUGCVotePublishViewController *viewController;

@property (nonatomic, strong) FHUGCVotePublishScopeView *scopeView;
@property (nonatomic, strong) FHUGCVotePublishVoteTypeView *typeView;
@property (nonatomic, strong) FHUGCVotePublishDatePickView *deadlineDateView;
@property (nonatomic, strong) FHUGCVotePublishTitleView *titleTextView;
@property (nonatomic, strong) FHUGCVotePublishDescriptionView *descTextView;

@property (nonatomic, strong) UITableView *voteOptionsTableView;
@property (nonatomic, strong) UIView *addOptionFooterView;

@property (nonatomic, strong) FHUGCVoteBottomPopView *bottomPopView;
@property (nonatomic, strong) FHUGCVoteDatePickerView *datePicker;
@property (nonatomic, strong) UIView *dateSelectView;

@property (nonatomic, assign) BOOL isPublishing;

@end

@implementation FHUGCVoteViewModel

-(instancetype)initWithScrollView:(UIScrollView *)scrollView ViewController:(FHUGCVotePublishViewController *)viewController {
    if(self = [super init]) {
        self.scrollView = scrollView;
        self.scrollView.delegate = self;
        self.scrollView.backgroundColor = [UIColor colorWithHexStr:@"#EBEBF0"];
        self.viewController = viewController;
        self.model = [FHUGCVotePublishModel new];
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    // 可见范围
    self.scopeView = [[FHUGCVotePublishScopeView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, CELL_HEIGHT)];
    self.scopeView.delegate = self;
    
    // 投票类型
    self.typeView = [[FHUGCVotePublishVoteTypeView alloc] initWithFrame:CGRectMake(0, self.scopeView.bottom, self.scopeView.frame.size.width, CELL_HEIGHT)];
    self.typeView.delegate = self;
    
    // 投票截止日期
    self.deadlineDateView = [[FHUGCVotePublishDatePickView alloc] initWithFrame:CGRectMake(0, self.typeView.bottom, self.typeView.frame.size.width, CELL_HEIGHT)];
    self.deadlineDateView.hideBottomLine = YES;
    self.deadlineDateView.delegate = self;
    [self updateDeadlineDateView];
    
    // 标题
    self.titleTextView = [[FHUGCVotePublishTitleView alloc] initWithFrame:CGRectMake(0, self.deadlineDateView.bottom + 20, self.deadlineDateView.frame.size.width, TITLE_VIEW_HEIGHT)];
    self.titleTextView.delegate = self;
    
    // 描述
    self.descTextView = [[FHUGCVotePublishDescriptionView alloc] initWithFrame:CGRectMake(0, self.titleTextView.bottom, self.titleTextView.frame.size.width, DESC_VIEW_HEIGHT)];
    self.descTextView.hideBottomLine = YES;
    self.descTextView.delegate = self;

    // 投票选项
    self.voteOptionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.descTextView.bottom, self.descTextView.frame.size.width, 0) style:UITableViewStyleGrouped];
    [self updateVoteOptionsViewHeight];
    [self.voteOptionsTableView registerClass:[FHUGCVotePublishOptionCell class] forCellReuseIdentifier:[FHUGCVotePublishOptionCell reusedIdentifier]];
    self.voteOptionsTableView.scrollEnabled = NO;
    self.voteOptionsTableView.delegate = self;
    self.voteOptionsTableView.dataSource = self;
    
    // 上半截
    [self.scrollView addSubview:self.scopeView];
    [self.scrollView addSubview:self.typeView];
    [self.scrollView addSubview:self.deadlineDateView];
    
    // 下半截
    [self.scrollView addSubview:self.titleTextView];
    [self.scrollView addSubview:self.descTextView];
    [self.scrollView addSubview:self.voteOptionsTableView];
}

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
        titleLabel.text = @"投票截止时间";
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

- (FHUGCVoteDatePickerView *)datePicker {
    if(!_datePicker) {
        _datePicker = [[FHUGCVoteDatePickerView alloc] initWithFrame:CGRectMake(0, TOP_BAR_HEIGHT, SCREEN_WIDTH, DATEPICKER_HEIGHT) minimumDate:[NSDate date] maximumDate:[[NSDate date] dateByAddingTimeInterval:29 * 24 * 60 * 60]];
        NSDate *defaultVoteDeadline = [[NSDate date] dateByAddingTimeInterval:7 * 24 * 60 * 60];
        _datePicker.date = self.model.deadline ? self.model.deadline : defaultVoteDeadline;
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

// 从圈子详情页进入投票时带入的圈子信息处理
- (void)configModelForSocialGroupId: (NSString *)socialGroupId socialGroupName: (NSString *)socialGroupName hasFollowed:(BOOL)followed {
    
    if(self.model && followed) {
        FHUGCVotePublishCityInfo *cityInfo = [[FHUGCVotePublishCityInfo alloc] init];
        cityInfo.socialGroupId = socialGroupId;
        cityInfo.socialGroupName = socialGroupName;
        self.model.cityInfos = @[cityInfo];
        self.model.isAllSelected = NO;
        self.model.isPartialSelected = YES;
        self.model.visibleType = VisibleType_Group;
        
        [self updateVoteVisibleScopeView];
    }
}

// MARK: UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return OPTION_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return OPTION_CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.addOptionFooterView;
}

// MARK: UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FHUGCVotePublishOptionCell *optionCell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishOptionCell reusedIdentifier] forIndexPath: indexPath];
    
    NSInteger index = indexPath.row;
    if(index >= 0 && index < self.model.options.count) {
        [optionCell updateWithOption:self.model.options[index]];
    }
    
    optionCell.delegate = self;
    
    return optionCell;
}

// MARK: FHUGCVotePublishBaseViewDelegate

- (void)voteScopeView:(FHUGCVotePublishScopeView *)scopeView tapAction:(UITapGestureRecognizer *)tap {
    [self gotoVoteVisibleScopePage];
}

- (void)voteTypeView:(FHUGCVotePublishVoteTypeView *)scopeView tapAction:(UITapGestureRecognizer *)tap {
    [self gotoVoteTypeSelectPage];
}

- (void)voteDatePickView:(FHUGCVotePublishDatePickView *)scopeView tapAction:(UITapGestureRecognizer *)tap {
    [self showDatePicker];
}

- (void)voteTitleView:(FHUGCVotePublishTitleView *)titleView didInputText:(NSString *)text {
    self.model.voteTitle = [self validStringConvertWith:text];
    [self checkIfEnablePublish];
}

- (void)voteTitleView:(FHUGCVotePublishTitleView *)titleView didChangeHeight:(CGFloat)newHeight {
    [self updateTitleViewWithNewHeight:newHeight];
    self.viewController.firstResponderView = titleView;
    [self.viewController scrollToVisibleForFirstResponderView];
}

- (void)voteTitleViewDidBeginEditing:(FHUGCVotePublishTitleView *)titleView {
    self.viewController.firstResponderView = titleView;
}

- (void)descriptionView:(FHUGCVotePublishDescriptionView *)descriptionView didInputText:(NSString *)text {
    self.model.voteDescription = [self validStringConvertWith:text];
    [self checkIfEnablePublish];
}

- (void)descriptionView:(FHUGCVotePublishDescriptionView *)descriptionView didChangeHeight:(CGFloat)newHeight {
    [self updateDescriptionViewWithNewHeight:newHeight];
    self.viewController.firstResponderView = descriptionView;
    [self.viewController scrollToVisibleForFirstResponderView];
}

- (void)descriptionViewDidBeginEditing:(FHUGCVotePublishDescriptionView *)descriptionView {
    self.viewController.firstResponderView = descriptionView;
}

// MARK: UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.scrollView endEditing:YES];
}

// MARK: 函数

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
        
        [self updateVoteVisibleScopeView];
        
    };
    NSMutableDictionary *tracer = @{}.mutableCopy;
    tracer[UT_ENTER_FROM] = self.viewController.tracerDict[UT_ENTER_FROM];
    tracer[UT_PAGE_TYPE] = @"vote_publisher";
    dict[TRACER_KEY] = tracer;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_vote_publish_visible_scope"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)updateVoteVisibleScopeView {
    
    NSInteger count = self.model.cityInfos.count;
    
    NSMutableString *title = @"未设置";
    self.scopeView.cityLabel.textColor = [UIColor themeGray3];
    
    if(self.model.isAllSelected) {
        title = @"全部关注圈子";
        self.scopeView.cityLabel.textColor = [UIColor themeGray1];
    }
    else if(self.model.isPartialSelected) {
        if(count > 1) {
            title = [NSMutableString stringWithFormat:@"%@等%@个圈子", self.model.cityInfos.firstObject.socialGroupName, @(count)];
            self.scopeView.cityLabel.textColor = [UIColor themeGray1];
        }
        else if(count == 0) {
            // 默认未设置
        }
        else {
            title = [NSMutableString stringWithFormat:@"%@", self.model.cityInfos.firstObject.socialGroupName];
            self.scopeView.cityLabel.textColor = [UIColor themeGray1];
        }
    }
    self.scopeView.cityLabel.text = title;
    
    [self checkIfEnablePublish];
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
        [self updateVoteTypeView];
    };
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_vote_publish_type_select"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)updateVoteTypeView {
    [self.typeView updateWithVoteType:self.model.type];
    [self checkIfEnablePublish];
}

- (void)showDatePicker {
    [self.viewController.view endEditing:YES];
    [self.datePicker removeFromSuperview];
    self.datePicker = nil;
    [self.dateSelectView removeFromSuperview];
    self.dateSelectView = nil;
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
    if([self.datePicker.date timeIntervalSinceDate:[NSDate date]] < 0) {
        [[ToastManager manager] showToast:@"截止日期必须大于当前时间"];
        return;
    }
    [self updateDeadlineDateView];
    [self.bottomPopView hide];
}

- (void)updateDeadlineDateView {
    self.model.deadline = self.datePicker.date;
    self.deadlineDateView.dateLabel.text = [self.deadlineDateView.dateFormatter stringFromDate:self.datePicker.date];
    [self checkIfEnablePublish];
}

- (void)updateTitleViewWithNewHeight:(CGFloat)newHeight {
    CGRect frame = self.titleTextView.frame;
    frame.size.height = newHeight;
    self.titleTextView.frame = frame;
    
    // 更新投票描述位置
    [self updateDescriptionViewLocation];
}

- (void)updateDescriptionViewWithNewHeight:(CGFloat)newHeight {
    CGRect frame = self.descTextView.frame;
    frame.size.height = newHeight;
    self.descTextView.frame = frame;
    
    // 更新投票选项位置
    [self updateVoteOptionsViewLocation];
}

- (void)updateDescriptionViewLocation {
    // 更新投票描述位置
    CGRect descTextViewFrame = self.descTextView.frame;
    descTextViewFrame.origin.y = self.titleTextView.bottom;
    self.descTextView.frame = descTextViewFrame;
    
    // 更新投票选项位置
    [self updateVoteOptionsViewLocation];
}

- (void)updateVoteOptionsViewLocation {
    CGRect frame = self.voteOptionsTableView.frame;
    frame.origin.y = self.descTextView.bottom;
    self.voteOptionsTableView.frame = frame;
    
    // 更新滚动视图的内容大小
    [self updateScrollViewContentSize];
}

- (void)updateVoteOptionsViewHeight {
    CGRect frame = self.voteOptionsTableView.frame;
    CGFloat optionViewMinHeight = self.scrollView.frame.size.height - self.descTextView.bottom;
    frame.size.height = MAX((self.model.options.count + 1) * OPTION_CELL_HEIGHT, optionViewMinHeight);
    self.voteOptionsTableView.frame = frame;

    [self updateScrollViewContentSize];
}

- (void)updateScrollViewContentSize {
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height = MAX(self.voteOptionsTableView.bottom, self.scrollView.frame.size.height);
    self.scrollView.contentSize = contentSize;
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

- (NSString *)validStringConvertWith:(NSString *)originString {
    return [[originString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

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
    self.isPublishing = YES;
    [FHHouseUGCAPI requestVotePublishWithParam:params completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        // 成功 status = 0 请求失败 status = 1 数据解析失败 status = 2
        if(error) {
            [[ToastManager manager] showToast:@"发布投票失败!"];
            [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_vote_publish" metric:nil category:@{@"status":@(1)} extra:nil];
            
            // 发布请求结束，防止发布按钮被快速连续点击多次，造出多次发布投票, 放在最后面
            self.isPublishing = NO;
            
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
        
        
        
        // 发布请求结束，防止发布按钮被快速连续点击多次，造出多次发布投票, 放在最后面
        self.isPublishing = NO;
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

        FHUGCVotePublishOptionCell *optionCell0 = [self.voteOptionsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [optionCell0 updateWithOption:options[0]];

        FHUGCVotePublishOptionCell *optionCell1 = [self.voteOptionsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

        [optionCell1 updateWithOption:options[1]];
    }

    if(options.count <= OPTION_COUNT_MAX) {
        self.model.options = options;
        
        [self.voteOptionsTableView beginUpdates];
        [self updateVoteOptionsViewHeight];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.voteOptionsTableView numberOfRowsInSection:0] inSection:0];
        [self.voteOptionsTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height) animated:YES];
        [self.voteOptionsTableView endUpdates];
    }
    
    self.addOptionFooterView.alpha = (self.model.options.count < OPTION_COUNT_MAX) ? 1 : 0;
}

#pragma mark - FHUGCVotePublishOptionCellDelegate

- (void)optionCell:(FHUGCVotePublishOptionCell *)optionCell didInputText:(NSString *)text {
    NSIndexPath *indexPath = [self.voteOptionsTableView indexPathForCell:optionCell];
    NSUInteger index = indexPath.row;
    if(index < self.model.options.count) {
        self.model.options[index].content = [self validStringConvertWith:text];
        [self checkIfEnablePublish];
    }
}

- (void)deleteOptionCell:(FHUGCVotePublishOptionCell *)optionCell {
    NSMutableArray *options = [NSMutableArray arrayWithArray:self.model.options];
    NSIndexPath *indexPath = [self.voteOptionsTableView indexPathForCell:optionCell];
    if(indexPath.row >= 0) {
        NSUInteger index = indexPath.row;

        if(self.model.options.count <= OPTION_COUNT_MIN + 1) {
            [self.model.options enumerateObjectsUsingBlock:^(FHUGCVotePublishOption * _Nonnull option, NSUInteger idx, BOOL * _Nonnull stop) {
                option.isValid = NO;
            }];

            NSMutableArray *indexPaths = [NSMutableArray array];
            for(NSInteger i = 0; i < options.count; i++) {
                if(i == index) {
                    continue;
                }

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }

            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *  _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
                FHUGCVotePublishOptionCell *optionCell = [self.voteOptionsTableView cellForRowAtIndexPath:indexPath];
                [optionCell updateWithOption:self.model.options[indexPath.row]];
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

            FHUGCVotePublishOptionCell *nextResponderCell = [self.voteOptionsTableView cellForRowAtIndexPath:nextResponderCellIndexPath];
            [nextResponderCell.optionTextField becomeFirstResponder];
        }

        [options removeObjectAtIndex:index];
        self.model.options = options;
        
        [self.voteOptionsTableView beginUpdates];
        [self.voteOptionsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.addOptionFooterView.alpha = (self.model.options.count < OPTION_COUNT_MAX) ? 1 : 0;
        [self.voteOptionsTableView endUpdates];
        
            // 动画执行完成后更新
        [self updateVoteOptionsViewHeight];
    }
}

- (void)optionCellDidBeginEditing:(FHUGCVotePublishOptionCell *)optionCell {
    self.viewController.firstResponderView = optionCell;
}

@end
