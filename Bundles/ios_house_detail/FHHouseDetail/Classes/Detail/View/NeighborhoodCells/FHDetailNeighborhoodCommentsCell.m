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

#define cellId @"cellId"

@interface FHDetailNeighborhoodCommentsCell () <UITableViewDelegate,UITableViewDataSource, FHUGCBaseCellDelegate>

@property(nonatomic , strong) NSMutableArray *dataList;
@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) UIView *titleView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIButton *commentBtn;
@property(nonatomic , strong) FHUGCCellManager *cellManager;
@property(nonatomic , strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic , strong) NSMutableDictionary *clientShowDict;

@end

@implementation FHDetailNeighborhoodCommentsCell

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
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-14);
        make.bottom.equalTo(self.contentView).offset(14);
    }];
    _containerView = [[UIView alloc] init];
//    _containerView.clipsToBounds = YES;
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
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 60, 50)];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:18] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"小区点评";
    [self.titleView addSubview:_titleLabel];
    
    self.commentBtn = [[UIButton alloc] init];
    [_commentBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_commentBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _commentBtn.imageView.contentMode = UIViewContentModeCenter;
    [_commentBtn setImage:[UIImage imageNamed:@"detail_questiom_ask"] forState:UIControlStateNormal];
    [_commentBtn setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    [_commentBtn setTitle:@"我要点评" forState:UIControlStateNormal];
    [_commentBtn addTarget:self action:@selector(gotoCommentPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:_commentBtn];
    
    _tableView.tableHeaderView = self.titleView;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
//        shadowImage.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)initConstaints {
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.shadowImage).offset(-20);
    }];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView);
        make.left.mas_equalTo(self.containerView).offset(15);
        make.right.mas_equalTo(self.containerView).offset(-15);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.containerView).mas_offset(-10);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleView).offset(20);
        make.left.mas_equalTo(self.titleView).offset(16);
        make.right.mas_equalTo(self.commentBtn.mas_left).offset(-10);
        make.height.mas_equalTo(25);
    }];

    [_commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleView).offset(-16);
        make.height.mas_equalTo(25);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailCommentsCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailCommentsCellModel *cellModel = (FHDetailCommentsCellModel *)data;
    self.shadowImage.image = cellModel.shadowImage;
    
    _titleView.height = cellModel.headerViewHeight;
    self.tableView.tableHeaderView = _titleView;
    
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleView).offset(cellModel.topMargin == 30?20:cellModel.topMargin);
    }];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(cellModel.viewHeight);
    }];
    if (cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll) {
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    //业主点评在不单独为卡片的时候重新布局
    if(cellModel.shadowImageType == FHHouseShdowImageTypeLR || cellModel.shadowImageType == FHHouseShdowImageTypeLBR){
        [_containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shadowImage).offset(14);
            make.left.right.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.shadowImage).offset(-20);
        }];
    }
    _titleLabel.text = cellModel.title;
    [_commentBtn setTitle:cellModel.commentTitle forState:UIControlStateNormal];
    
    self.dataList = [[NSMutableArray alloc] init];
    [_dataList addObjectsFromArray:cellModel.dataList];
    [self.tableView reloadData];
    
    if(self.dataList.count > 0){
        self.commentBtn.hidden = NO;
    }else{
        self.commentBtn.hidden = YES;
    }
}

#pragma mark delegate

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)gotoCommentPublish {

    if ([TTAccountManager isLogin]) {
        [self gotoCommentVC];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoCommentVC {
    
    FHDetailCommentsCellModel *cellModel = (FHDetailCommentsCellModel *)self.currentData;
    if(!isEmptyString(cellModel.commentsSchema)){
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:cellModel.commentsSchema];
        NSMutableDictionary *dict = @{}.mutableCopy;
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[UT_ENTER_FROM] = cellModel.tracerDict[@"page_type"];
        tracerDict[UT_LOG_PB] = cellModel.tracerDict[@"log_pb"] ?: @"be_null";
        tracerDict[UT_ELEMENT_FROM] = [self elementTypeString:FHHouseTypeNeighborhood] ?: @"be_null";
        dict[TRACER_KEY] = tracerDict;
        dict[@"neighborhood_id"] = cellModel.neighborhoodId;
        dict[@"post_content_hint"] = @"说说你对该小区的评价，小区物业、配套、停车、周边学校、邻居关系等方面都可以~最少要写10个字以上哦";
        dict[@"title"] = @"发布点评";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
    }
}

- (void)gotoLogin {
    FHDetailCommentsCellModel *cellModel = (FHDetailCommentsCellModel *)self.currentData;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *page_type = cellModel.tracerDict[@"page_type"] ?: @"be_null";
    [params setObject:page_type forKey:@"enter_from"];
    [params setObject:@"click_publisher" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wSelf gotoCommentVC];
                });
            }
        }
    }];
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

- (UIButton *)lookAllBtn {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, [UIScreen mainScreen].bounds.size.width - 60, 40)];
    button.backgroundColor = [UIColor themeGray7];
    button.imageView.contentMode = UIViewContentModeCenter;
    [button setTitle:@"查看全部" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"neighborhood_detail_v3_arrow_icon"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont themeFontRegular:14];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 20;
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -
                                                    button.imageView.frame.size.width, 0, button.imageView.frame.size.width)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, button.titleLabel.bounds.size.width, 0, - button.titleLabel.bounds.size.width)];
    [button addTarget:self action:@selector(gotoMore) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)writeCommentBtn {
    FHDetailCommentsCellModel *cellModel = (FHDetailCommentsCellModel *)self.currentData;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, [UIScreen mainScreen].bounds.size.width - 60, 40)];
    button.backgroundColor = [UIColor themeGray7];
    button.imageView.contentMode = UIViewContentModeCenter;
    [button setTitle:cellModel.contentEmptyTitle forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"detail_questiom_ask"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont themeFontRegular:14];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 20;
    [button addTarget:self action:@selector(gotoCommentPublish) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    FHDetailCommentsCellModel *cellModel = (FHDetailCommentsCellModel *)self.currentData;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, cellModel.footerViewHeight)];
    if(cellModel.totalCount > 2 && self.dataList.count > 0){
        [footView addSubview:[self lookAllBtn]];
    }else if(cellModel.dataList.count <= 0){
        [footView addSubview:[self writeCommentBtn]];
    }
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    FHDetailCommentsCellModel *cellModel = (FHDetailCommentsCellModel *)self.currentData;
    return cellModel.footerViewHeight;
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
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    [self lookAllLinkClicked:cellModel cell:nil];
}

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    // PM要求点富文本链接也进入详情页
    [self lookAllLinkClicked:cellModel cell:nil];
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

@end
