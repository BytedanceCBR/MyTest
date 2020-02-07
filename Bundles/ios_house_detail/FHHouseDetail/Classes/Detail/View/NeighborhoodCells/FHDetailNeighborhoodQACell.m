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
#import "FHDetailPriceMarkerView.h"
#import "UIView+House.h"
#import <FHHouseBase/FHUserTracker.h>
#import "FHFeedUGCCellModel.h"
#import "FHNeighbourhoodQuestionCell.h"
#import "TTAccountManager.h"

#define cellId @"cellId"

@interface FHDetailNeighborhoodQACell () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) NSMutableArray *dataList;
@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) UIView *titleView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIButton *questionBtn;

@end

@implementation FHDetailNeighborhoodQACell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
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
    self.contentView.backgroundColor = [UIColor themeGray7];
    self.tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.layer.masksToBounds = YES;
    _tableView.layer.cornerRadius = 10;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
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
    
    [self.contentView addSubview:_tableView];
    
    [_tableView registerClass:[FHNeighbourhoodQuestionCell class] forCellReuseIdentifier:cellId];
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, 65)];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:18] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"小区问答";
    [self.titleView addSubview:_titleLabel];
    
    self.questionBtn = [[UIButton alloc] init];
    [_questionBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_questionBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _questionBtn.imageView.contentMode = UIViewContentModeCenter;
    [_questionBtn setImage:[UIImage imageNamed:@"detail_questiom_ask"] forState:UIControlStateNormal];
    [_questionBtn setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    _questionBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_questionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_questionBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    [_questionBtn setTitle:@"我要提问" forState:UIControlStateNormal];
    [_questionBtn addTarget:self action:@selector(gotoWendaPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:_questionBtn];
    
    _tableView.tableHeaderView = self.titleView;
}

- (void)initConstaints {
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(300);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleView).offset(30);
        make.left.mas_equalTo(self.titleView).offset(16);
        make.right.mas_equalTo(self.questionBtn.mas_left).offset(-10);
        make.height.mas_equalTo(25);
    }];

    [_questionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleView).offset(-16);
        make.height.mas_equalTo(25);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailQACellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailQACellModel *cellModel = (FHDetailQACellModel *)data;
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(cellModel.viewHeight);
    }];

    _titleLabel.text = cellModel.title;
    [_questionBtn setTitle:cellModel.askTitle forState:UIControlStateNormal];
    
    self.dataList = [[NSMutableArray alloc] init];
    [_dataList addObject:[FHFeedUGCCellModel modelFromFake]];
    [_dataList addObject:[FHFeedUGCCellModel modelFromFake]];
    [self.tableView reloadData];
}

#pragma mark delegate
//- (void)addClickPriceTrendLog
//{
//    NSMutableDictionary *params = @{}.mutableCopy;
//    NSDictionary *traceDict = [self.baseViewModel detailTracerDic];
//
//    //    1. event_type：house_app2c_v2
//    //    2. page_type：页面类型,{'新房详情页': 'new_detail', '二手房详情页': 'old_detail', '小区详情页': 'neighborhood_detail'}
//    //    3. rank
//    //    4. origin_from
//    //    5. origin_search_id
//    //    6.log_pb
//
//    params[@"page_type"] = traceDict[@"page_type"] ? : @"be_null";
//    params[@"rank"] = traceDict[@"rank"] ? : @"be_null";
//    params[@"origin_from"] = traceDict[@"origin_from"] ? : @"be_null";
//    params[@"origin_search_id"] = traceDict[@"origin_search_id"] ? : @"be_null";
//    params[@"log_pb"] = traceDict[@"log_pb"] ? : @"be_null";
//    [FHUserTracker writeEvent:@"click_price_trend" params:params];
//}
//

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)gotoWendaPublish {
//    NSMutableDictionary *params = @{}.mutableCopy;
//    params[UT_ELEMENT_TYPE] = @"question_icon";
//    params[UT_PAGE_TYPE] = [self pageType];
//    TRACK_EVENT(@"click_options", params);
    
    if ([TTAccountManager isLogin]) {
        [self gotoWendaVC];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoWendaVC {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"sslocal://ugc_wenda_publish"];
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
//    tracerDict[UT_ENTER_FROM] = [self pageType];
    dict[TRACER_KEY] = tracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    NSString *page_type = @"nearby_list";
//    if (self.listType == FHCommunityFeedListTypeMyJoin) {
//        page_type = @"my_join_list";
//    } else  if (self.listType == FHCommunityFeedListTypeNearby) {
//        page_type = @"nearby_list";
//    }
//    [params setObject:page_type forKey:@"enter_from"];
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
                    [wSelf gotoWendaVC];
                });
            }
        }
    }];
}

- (void)gotoMore {
    NSURL *url = [NSURL URLWithString:@"sslocal://ugc_wenda_list"];
    NSMutableDictionary *dict = @{}.mutableCopy;
//    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    //    tracerDict[UT_ENTER_FROM] = [self pageType];
//    dict[TRACER_KEY] = tracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
//        [self traceClientShowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        FHNeighbourhoodQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) {
            cell = [[FHNeighbourhoodQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
//        cell.delegate = self;
//        cellModel.tracerDic = [self trackDict:cellModel rank:indexPath.row];
        
        if(indexPath.row < self.dataList.count){
            [cell refreshWithData:cellModel];
        }
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    FHDetailQACellModel *cellModel = (FHDetailQACellModel *)self.currentData;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, cellModel.footerViewHeight)];
    UIButton *lookAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, 10, footView.bounds.size.width - 32, 40)];
    lookAllBtn.backgroundColor = [UIColor themeGray7];
    lookAllBtn.imageView.contentMode = UIViewContentModeCenter;
    [lookAllBtn setTitle:@"查看全部" forState:UIControlStateNormal];
    [lookAllBtn setImage:[UIImage imageNamed:@"detail_question_right_arror"] forState:UIControlStateNormal];
    [lookAllBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    lookAllBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [lookAllBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [lookAllBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    lookAllBtn.layer.masksToBounds = YES;
    lookAllBtn.layer.cornerRadius = 20;
    [lookAllBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -
                                                    lookAllBtn.imageView.frame.size.width, 0, lookAllBtn.imageView.frame.size.width)];
    [lookAllBtn setImageEdgeInsets:UIEdgeInsetsMake(0, lookAllBtn.titleLabel.bounds.size.width, 0, - lookAllBtn.titleLabel.bounds.size.width)];
    [lookAllBtn addTarget:self action:@selector(gotoMore) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:lookAllBtn];
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    FHDetailQACellModel *cellModel = (FHDetailQACellModel *)self.currentData;
    return cellModel.footerViewHeight;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        return [FHNeighbourhoodQuestionCell heightForData:cellModel];
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
//    self.currentCellModel = cellModel;
//    self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
//    [self jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

@end
