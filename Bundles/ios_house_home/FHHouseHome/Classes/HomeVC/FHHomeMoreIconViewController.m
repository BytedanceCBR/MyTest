//
//  FHHomeMoreIconViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/12/2.
//

#import "FHHomeMoreIconViewController.h"
#import "TTRoute.h"
#import "FHBaseTableView.h"
#import "FHConfigModel.h"
#import "FHHomeCellHelper.h"
#import <FHHomeEntrancesCell.h>
#import "FHEnvContext.h"
#import "UIColor+Theme.h"
#import "UIViewController+Track.h"
#import "FHHomeEntranceItemView.h"
#import "FHCommonDefines.h"
#import "UIViewAdditions.h"
#import "FHCommuteManager.h"
#import "FHUserTracker.h"
#import "TTSettingsManager.h"
#import "NSDictionary+TTAdditions.h"

@interface FHHomeMoreIconViewController ()<TTRouteInitializeProtocol,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView* contentTableView;
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property(nonatomic , strong) NSMutableArray *itemViews;


@end

@implementation FHHomeMoreIconViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj: paramObj];
    if (self) {
        self.contentTableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.ttTrackStayEnable = YES;
        self.contentTableView.delegate = self;
        self.contentTableView.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDefaultNavBar:NO];
    
    self.customNavBarView.title.text = @"工具箱";
    
    NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    NSInteger topInterger = [fhSettings tt_integerValueForKey:@"f_tool_box_try_fps_close"];
    
    if (!topInterger) {
        [self tryFPSFixUICreate];
    }else{
        [self normalCreate];
    }
    
    [self sendGoDetailTrace];
    
}

- (void)normalCreate {
    self.contentTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:self.contentTableView];
    [self.contentTableView setBackgroundColor:[UIColor themeGray8]];
    [self.view setBackgroundColor:[UIColor themeGray8]];
    self.contentTableView.scrollEnabled = NO;
    
    [self setupConstrains];
    
    [self.contentTableView registerClass:[FHHomeEntrancesCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeEntrancesCell class])];
}

- (void)tryFPSFixUICreate{
    
    CGFloat top = 0;
    CGFloat safeTop = 20;
    if (@available(iOS 11.0, *)) {
        safeTop = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].top;
    }
    
    CGFloat topSet = 44 + (safeTop == 0 ? 20 : safeTop);
    
    _itemViews = [NSMutableArray new];

    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray * items = (NSArray<FHConfigDataOpDataItemsModel> *)configData.toolboxData.items;
    
    NSInteger countPerRow = [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount;
    if(items.count > countPerRow*2){
        items = [items subarrayWithRange:NSMakeRange(0, countPerRow*2)];
    }
    NSInteger rowCount = (items.count+countPerRow-1)/countPerRow;
    NSInteger totalCount = MIN(items.count, rowCount*countPerRow);
    CGFloat ratio = SCREEN_WIDTH/375;
    
    CGRect itemFrame = CGRectMake(0, topSet, MAX(ceil(ratio*NORMAL_ICON_WIDTH),NORMAL_ITEM_WIDTH), ceil(ratio*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT));
    
    if(self.itemViews.count < totalCount){
        CGSize iconSize = CGSizeMake(ceil(NORMAL_ICON_WIDTH*ratio), ceil(NORMAL_ICON_WIDTH*ratio));
        for (NSInteger i = _itemViews.count; i < totalCount; i++) {
            FHHomeEntranceItemView *itemView = [[FHHomeEntranceItemView alloc] initWithFrame:itemFrame iconSize:iconSize];
            [itemView setBackgroundColor:[UIColor clearColor]];
            [itemView addTarget:self action:@selector(onItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.itemViews addObject:itemView];
            [self.view addSubview:itemView];
        }
    }
    
    [self.itemViews enumerateObjectsUsingBlock:^(UIView *   obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    CGFloat margin = (SCREEN_WIDTH - countPerRow*itemFrame.size.width - 2*HOR_MARGIN)/(countPerRow-1);
    UIImage *placeHolder = [UIImage imageNamed:@"icon_placeholder"];;
    for (NSInteger i = 0 ; i < totalCount; i++) {
        FHConfigDataOpDataItemsModel *model = items[i];
        FHHomeEntranceItemView *itemView = _itemViews[i];
        itemView.tag = ITEM_TAG_BASE+i;
        FHConfigDataOpDataItemsImageModel *imgModel = [model.image firstObject];
        [itemView updateWithIconUrl:imgModel.url name:model.title placeHolder:placeHolder];
        NSInteger row = i / countPerRow;
        NSInteger col = i % countPerRow;
        itemView.origin = CGPointMake(HOR_MARGIN+(itemFrame.size.width+margin)*col, row*[self.class rowHeight]+TOP_MARGIN_PER_ROW + topSet);
        [itemView setBackgroundColor:[UIColor clearColor]];
        itemView.hidden = NO;
    }
    
    [self.view setBackgroundColor:[UIColor themeHomeColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.contentTableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self sendStayPageTrace];
    [self tt_resetStayTime];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self sendStayPageTrace];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}


- (void)sendGoDetailTrace
{
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray<FHConfigDataOpDataItemsModel> * opDataArray = (NSArray<FHConfigDataOpDataItemsModel> *)configData.toolboxData.items;
    NSMutableDictionary *paramsTrace = [NSMutableDictionary new];
    [paramsTrace setValue:@"maintab" forKey:@"enter_from"];
    [paramsTrace setValue:@"tools_box" forKey:@"page_type"];
    NSMutableString *opDataIdStr = [NSMutableString new];
    BOOL isFirst = YES;
    for (FHConfigDataOpDataItemsModel * model in opDataArray) {
        if (isFirst && model.id) {
            [opDataIdStr appendString:model.id];
        }else
        {
            if (model.id) {
                [opDataIdStr appendString:[NSString stringWithFormat:@"_%@",model.id]];
            }
        }
        isFirst = NO;
    }
    [paramsTrace setValue:opDataIdStr forKey:@"tools_name"];
    [FHEnvContext recordEvent:paramsTrace andEventKey:@"go_detail"];
}

- (void)sendStayPageTrace
{
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray<FHConfigDataOpDataItemsModel> * opDataArray = (NSArray<FHConfigDataOpDataItemsModel> *)configData.toolboxData.items;
    
    NSMutableDictionary *paramsTrace = [NSMutableDictionary new];
    [paramsTrace setValue:@"maintab" forKey:@"enter_from"];
    [paramsTrace setValue:@"tools_box" forKey:@"page_type"];
    
    NSMutableString *opDataIdStr = [NSMutableString new];
    BOOL isFirst = YES;
    for (FHConfigDataOpDataItemsModel * model in opDataArray) {
        if (isFirst && model.id) {
            [opDataIdStr appendString:model.id];
        }else
        {
            if (model.id) {
                [opDataIdStr appendString:[NSString stringWithFormat:@"_%@",model.id]];
            }
        }
        isFirst = NO;
    }
    [paramsTrace setValue:opDataIdStr forKey:@"tools_name"];
    
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    paramsTrace[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHEnvContext recordEvent:paramsTrace andEventKey:@"stay_page"];
}

- (void)setupConstrains
{
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if(@available(iOS 11.0 , *)){
        safeInsets = [UIApplication sharedApplication].delegate.window.safeAreaInsets;
    }
    [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0 , *)) {
            make.top.mas_equalTo(44.f + (safeInsets.top == 0 ? 20 : safeInsets.top));
        } else {
            make.top.mas_equalTo(65);
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = NSStringFromClass([FHHomeEntrancesCell class]);
    FHHomeEntrancesCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    FHConfigDataOpDataModel *opData = [FHConfigDataOpDataModel new];
    opData.items = (NSArray<FHConfigDataOpDataItemsModel> *)configData.toolboxData.items;
    [cell.contentView setBackgroundColor:[UIColor themeGray8]];
    [FHHomeCellHelper fillFHHomeEntrancesCell:cell withModel:opData withTraceParams:@{@"enter_from":@"tools_box"}];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FHHomeEntrancesCell rowHeight] * 12;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}



-(void)onItemAction:(FHHomeEntranceItemView *)itemView
{
    NSInteger index = itemView.tag - ITEM_TAG_BASE;
    FHConfigDataOpDataItemsModel *model = nil;
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray * items = (NSArray<FHConfigDataOpDataItemsModel> *)configData.toolboxData.items;
    if(items.count > index){
        model = items[index];
    }
    
    NSMutableDictionary *dictTrace = [NSMutableDictionary new];
           [dictTrace setValue:@"maintab" forKey:@"enter_from"];
    NSDictionary *traceParams = @{@"enter_from":@"tools_box"};
       if ([traceParams isKindOfClass:[NSDictionary class]]) {
           [dictTrace addEntriesFromDictionary:traceParams];
       }
       
       //首页工具箱里面的icon追加上报
       NSString *enterFrom = traceParams[@"enter_from"];
       if (enterFrom && [enterFrom isEqualToString:@"tools_box"]) {
           [self addCLickIconLog:model andPageType:@"tools_box"];
       }else
       {
           [self addCLickIconLog:model andPageType:@"maintab"];
       }
       
       [dictTrace setValue:@"maintab_icon" forKey:@"element_from"];
       [dictTrace setValue:@"click" forKey:@"enter_type"];
       
       if ([model.logPb isKindOfClass:[NSDictionary class]] && model.logPb[@"element_from"] != nil) {
           [dictTrace setValue:model.logPb[@"element_from"] forKey:@"element_from"];
       }
       
       NSString *stringOriginFrom = model.logPb[@"origin_from"];

       NSDictionary *userInfoDict = @{@"tracer":dictTrace};
       TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
       
       if ([model.openUrl isKindOfClass:[NSString class]]) {
           NSURL *url = [NSURL URLWithString:model.openUrl];
           if ([model.openUrl containsString:@"snssdk1370://category_feed"]) {
               [FHHomeConfigManager sharedInstance].isNeedTriggerPullDownUpdate = YES;
               [FHHomeConfigManager sharedInstance].isTraceClickIcon = YES;
               [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
           }else if ([model.openUrl containsString:@"://commute_list"]){
               //通勤找房
               [[FHCommuteManager sharedInstance] tryEnterCommutePage:model.openUrl logParam:dictTrace];
           }else{
               [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
           }
       }
}

-(void)addCLickIconLog:(FHConfigDataOpDataItemsModel *)itemModel andPageType:(NSString *)pageType
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if([itemModel.logPb isKindOfClass:[NSDictionary class]]){
        [param addEntriesFromDictionary:itemModel.logPb];
    }
    param[@"log_pb"] = itemModel.logPb ?: @"be_null";
    param[@"page_type"] = pageType;
    [FHUserTracker writeEvent:@"click_icon" params:param];
}

+(CGFloat)rowHeight
{
    if([[FHEnvContext sharedInstance] getConfigFromCache].mainPageBannerOpData.items.count > 0){
        return ceil(SCREEN_WIDTH/375.f*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT)+TOP_MARGIN_PER_ROW;
    }else
    {
        return ceil(SCREEN_WIDTH/375.f*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT)+TOP_MARGIN_PER_ROW + 10;
    }
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
