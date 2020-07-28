//
//  FHDetailHalfPopLayer.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHDetailHalfPopLayer.h"
#import "FHDetailHalfPopFooter.h"
#import "FHDetailHalfPopTopBar.h"
#import <Masonry/Masonry.h>
#import <FHHouseBase/FHUserTracker.h>

#import "FHDetailHalfPopLogoHeader.h"
#import "FHDetailHalfPopAgencyCell.h"
#import "FHDetailHalfPopCheckCell.h"
#import "FHDetailHalfPopInfoCell.h"
#import "FHDetailHalfPopDealCell.h"
#import "FHDetailHalfPopDealFooter.h"
#import "FHDetailCheckHeader.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHUserTracker.h>

#import "FHDetailOldModel.h"
#import "FHDetailRentModel.h"
#import <FHHouseBase/FHBaseTableView.h>

#define HEADER_HEIGHT 50
#define FOOTER_HEIGHT 60

#define AGENCY_CELL @"agency_cell"
#define INFO_CELL   @"info_cell"
#define CHECK_INFO_CELL @"check_info_cell"
#define DEAL_CELL @"deal_cell"
#define REASON_INFO_CELL @"reason_info_cell"

@interface FHDetailHalfPopLayer ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) FHDetailHalfPopTopBar *menu;
@property(nonatomic , strong) UIView *containerView;
@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) FHDetailHalfPopFooter *footer;
@property(nonatomic , assign) CGFloat bgTop;
@property(nonatomic , assign) CGFloat dragOffset;
@property(nonatomic , assign) CGPoint panLocation;
@property(nonatomic , strong) UIPanGestureRecognizer *panGesture;
@property(nonatomic , strong) id data;

//for track
@property(nonatomic , strong) NSDate *enterDate;
@property(nonatomic , strong) NSString *showKey;
@property(nonatomic , strong) NSDictionary *trackInfo;

@end

@implementation FHDetailHalfPopLayer

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        _bgView = [[UIView alloc]initWithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor whiteColor];

        __weak typeof(self) wself = self;
        _menu = [[FHDetailHalfPopTopBar alloc] initWithFrame:CGRectZero];
        _menu.headerActionBlock = ^(BOOL isClose) {
            if (isClose) {
                [wself addPopClickLog:@"cancel"];
                [wself dismiss:YES];
            }else{
                [wself report];
            }
        };
        _containerView = [[UIView alloc]initWithFrame:self.bounds];
        _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.allowsSelection = NO;
        _tableView.backgroundColor = [UIColor whiteColor];
        
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        
        if (@available(iOS 11.0 , *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentScrollableAxes;
        }
        
        _footer = [[FHDetailHalfPopFooter alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), FOOTER_HEIGHT)];
        _footer.actionBlock = ^(NSInteger positive) {
            [wself feedBack:positive];
        };
        
        _tableView.tableFooterView = _footer;
        
        [_containerView addSubview:_tableView];
        
        [_bgView addSubview:_menu];
        [_bgView addSubview:_containerView];
        
        [self addSubview:_bgView];
        
        [_tableView registerClass:[FHDetailHalfPopAgencyCell class] forCellReuseIdentifier:AGENCY_CELL];
        [_tableView registerClass:[FHDetailHalfPopCheckCell class] forCellReuseIdentifier:INFO_CELL];
        [_tableView registerClass:[FHDetailHalfPopInfoCell class] forCellReuseIdentifier:CHECK_INFO_CELL];
        [_tableView registerClass:[FHDetailHalfPopDealCell class] forCellReuseIdentifier:DEAL_CELL];
        [_tableView registerClass:[FHDetailHalfPopInfoCell class] forCellReuseIdentifier:REASON_INFO_CELL];

        [self initConstraints];
        
        self.backgroundColor = [UIColor clearColor];//[[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
        [self.bgView addGestureRecognizer:panGesture];
        panGesture.enabled = NO;
        self.panGesture = panGesture;
        
    }
    return self;
}

-(void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}

-(void)dismiss:(BOOL)animated
{
    if (animated) {
        CGRect frame = self.bgView.frame;
        frame.origin.y = CGRectGetHeight(self.bounds);
        [UIView animateWithDuration:0.3 animations:^{
            
            self.bgView.frame = frame;
            
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else{
        [self removeFromSuperview];
    }
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    
    [self addStayLog];
}

-(void)report
{
    if (self.reportBlock) {
        self.reportBlock(self.data);
    }
    [self dismiss:NO];
}

-(void)onTapAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint location = [gesture locationInView:self];
    if (CGRectContainsPoint(_bgView.frame, location)) {
        return;
    }
    [self addPopClickLog:@"cancel"];
    [self dismiss:YES];
}

-(void)feedBack:(NSInteger)type
{
    if (self.feedBack) {
        __weak typeof(self) wself = self;
        self.footer.actionButton.enabled = NO;
        self.footer.negativeButton.enabled = NO;
        self.feedBack(type, self.data, ^(BOOL success) {            
            [wself updateFooterFeedback:success];
        });
        [wself addClickAgreeLogType:type];
        NSString *clickPosition = (type == 1)?@"yes":@"no";
        [self addPopClickLog:clickPosition];
    }
}

-(void)updateFooterFeedback:(BOOL)success
{
    if (success) {        
        [self.footer changeToFeedbacked];
    }else{
        self.footer.actionButton.enabled = YES;
        self.footer.negativeButton.enabled = YES;
    }
}

-(FHDetailHalfPopLogoHeader *)header
{
    return  [[FHDetailHalfPopLogoHeader alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 77)];
}

-(void)showWithOfficialData:(FHDetailDataBaseExtraOfficialModel *)data trackInfo:(NSDictionary *)trackInfo
{
    self.enterDate = [NSDate date];
    self.trackInfo = trackInfo;
    self.data = data;    
//    [self addShowLog:@"inspection_show"];
    
    FHDetailHalfPopLogoHeader *header = [self header];
    [header updateWithTitle:data.dialogs.title tip:data.dialogs.subTitle imgUrl:data.dialogs.icon];
    
    [_footer showTip:data.dialogs.feedbackContent type:FHDetailHalfPopFooterTypeChoose positiveTitle:@"是" negativeTitle:@"否"];
    
    self.tableView.tableHeaderView = header;
    
    [self.tableView reloadData];
    
}

-(void)showDetectiveData:(FHDetailDataBaseExtraDetectiveModel *)data trackInfo:(NSDictionary *)trackInfo
{
    self.data = data;
    self.trackInfo = trackInfo;
    self.enterDate = [NSDate date];
//    [self addShowLog:@"happiness_show"];
    
    FHDetailHalfPopLogoHeader *header = [self header];
    
    [header updateWithTitle:data.dialogs.title tip:data.dialogs.subTitle imgUrl:data.dialogs.icon];
    
    [_footer showTip:data.dialogs.feedbackContent type:FHDetailHalfPopFooterTypeChoose positiveTitle:@"是" negativeTitle:@"否"];
    
    self.tableView.tableHeaderView = header;
    
    [self.tableView reloadData];
}

- (void)showDetectiveReasonInfoData:(FHDetailDataBaseExtraDetectiveReasonInfo *)data trackInfo:(NSDictionary *)trackInfo
{
    self.data = data;
    self.trackInfo = trackInfo;
    self.enterDate = [NSDate date];
    [_menu hideReportBtn];
    [_menu mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
    }];
    FHDetailHalfPopLogoHeader *header = [[FHDetailHalfPopLogoHeader alloc]initWithHalfPopType:FHDetailHalfPopTypeLeft];
    header.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 50);
    [header updateWithTitle:data.title tip:data.subTitle];
    
    [_footer showTip:data.feedbackContent type:FHDetailHalfPopFooterTypeChoose positiveTitle:@"是" negativeTitle:@"否"];
    
    self.tableView.tableHeaderView = header;
    
    [self.tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addPopShowLog];
    });
}

-(void)showDealData:(FHRentDetailDataBaseExtraModel *)data trackInfo:(NSDictionary *)trackInfo
{
    self.data = data;
    self.trackInfo = trackInfo;
    self.enterDate = [NSDate date];
//    [self addShowLog:@"remind_show"];
    
    FHDetailHalfPopLogoHeader *header = [self header];
    header.height = 47;
//    data.securityInformation.dialogs
    [header updateWithTitle:data.securityInformation.dialogs.title tip:data.securityInformation.dialogs.subTitle imgUrl:data.securityInformation.dialogs.icon];
    
    [_footer showTip:data.securityInformation.dialogs.feedbackContent type:FHDetailHalfPopFooterTypeChoose positiveTitle:@"是" negativeTitle:@"否"];
    
    self.tableView.tableHeaderView = header;
    
    [self.tableView reloadData];
}


-(void)initConstraints
{
    [_menu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.bgView);
        make.height.mas_equalTo(HEADER_HEIGHT);
    }];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.menu.mas_bottom);
//        make.height.mas_equalTo(100);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView.superview);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
}

-(void)panAction:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.panLocation = [pan locationInView:self];
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint loc = [pan locationInView:self];
            self.dragOffset = loc.y - self.panLocation.y;
            if (self.dragOffset >= 0) {
                self.bgView.top = self.bgTop + self.dragOffset;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGFloat yVelociy = [pan velocityInView:self].y;
            if (yVelociy/1000.0 > 0.3) {
                [self addPopClickLog:@"cancel"];
                [self dismiss:YES];
            } else {
                if (self.dragOffset + self.bgTop > self.height/2 && self.dragOffset > self.bgView.height/3) {
                    [self addPopClickLog:@"cancel"];
                    [self dismiss:YES];
                }else{
                    self.bgView.top = self.bgTop;
                    self.dragOffset = 0;
                }
            }
        }
            break;
        default:
            break;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    if (scrollView.isTracking) {
        if (offset.y < 0 || self.dragOffset > 0) {
            self.dragOffset -= offset.y;
            if (self.bgTop + self.dragOffset+self.bgView.height < self.height) {
                self.dragOffset = self.height - self.bgView.height - self.bgTop;
            }
            self.bgView.top = self.bgTop + self.dragOffset;
            scrollView.contentOffset = CGPointZero;
        }
    }else{
        self.dragOffset = 0;
    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.dragOffset + self.bgTop > self.height/2 && self.dragOffset > self.bgView.height/3) {
        [self addPopClickLog:@"cancel"];
        [self dismiss:YES];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.top = self.bgTop;
        }];
        self.dragOffset = 0;
    }
    
}

#pragma mark - tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.data isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        return 2;
    }else if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
        FHDetailDataBaseExtraDetectiveModel *detectiveModel = (FHDetailDataBaseExtraDetectiveModel *)self.data;
        return detectiveModel.detectiveInfo.detectiveList.count;
    }else if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]){
        FHDetailDataBaseExtraDetectiveReasonInfo *reasonInfo = (FHDetailDataBaseExtraDetectiveReasonInfo *)self.data;
        return reasonInfo.reasonList.count;
    }else if ([self.data isKindOfClass:[FHRentDetailDataBaseExtraModel class]]){
        FHRentDetailDataBaseExtraModel *extraModel = (FHRentDetailDataBaseExtraModel *)self.data;
        return extraModel.securityInformation.dialogContent.content.count;
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =  nil; //[tableView dequeueReusableCellWithIdentifier:@""];
    
    if ([self.data isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        FHDetailDataBaseExtraOfficialModel *officalData = (FHDetailDataBaseExtraOfficialModel *)self.data;
        if (indexPath.row == 0) {
            FHDetailHalfPopAgencyCell *acell = [tableView dequeueReusableCellWithIdentifier:AGENCY_CELL];
            
            [acell updateWithIcon:officalData.agency.logo.url name:officalData.agency.name tip:officalData.agency.nameSubTitle];
            cell = acell;
        }else{
            
            FHDetailHalfPopCheckCell *ccell = [tableView dequeueReusableCellWithIdentifier:INFO_CELL];
            
            [ccell updateWithTitle:officalData.agency.content tip:officalData.agency.source];
            
            cell = ccell;
        }
        
    }else if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
     
        FHDetailDataBaseExtraDetectiveModel *detectiveModel = (FHDetailDataBaseExtraDetectiveModel *)self.data;
        FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel * infoModel = detectiveModel.detectiveInfo.detectiveList[indexPath.row];
        FHDetailHalfPopInfoCell *cicell = (FHDetailHalfPopInfoCell *)[tableView dequeueReusableCellWithIdentifier:CHECK_INFO_CELL];
        [cicell updateWithModel:infoModel];
        
        cell = cicell;
        
    }else if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]){
        
        FHDetailDataBaseExtraDetectiveReasonInfo *reasonInfo = (FHDetailDataBaseExtraDetectiveReasonInfo *)self.data;
        FHDetailDataBaseExtraDetectiveReasonListItem * infoModel = reasonInfo.reasonList[indexPath.row];
        FHDetailHalfPopInfoCell *cicell = (FHDetailHalfPopInfoCell *)[tableView dequeueReusableCellWithIdentifier:REASON_INFO_CELL];
        [cicell updateWithReasonInfoItem:infoModel];
        
        cell = cicell;
        
    }else if ([self.data isKindOfClass:[FHRentDetailDataBaseExtraModel class]]){
        FHRentDetailDataBaseExtraModel *extraModel = (FHRentDetailDataBaseExtraModel *)self.data;
        FHRentDetailDataBaseExtraSecurityInformationDialogContentContentModel *dialogModel = extraModel.securityInformation.dialogContent.content[indexPath.row];
        
        FHDetailHalfPopDealCell *dcell = (FHDetailHalfPopDealCell *)[tableView dequeueReusableCellWithIdentifier:DEAL_CELL];
        [dcell updateWithModel:dialogModel];
        cell = dcell;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]) {
        return 30;
    }else if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]) {
        return 20;
    }else if ([self.data isKindOfClass:[FHRentDetailDataBaseExtraModel class]]){
        
        NSString *comment = [(FHRentDetailDataBaseExtraModel *)self.data securityInformation].dialogContent.comment;
        return [FHDetailHalfPopDealFooter heightForText:comment];
    }
    return 1;//CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]) {
        return 25;
    }
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]] || [self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]) {
        UIView *v = [[UIView alloc]init];
        v.backgroundColor = [UIColor whiteColor];
        return v;
    }else if ([self.data isKindOfClass:[FHRentDetailDataBaseExtraModel class]]){
        FHDetailHalfPopDealFooter *footer = [[FHDetailHalfPopDealFooter alloc] init];
        footer.infoLabel.text = [(FHRentDetailDataBaseExtraModel *)self.data securityInformation].dialogContent.comment;
        return footer;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]) {
        FHDetailCheckHeader *header = [[FHDetailCheckHeader alloc]init];
        header.titleLabel.text = [(FHDetailDataBaseExtraDetectiveModel *)self.data detectiveInfo].title;
        return header;
    }
 //
    return nil;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
                
        NSValue *contentSizeValue = change[NSKeyValueChangeNewKey];
        CGSize contentSize ;
        [contentSizeValue getValue:&contentSize];
        UIEdgeInsets safeInsets = UIEdgeInsetsZero;
        if (@available(iOS 11.0 , *)) {
            safeInsets = [[UIApplication sharedApplication]delegate].window.safeAreaInsets;
        }
        
//        contentSize.height = MIN(contentSize.height, self.footer.bottom);
        
//        if (@available(iOS 13.0 , *)) {
            //iOS 13下content size的高度有问题，会多20
//            contentSize.height -= 20;
//        }
        
        CGFloat headerHeight = [self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]] ? 30 : HEADER_HEIGHT;
        CGFloat bgTop = CGRectGetHeight(self.bounds) - headerHeight - floor(contentSize.height) - safeInsets.bottom;
        CGFloat minTop = (safeInsets.top > 20)?safeInsets.top+40:64;
        
        if (bgTop < minTop) {
            bgTop = minTop;
            self.tableView.scrollEnabled = YES;
            self.panGesture.enabled = NO;
        }else{
            self.tableView.scrollEnabled = NO;
            self.panGesture.enabled = YES;
        }
        
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgTop);
        }];
        
        CGRect frame = self.bgView.frame;
        frame.origin.y = CGRectGetHeight(self.bounds);
        self.bgView.frame = frame;
        frame.origin.y = bgTop;
        [UIView animateWithDuration:0.3 animations:^{
            
            self.bgView.frame = frame;
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
            
        } completion:^(BOOL finished) {
            
        }];
        self.bgTop = bgTop;
    }
}

#pragma mark - log
-(void)addClickAgreeLogType:(NSInteger)type
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:self.trackInfo];
    param[@"click_position"] = (type == 1)?@"yes":@"no";
    
    TRACK_EVENT(@"click_agree", param);
}

-(void)addStayLog
{
    if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]) {
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:self.trackInfo];
    
    param[@"stay_time"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSinceDate:self.enterDate]*1000];
    
    TRACK_EVENT(@"stay_category", param);
}

- (void)addPopShowLog
{
    if (![self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]) {
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:self.trackInfo];
    param[@"element_from"] = @"low_price_cause";

    TRACK_EVENT(@"happinesseye_cause_popup_show", param);
}

- (void)addPopClickLog:(NSString *)clickPosition
{
    if (![self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]) {
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:self.trackInfo];
    param[@"element_from"] = @"low_price_cause";
    param[@"click_position"] = clickPosition;
    
    TRACK_EVENT(@"happinesseye_cause_popup_click", param);
}

@end
