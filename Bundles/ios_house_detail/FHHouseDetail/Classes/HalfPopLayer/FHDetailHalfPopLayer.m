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

#define HEADER_HEIGHT 50
#define FOOTER_HEIGHT 60

#define AGENCY_CELL @"agency_cell"
#define INFO_CELL   @"info_cell"
#define CHECK_INFO_CELL @"check_info_cell"
#define DEAL_CELL @"deal_cell"

@interface FHDetailHalfPopLayer ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) FHDetailHalfPopTopBar *menu;
@property(nonatomic , strong) UIView *containerView;
@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) FHDetailHalfPopFooter *footer;
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
        
//        if (@available(iOS 11.0 , *)) {
//            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
        
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
        
        [self initConstraints];
        
        self.backgroundColor = [UIColor clearColor];//[[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)];
        [self addGestureRecognizer:tapGesture];
        
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
    [self dismiss:YES];
}

-(void)feedBack:(NSInteger)type
{
    if (self.feedBack) {
        __weak typeof(self) wself = self;
        self.feedBack(type, self.data, ^(BOOL success) {            
            [wself updateFooterFeedback:success];
        });
        [wself addClickAgreeLogType:type];
    }
    self.footer.actionButton.enabled = NO;
    self.footer.negativeButton.enabled = NO;
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
    }else if ([self.data isKindOfClass:[FHRentDetailDataBaseExtraModel class]]){
        
        NSString *comment = [(FHRentDetailDataBaseExtraModel *)self.data securityInformation].dialogContent.comment;
        return [FHDetailHalfPopDealFooter heightForText:comment];
    }
    return CGFLOAT_MIN;
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
    if ([self.data isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]) {
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
        
        CGFloat bgTop = CGRectGetHeight(self.bounds) - HEADER_HEIGHT - floor(contentSize.height) - safeInsets.bottom;
        CGFloat minTop = (safeInsets.top > 0)?safeInsets.top+40:64;
        if (bgTop < minTop) {
            bgTop = minTop;
            self.tableView.scrollEnabled = YES;
        }else{
            self.tableView.scrollEnabled = NO;
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
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:self.trackInfo];
    
    param[@"stay_time"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSinceDate:self.enterDate]*1000];
    
    TRACK_EVENT(@"stay_category", param);
}

@end
