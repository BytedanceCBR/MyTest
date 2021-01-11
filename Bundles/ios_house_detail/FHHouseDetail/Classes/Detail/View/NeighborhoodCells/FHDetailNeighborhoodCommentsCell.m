//
//  FHDetailNeighborhoodCommentsCell.m
//  FHHouseDetail
//
//  Created by wangzhizhou on 2020/2/24.
//

#import "FHDetailNeighborhoodCommentsCell.h"
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
#import "FHUGCFeedDetailJumpManager.h"
#import "FHUtils.h"
#import "FHDetailMoreView.h"

#define cellId @"cellId"

@interface FHDetailNeighborhoodCommentsCell () <UITableViewDelegate,UITableViewDataSource, FHUGCBaseCellDelegate>

@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIView *titleView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) FHDetailMoreView *moreView;
@property(nonatomic, strong) FHUGCCellManager *cellManager;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, weak  ) UIImageView *shadowImage;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;

@end

@implementation FHDetailNeighborhoodCommentsCell

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
    [self.contentView addSubview:_containerView];
    
    self.tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.layer.masksToBounds = YES;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    _tableView.estimatedRowHeight = 0;
    _tableView.scrollEnabled = NO;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    
    [self.containerView addSubview:_tableView];
    
    self.cellManager = [[FHUGCCellManager alloc] init];
    [self.cellManager registerAllCell:_tableView];
    
    self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
    self.detailJumpManager.refer = 1;
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 42, 34)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoMore)];
    [self.titleView addGestureRecognizer:tap];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontSemibold:16] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"小区点评";
    [self.titleView addSubview:_titleLabel];
    [self.titleView addSubview:self.moreView];
    _tableView.tableHeaderView = self.titleView;
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
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(4.5, 0, 4.5, 0));
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView);
        make.left.mas_equalTo(self.containerView).offset(9);
        make.right.mas_equalTo(self.containerView).offset(-9);
        make.height.mas_equalTo(0);
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
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailCommentsCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailCommentsCellModel *cellModel = (FHDetailCommentsCellModel *)data;
    self.shadowImage.image = cellModel.shadowImage;
            
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(cellModel.viewHeight);
    }];
    
    if (cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll || cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeDefault) {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
        }];
    }
    
    if (cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll || cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeAll) {
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(4.5);
        }];
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
        }];
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
    FHDetailCommentsCellModel *cellModel = (FHDetailCommentsCellModel *)self.currentData;
    if(!isEmptyString(cellModel.commentsListSchema)){
        NSURL *url = [NSURL URLWithString:cellModel.commentsListSchema];
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"neighborhood_id"] = cellModel.neighborhoodId;
        dict[@"title"] = cellModel.title;
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[UT_ORIGIN_FROM] = cellModel.tracerDict[@"origin_from"] ?: @"be_null";
        tracerDict[UT_ENTER_FROM] = cellModel.tracerDict[@"page_type"] ?: @"be_null";
        tracerDict[UT_ELEMENT_FROM] = [self elementTypeString:FHHouseTypeNeighborhood];
        tracerDict[UT_LOG_PB] = cellModel.tracerDict[@"log_pb"] ?: @"be_null";
        tracerDict[@"from_gid"] = self.baseViewModel.houseId;
        dict[TRACER_KEY] = tracerDict;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_comment";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;

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
        Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            return [cellClass heightForData:cellModel];
        }
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self gotoMore];
}

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    // PM要求点富文本链接也进入详情页
    [self lookAllLinkClicked:cellModel cell:nil];
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

@end
