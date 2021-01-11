//
//  FHDetailNeighborhoodQACell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/2/7.
//

#import "FHDetailNeighborhoodQACell.h"
#import "FHDetailNeighborhoodModel.h"
#import "TTDeviceHelper.h"
#import "FHDetailFoldViewButton.h"
#import "PNChart.h"
#import "UIView+House.h"
#import <FHHouseBase/FHUserTracker.h>
#import "FHFeedUGCCellModel.h"
#import "FHNeighbourhoodQuestionCell.h"
#import "TTAccountManager.h"
#import "TTStringHelper.h"
#import "FHUGCCellManager.h"
#import "FHUtils.h"
#import "FHUGCFeedDetailJumpManager.h"
#import "FHDetailMoreView.h"
#import "FHDetailHouseNeighborhoodQuestionCell.h"

#define cellId @"cellId"

@interface FHDetailNeighborhoodQACell () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) NSMutableArray *dataList;
@property(nonatomic , strong) UITableView *tableView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic , strong) UIView *titleView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) FHDetailMoreView *moreView;
@property(nonatomic , strong) NSMutableDictionary *clientShowDict;
@property(nonatomic , strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property (nonatomic, strong) UIView *topLine;

@end

@implementation FHDetailNeighborhoodQACell

- (FHDetailMoreView *)moreView {
    if(!_moreView) {
        _moreView = [FHDetailMoreView new];
    }
    return _moreView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self initConstaints];
    }
    return self;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(-4.5, 0, -4.5, 0));
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];

    self.tableView = [[UITableView alloc] init];
    // 注册Cell
    [_tableView registerClass:FHDetailHouseNeighborhoodQuestionCell.class forCellReuseIdentifier:NSStringFromClass(FHDetailHouseNeighborhoodQuestionCell.class)];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.layer.masksToBounds = YES;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    _tableView.estimatedRowHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    
    [self.containerView addSubview:_tableView];
    
    self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
    self.detailJumpManager.refer = 1;
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 42, 34)];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontSemibold:16] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"小区问答";
    [self.titleView addSubview:_titleLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoMore)];
    [self.titleView addGestureRecognizer:tap];
    [self.titleView addSubview:self.moreView];
    
    _tableView.tableHeaderView = self.titleView;
    
    self.topLine = [[UIView alloc] init];
    self.topLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:self.topLine];
    self.topLine.hidden = YES;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)initConstaints {
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(4.5, 9, 4.5, 9));
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView);
        make.left.mas_equalTo(self.containerView);
        make.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(300);
        make.bottom.mas_equalTo(self.containerView);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleView).offset(12);
        make.left.mas_equalTo(self.titleView).offset(12);
        make.right.mas_equalTo(self.moreView.mas_left).offset(-12);
        make.height.mas_equalTo(22);
    }];
    
    [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleView).offset(-12);
        make.height.equalTo(self.titleLabel);
    }];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.left.mas_equalTo(21);
        make.right.mas_equalTo(-21);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailQACellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailQACellModel *cellModel = (FHDetailQACellModel *)data;
    self.shadowImage.image = cellModel.shadowImage;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(cellModel.viewHeight);
    }];
    
    if (cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll) {
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(4.5);
        }];
    }
    if (cellModel.shdowImageScopeType != FHHouseShdowImageScopeTypeTopAll && cellModel.shdowImageScopeType != FHHouseShdowImageScopeTypeAll) {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
        }];
        self.topLine.hidden = NO;
    }
    _titleLabel.text = cellModel.title;
    
    self.dataList = [[NSMutableArray alloc] init];
    [_dataList addObjectsFromArray:cellModel.dataList];
    [self.tableView reloadData];
    
    self.moreView.hidden = (self.dataList.count <= 0);
}

#pragma mark delegate

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)gotoMore {
    FHDetailQACellModel *cellModel = (FHDetailQACellModel *)self.currentData;
    if(!isEmptyString(cellModel.questionListSchema)){
        NSURL *url = [NSURL URLWithString:cellModel.questionListSchema];
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"neighborhood_id"] = cellModel.neighborhoodId;
        dict[@"title"] = cellModel.title;
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[UT_ORIGIN_FROM] = cellModel.tracerDict[@"origin_from"] ?: @"be_null";
        tracerDict[UT_ENTER_FROM] = cellModel.tracerDict[@"page_type"] ?: @"be_null";
        tracerDict[UT_ELEMENT_FROM] = [self elementTypeString:FHHouseTypeNeighborhood];
        tracerDict[UT_LOG_PB] = cellModel.tracerDict[@"log_pb"] ?: @"be_null";
        dict[TRACER_KEY] = tracerDict;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_question";
}

#pragma mark - UITableViewDataSource

- (void)traceFeedClientShowWithIndexPath: (NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        
        if (!self.clientShowDict) {
            self.clientShowDict = [NSMutableDictionary new];
        }
        
        NSString *groupId = cellModel.groupId;
        if(groupId){
            if (self.clientShowDict[groupId]) {
                return;
            }
            
            self.clientShowDict[groupId] = @(indexPath.row);
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[UT_ENTER_FROM] = self.baseViewModel.detailTracerDic[UT_ENTER_FROM]?: UT_BE_NULL;
            dict[UT_ORIGIN_FROM] = self.baseViewModel.detailTracerDic[UT_ORIGIN_FROM]?:UT_BE_NULL;
            dict[UT_PAGE_TYPE] = [self.baseViewModel pageTypeString];
            dict[UT_LOG_PB] = cellModel.logPb;
            dict[UT_ELEMENT_TYPE] = [self elementTypeString:FHHouseTypeNeighborhood];
            dict[@"rank"] = @(indexPath.row);
            dict[@"group_id"] = cellModel.groupId;
            dict[@"from_gid"] = self.baseViewModel.houseId;
            
            id logPb = dict[@"log_pb"];
            NSDictionary *logPbDic = nil;
            if([logPb isKindOfClass:[NSDictionary class]]){
                logPbDic = logPb;
            }else if([logPb isKindOfClass:[NSString class]]){
                logPbDic = [FHUtils dictionaryWithJsonString:logPb];
            }
            
            if(logPbDic[@"impr_id"]){
                dict[@"impr_id"] = logPbDic[@"impr_id"];
            }
            
            if(logPbDic[@"group_source"]){
                dict[@"group_source"] = logPbDic[@"group_source"];
            }
            
            TRACK_EVENT(@"feed_client_show", dict);
        }
    }
}

- (void)fh_willDisplayCell  {
    [super fh_willDisplayCell];
    
    if(self.dataList.count > 0) {
        for(int i = 0; i < self.dataList.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self traceFeedClientShowWithIndexPath:indexPath];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass(FHDetailHouseNeighborhoodQuestionCell.class);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(indexPath.row < self.dataList.count){
            [cell refreshWithData:cellModel];
        }
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        return [FHDetailHouseNeighborhoodQuestionCell heightForData:cellModel];
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self gotoMore];
}

@end
