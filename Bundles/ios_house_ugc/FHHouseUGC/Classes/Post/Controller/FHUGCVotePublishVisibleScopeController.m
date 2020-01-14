//
//  FHUGCVotePublishVisibleScopeController.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/14.
//

#import "FHUGCVotePublishVisibleScopeController.h"
#import <WDDefines.h>
#import <FHCommonDefines.h>
#import "Masonry.h"
#import "FHLocManager.h"
#import <FHHouseUGCAPI.h>
#import <FHUGCCommunityListModel.h>
#import "FHUGCVotePublishModel.h"
#import "FHUserTracker.h"

@interface FHUGCVotePublishVisibleScopeHeaderCell: UITableViewCell
@property (nonatomic, strong) UIImageView *checkImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *moreArrowImageView;
@property (nonatomic, assign) BOOL isOpen;

+ (NSString *)reuseIdentifier;
@end

@implementation FHUGCVotePublishVisibleScopeHeaderCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.checkImageView.hidden = YES;
    self.moreArrowImageView.hidden = YES;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

- (UIImageView *)checkImageView {
    if(!_checkImageView) {
        _checkImageView = [[UIImageView alloc] init];
        _checkImageView.image = [UIImage imageNamed:@"fh_ugc_vote_publish_visible_scope_check"];
        _checkImageView.hidden = YES;
    }
    return _checkImageView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (UIImageView *)moreArrowImageView {
    if(!_moreArrowImageView) {
        _moreArrowImageView = [[UIImageView alloc] init];
        _moreArrowImageView.image = [UIImage imageNamed:@"fh_ugc_vote_publish_visible_scope_more_up"];
        _moreArrowImageView.transform = CGAffineTransformIdentity;
        _moreArrowImageView.hidden = YES;
    }
    return _moreArrowImageView;
}

- (void)setIsOpen:(BOOL)isOpen {
    _isOpen = isOpen;
    [UIView animateWithDuration:0.3 animations:^{
        self.moreArrowImageView.transform = [self transformRotate];
    }];
}

- (CGAffineTransform)transformRotate {
    if(self.isOpen) {
        return CGAffineTransformMakeRotation(-2 * M_PI);
    } else {
        return CGAffineTransformMakeRotation(M_PI);
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.checkImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.moreArrowImageView];
        
        [self.checkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(22);
            make.left.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.checkImageView.mas_right).offset(10);
            make.top.bottom.equalTo(self.contentView);
        }];
        
        [self.moreArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(16);
            make.right.equalTo(self.contentView).offset(-20);
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.titleLabel.mas_right).offset(10);
        }];
    }
    return self;
}

@end

@interface FHUGCVotePublishVisibleScopeSocialGroupCell : UITableViewCell
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UILabel *titleLabel;

+ (NSString *)reuseIdentifier;
@end

@implementation FHUGCVotePublishVisibleScopeSocialGroupCell

- (UIButton *)checkButton {
    if(!_checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.userInteractionEnabled = NO;
        [_checkButton setImage:[UIImage imageNamed:@"fh_ugc_vote_publish_type_normal"] forState: UIControlStateNormal];
        [_checkButton setImage:[UIImage imageNamed:@"fh_ugc_vote_publish_type_selected"] forState:UIControlStateSelected];
    }
    return _checkButton;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.checkButton];
        [self.contentView addSubview:self.titleLabel];
        
        [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(52);
            make.width.height.mas_equalTo(20);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.checkButton.mas_right).offset(10);
            make.top.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-20);
        }];
    }
    return self;
}
@end

@interface FHUGCVotePublishVisibleScopeModel: NSObject
@property (nonatomic, copy) NSString *socialGroupName;
@property (nonatomic, copy) NSString *socialGroupId;
@property (nonatomic, assign) BOOL isSelected;
@end

@implementation FHUGCVotePublishVisibleScopeModel
@end

@interface FHUGCVotePublishVisibleScopeController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong , nullable) NSArray<FHUGCVotePublishVisibleScopeModel *> *socialGroupList;
@property (nonatomic, assign) BOOL isFoldSocialGroupList;
@property (nonatomic, copy) void (^resultBlock)(NSArray<FHUGCVotePublishCityInfo *> *cityInfos, BOOL isAllSelected, BOOL isPartialSelected);
@property (nonatomic, strong) NSArray<FHUGCVotePublishCityInfo *> *selectedSocialGroup;
@property (nonatomic, assign) BOOL isAllSelected;
@property (nonatomic, assign) BOOL isPartialSelected;
@property (nonatomic, strong) NSMutableSet<NSString *> *elementShowSet;
@end

@implementation FHUGCVotePublishVisibleScopeController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        self.resultBlock = paramObj.allParams[@"resultBlock"];
        self.selectedSocialGroup = paramObj.allParams[@"selectedSocialGroup"];
        self.isAllSelected = [paramObj.allParams[@"isAllSelected"] boolValue];
        self.isPartialSelected = [paramObj.allParams[@"isPartialSelected"] boolValue];
        self.elementShowSet = [NSMutableSet set];
    }
    return self;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, SCREEN_WIDTH, self.view.bounds.size.height - kNavigationBarHeight) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[FHUGCVotePublishVisibleScopeHeaderCell class] forCellReuseIdentifier:[FHUGCVotePublishVisibleScopeHeaderCell reuseIdentifier]];
        [_tableView registerClass:[FHUGCVotePublishVisibleScopeSocialGroupCell class] forCellReuseIdentifier:[FHUGCVotePublishVisibleScopeSocialGroupCell reuseIdentifier]];
        
        _tableView.backgroundColor = [UIColor themeWhite];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.bounces = NO;
        
        
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor themeWhite];
    
    [self.view addSubview: self.tableView];
    
    [self configNavigation];
    
    [self addDefaultEmptyViewFullScreen];
    
    [self request];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!self.isAllSelected && !self.isPartialSelected) {
        self.isFoldSocialGroupList = YES;
    } else if(!self.isAllSelected && self.isPartialSelected) {
        self.isFoldSocialGroupList = NO;
    } else {
        self.isFoldSocialGroupList = YES;
    }
}

- (void)configNavigation {
    
    [self setupDefaultNavBar:YES];
    
    [self setTitle:@"投票类型"];
    
    // 标题
    self.navigationItem.titleView = self.titleLabel;
    
    // 取消按钮
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn]];
    
    // 发布按钮
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.completeBtn]];
}

- (UIButton *)cancelBtn {
    if(!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_cancelBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelBtn.frame = CGRectMake(0, 0, 32, 44);
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"选择可见范围";
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (UIButton *)completeBtn {
    if(!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_completeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateDisabled];
        [_completeBtn setTitle:@"完成" forState:UIControlStateNormal];
        _completeBtn.frame = CGRectMake(0, 0, 32, 44);
        [_completeBtn addTarget:self action:@selector(completeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

- (void)completeAction: (UIButton *)sender {
    
    if(self.resultBlock) {
        
        NSMutableArray *cityInfos = [NSMutableArray array];
        
        if(self.isAllSelected) {
            [self.socialGroupList enumerateObjectsUsingBlock:^(FHUGCVotePublishVisibleScopeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHUGCVotePublishCityInfo *cityInfo = [FHUGCVotePublishCityInfo new];
                cityInfo.socialGroupId = obj.socialGroupId;
                cityInfo.socialGroupName = obj.socialGroupName;
                [cityInfos addObject:cityInfo];
            }];
        } else if(self.isPartialSelected) {
            [self.socialGroupList enumerateObjectsUsingBlock:^(FHUGCVotePublishVisibleScopeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(obj.isSelected) {
                    FHUGCVotePublishCityInfo *cityInfo = [FHUGCVotePublishCityInfo new];
                    cityInfo.socialGroupId = obj.socialGroupId;
                    cityInfo.socialGroupName = obj.socialGroupName;
                    [cityInfos addObject:cityInfo];
                }
            }];
        }
        self.resultBlock(cityInfos, self.isAllSelected, self.isPartialSelected); //本期写死为部分圈子，全部按部分圈子全选处理
    }
    [self exitPage];
}

- (void)cancelAction: (UIButton *)sender {
    [self exitPage];
}

- (void)exitPage {
    if(self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// MARK: UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *allGroupHeaderCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    FHUGCVotePublishVisibleScopeHeaderCell *allGroupHeaderCell = [tableView cellForRowAtIndexPath: allGroupHeaderCellIndexPath];
    
    NSIndexPath *paritalHeaderCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    FHUGCVotePublishVisibleScopeHeaderCell *partialHeaderCell = [tableView cellForRowAtIndexPath: paritalHeaderCellIndexPath];
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            if(self.isFoldSocialGroupList == NO) {
                self.isFoldSocialGroupList = YES;
            }
            
            self.isAllSelected = YES;
            self.isPartialSelected = !self.isAllSelected;

        }
    }
    else if(indexPath.section == 1) {
        
        self.isAllSelected = NO;
        self.isPartialSelected = !self.isAllSelected;
        
        if(indexPath.row == 0) {
            self.isFoldSocialGroupList = !self.isFoldSocialGroupList;
            partialHeaderCell.isOpen = !self.isFoldSocialGroupList;
        }
        
        else if(indexPath.row > 0) {
            FHUGCVotePublishVisibleScopeModel *model = self.socialGroupList[MAX(indexPath.row - 1, 0)];
            model.isSelected = !model.isSelected;
            
            
            // 点击选择想要发布的小区埋点
            NSMutableDictionary *params = @{}.mutableCopy;
            params[UT_PAGE_TYPE] = @"vote_publisher";
            params[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
            params[@"click_position"] = @"select_like_publisher_neighborhood";
            TRACK_EVENT(@"click_like_publisher_neighborhood", params);

        }
    }
    
    [tableView reloadData];
}

- (void)setIsFoldSocialGroupList:(BOOL)isFoldSocialGroupList {
    _isFoldSocialGroupList = isFoldSocialGroupList;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation: UITableViewRowAnimationFade];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

// MARK: UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.socialGroupList.count == 0) {
        return 0;
    }
    
    if(section == 0) {
        return 1;
    } else {
        return 1 + (self.isFoldSocialGroupList ? 0 : self.socialGroupList.count);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        FHUGCVotePublishVisibleScopeHeaderCell *headerCell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishVisibleScopeHeaderCell reuseIdentifier] forIndexPath:indexPath];
        if(indexPath.section == 0) {
            headerCell.titleLabel.text = @"全部关注圈子可见";
            headerCell.moreArrowImageView.hidden = YES;
            headerCell.checkImageView.hidden = !self.isAllSelected;
        } else {
            headerCell.titleLabel.text = @"部分圈子可见";
            headerCell.isOpen = !self.isFoldSocialGroupList;
            headerCell.moreArrowImageView.hidden = NO;
            headerCell.checkImageView.hidden = !self.isPartialSelected;
        }
        return headerCell;
    }
    else {
        FHUGCVotePublishVisibleScopeSocialGroupCell *socialGroupCell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishVisibleScopeSocialGroupCell reuseIdentifier] forIndexPath:indexPath];
        FHUGCVotePublishVisibleScopeModel *model = self.socialGroupList[indexPath.row - 1];
        
        NSString *title = model.socialGroupName;
        BOOL isSelected = model.isSelected;
        
        if(title.length > 0) {
            socialGroupCell.titleLabel.text = title;
            socialGroupCell.checkButton.selected = isSelected;
            socialGroupCell.backgroundColor = isSelected ? [UIColor themeGray7] : [UIColor themeWhite];
            
            // 可见圈子展现埋点
            if(![self.elementShowSet containsObject:model.socialGroupId]) {
                [self.elementShowSet addObject:model.socialGroupId];
                
                NSMutableDictionary *params = @{}.mutableCopy;
                params[UT_ELEMENT_TYPE] = @"select_like_publisher_neighborhood";
                params[UT_PAGE_TYPE] = @"vote_publisher";
                params[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
                params[@"group_id"] = model.socialGroupId;
                TRACK_EVENT(@"element_show", params);
            }
        }
        return socialGroupCell;
    }
}

// MARK: 请求

- (void)retryLoadData {
    [self request];
}

- (void)request {
    
    CLLocation *currentLocation = [FHLocManager sharedInstance].currentLocaton;

    WeakSelf;
    [FHHouseUGCAPI requestCommunityList:-2 source:@"social_group_list" latitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude class:[FHUGCCommunityListModel class] completion:^(id <FHBaseModelProtocol> _Nonnull model, NSError *_Nonnull error) {
        
        StrongSelf;
        FHUGCCommunityListModel *listModel = (FHUGCCommunityListModel *) model;
        if (error || !listModel || !(listModel.data)) {
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            self.completeBtn.hidden = YES;
            return;
        }
        [self.emptyView hideEmptyView];
        NSMutableArray *socialGroupList = [NSMutableArray array];
        
        NSMutableSet<NSString *> *selectedGroupIdSet = [NSMutableSet set];
        
        [self.selectedSocialGroup enumerateObjectsUsingBlock:^(FHUGCVotePublishCityInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [selectedGroupIdSet addObject:obj.socialGroupId];
        }];
        
        WeakSelf;
        [listModel.data.socialGroupList enumerateObjectsUsingBlock:^(FHUGCScialGroupDataModel *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            StrongSelf;
            FHUGCVotePublishVisibleScopeModel *visibleScopeModel = [[FHUGCVotePublishVisibleScopeModel alloc] init];
            visibleScopeModel.socialGroupId = obj.socialGroupId;
            visibleScopeModel.socialGroupName = obj.socialGroupName;
            visibleScopeModel.isSelected = [selectedGroupIdSet containsObject:obj.socialGroupId] && !self.isAllSelected;
            [socialGroupList addObject:visibleScopeModel];
        }];
        
        self.socialGroupList = socialGroupList;
        self.completeBtn.hidden = (self.socialGroupList.count == 0);
        if(self.socialGroupList.count > 0) {
            [self.tableView reloadData];
        } else {
            [self.emptyView showEmptyWithTip:@"您还没有关注圈子，快去关注吧" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        }
    }];
}
@end
