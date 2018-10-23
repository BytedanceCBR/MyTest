//
//  PgcProfileListView.m
//  Article
//
//  Created by Huaqing Luo on 18/11/14.
//
//

#import "ExploreSubscribeListView.h"
#import "ExploreSubscribeDataListManager.h"
#import "ExploreEntry.h"
#import "ExploreFetchListDefines.h"
#import "SSUserSettingManager.h"
#import "ExploreSubscribePGCCell.h"
#import "SSThemed.h"
#import "NewsListLogicManager.h"
#import "ExploreAddEntryListViewController.h"
#import "ExploreEntryManager.h"
#import "ArticleBadgeManager.h"
#import "ArticleMomentProfileViewController.h"

#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "TTBadgeNumberView.h"
#import "TTViewWrapper.h"
#import "TTDeviceHelper.h"




#define AddSubscribeCellViewImageRightPadding 5

@interface AddSubscribeCellView : SSThemedView
@property(nonatomic, strong)SSThemedView *backgroundView;
@property(nonatomic, strong)SSThemedView *containerView;
@property(nonatomic, strong)SSThemedImageView *addView;
@property(nonatomic, strong)SSThemedLabel *textLabel;
@end

@implementation AddSubscribeCellView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColorThemeKey = kColorBackground4;
        self.backgroundView = [[SSThemedView alloc] initWithFrame:frame];
        
        _backgroundView.borderColorThemeKey = kColorLine7;
        _backgroundView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _backgroundView.layer.cornerRadius = 5.f;
        [self addSubview:_backgroundView];
        
        self.addView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _addView.imageName = @"addpgc_subscribe.png";
        [_addView sizeToFit];
        
        self.textLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _textLabel.textColorThemeKey = kColorText4;
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.text = NSLocalizedString(@"关注更多头条号", @"");
        [_textLabel sizeToFit];
        
        self.containerView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        [_containerView addSubview:_addView];
        [_containerView addSubview:_textLabel];
        [_backgroundView addSubview:_containerView];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _textLabel.left = _addView.right + 5;
    _containerView.size = CGSizeMake(_textLabel.right, MAX(_textLabel.height, _addView.height));
    _textLabel.centerY = (_containerView.height) / 2;
    _addView.centerY = (_containerView.height) / 2;
    _backgroundView.frame = CGRectMake(15, 16, self.width - 30, self.height - 20);
    _containerView.center = CGPointMake(_backgroundView.width / 2, (_backgroundView.height) / 2);
}


@end


@interface AddSubscribeCell : SSThemedTableViewCell
{
    AddSubscribeCellView * _cellView;
}

@end

@implementation AddSubscribeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.needMargin = YES;
        _cellView = [[AddSubscribeCellView alloc] initWithFrame:self.bounds];
        _cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_cellView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}

@end

@interface ExploreSubscribeListEmptyView : SSThemedView

@property(nonatomic, strong) SSThemedLabel * label1;
@property(nonatomic, strong) SSThemedLabel * label2;
@property(nonatomic, strong) SSThemedImageView * imageView;

@end

@implementation ExploreSubscribeListEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.imageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        [_imageView setImageName:@"subcribe_pic.png"];
        [_imageView sizeToFit];
        [self addSubview:_imageView];
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(48));
            make.centerX.equalTo(self);
        }];
        
        self.label1 = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _label1.textColorThemeKey = kColorText3;
        _label1.font = [UIFont systemFontOfSize:15.f];
        [_label1 setText:@"新文章随时提醒。"];
        [_label1 sizeToFit];
        _label1.backgroundColor = [UIColor clearColor];
        [self addSubview:_label1];
        
        [_label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imageView.mas_bottom).offset(12);
            make.centerX.equalTo(self);
        }];
        
        self.label2 = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _label2.textColorThemeKey = kColorText3;
        _label2.font = [UIFont systemFontOfSize:15.f];
        [_label2 setText:@"从这些头条号开始吧！"];
        [_label2 sizeToFit];
        _label2.backgroundColor = [UIColor clearColor];
        [self addSubview:_label2];
        
        [_label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_label1.mas_bottom).offset(5);
            make.centerX.equalTo(self);
        }];
        
        SSThemedButton *button = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        button.imageName = @"addpgc_subscribe.png";
        [button setTitle:NSLocalizedString(@"关注更多头条号", @"") forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.titleColorThemeKey = kColorText4;
        button.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        button.layer.cornerRadius = 5.f;
        button.borderColorThemeKey = kColorLine7;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);

        [self addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(_label2.mas_bottom).offset(48);
            make.height.equalTo(@(40));
        }];
        
        [button addTarget:self action:@selector(addSubscribeTapAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColorThemeKey = kColorBackground4;
    }
    
    return self;
}

- (void)addSubscribeTapAction:(UITapGestureRecognizer *)recognizer
{

    wrapperTrackEventWithCustomKeys(@"subscription", @"enter", nil, nil, @{@"source":@"card"});
    
    ExploreAddEntryListViewController * controller = [[ExploreAddEntryListViewController alloc] init];
    [[TTUIResponderHelper topNavigationControllerFor: self] pushViewController:controller animated:YES];
}

@end

@interface ExploreSubscribeListView()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL _accountChangedNeedReadloadList;
    NSInteger _needClearBadgeDataIndex;
    // BOOL _needUpdateListView;
}

@property(nonatomic, strong) UITableView * listTableView;
@property(nonatomic, strong) TTViewWrapper * wrapperView;
@property(nonatomic, strong) ExploreSubscribeListEmptyView * listEmptyView;
@property(nonatomic, strong) ExploreSubscribeDataListManager * dataListManager;
@property(nonatomic, strong) NSMutableDictionary *cellIsDisplayedDictionary;
@end

@implementation ExploreSubscribeListView

- (id)initWithFrame:(CGRect)frame topInset:(CGFloat)topinset bottomInset:(CGFloat)bottomInset
{
    self = [super initWithFrame:frame];
    if (self) {
        _accountChangedNeedReadloadList = NO;
        _needClearBadgeDataIndex = -1;
        self.isCurrentDisplayView = NO;
        
        //listTableView init
        self.listTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.listTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.listTableView.delegate = self;
        self.listTableView.dataSource = self;
        self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.listTableView];
        
        self.cellIsDisplayedDictionary = [[NSMutableDictionary alloc] init];
        
        NSString *loadingText = [SSCommonLogic isNewPullRefreshEnabled] ? nil : @"推荐中";
        __weak typeof(self) wself = self;
        [self.listTableView addPullDownWithInitText:@"下拉推荐"
                                           pullText:@"松开推荐"
                                        loadingText:loadingText
                                         noMoreText:@"暂无新数据"
                                           timeText:nil
                                        lastTimeKey:nil
                                      actionHandler:^{
                                          
                                          if (wself.delegate && [wself.delegate respondsToSelector:@selector(listViewStartLoading:)])
                                          {
                                              [wself.delegate listViewStartLoading:wself];
                                          }
                                          
                                          if (wself.listTableView.pullDownView.isUserPullAndRefresh)
                                          {
                                              wrapperTrackEvent(@"subscription", @"pull_refresh");
                                              [wself trackPullDownEventForLabel:@"refresh_pull"];
                                          }
                                          
                                          // remove the badge on the category button
                                          wself.dataListManager.hasNewUpdatesIndicator = NO;
                                          [[ArticleBadgeManager shareManger] clearSubscribeHasNewUpdatesIndicator];
                                          
                                          [wself.dataListManager fetchEntriesFromLocal:NO fromRemote:YES];
                                      }];
        
        [self.listTableView setContentInset:UIEdgeInsetsMake(topinset, 0, bottomInset, 0)];
 

        [self showEmptyView];
        
        [self reloadThemeUI];
        
        //fetchListManager init
        self.dataListManager = [ExploreSubscribeDataListManager shareManager];
        
        //init: add abserver
        [self registNotifications];
    }
    
    return self;
}

- (BOOL)isEmpty {
    return !self.listEmptyView.hidden;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)registNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCoreDataCacheClearedNotification:) name:kExploreClearedCoreDataCacheNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDataFetchFinishedNotification:) name:kExploreSubscribeFetchFinishedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSubscribeOrUnsubscribeNotification:) name:kEntrySubscribeStatusChangedNotification object:nil];

}

- (void)receiveSubscribeOrUnsubscribeNotification:(NSNotification*)notification {
    
    [self pullAndRefresh];

}

- (void)refreshListViewForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(ListDataOperationReloadFromType)fromType;
{
    [super refreshListViewForCategory:category isDisplayView:display fromLocal:fromLocal fromRemote:fromRemote reloadFromType:fromType];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStartLoading:)])
    {
        [self.delegate listViewStartLoading:self];
    }
    
    // "订阅频道"的特殊加载逻辑，由ExploreSubscribeListView自身控制
    fromRemote = NO;
    if (display)
    {
//        fromRemote = self.dataListManager.hasNewUpdatesIndicator;
        fromRemote = YES;
        
        // remove the badge on the category button
        self.dataListManager.hasNewUpdatesIndicator = NO;
        [[ArticleBadgeManager shareManger] clearSubscribeHasNewUpdatesIndicator];
    }
    
    [self.dataListManager fetchEntriesFromLocal:fromLocal fromRemote:fromRemote];
    
    
    if (fromRemote) {
        [[NewsListLogicManager shareManager] saveHasReloadForCategoryID:category.categoryID];
    }
}

- (void)fontChanged:(NSNotification *)notification
{
    // do nothing for now
    //[self reloadListView];
}

/*
 - (void)accountChanged:(NSNotification *)notification
 {
 _accountChangedNeedReadloadList = YES;
 [self pullAndRefresh];
 // [self reloadListView];
 }
 */

- (void)receiveCoreDataCacheClearedNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_accountChangedNeedReadloadList) {
            [self pullAndRefresh];
            _accountChangedNeedReadloadList = NO;
        }
    });
}

- (void)receiveDataFetchFinishedNotification:(NSNotification *)notification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStopLoading:)])
    {
        [self.delegate listViewStopLoading:self];
    }
    
    [self reloadListView];

    [self.listTableView finishPullDownWithSuccess:YES];

}

- (void)scrollToTopAnimated:(BOOL)animated
{
    [self.listTableView scrollRectToVisible:CGRectMake(0, 0, (self.listTableView.width), (self.listTableView.height)) animated:animated];
}

- (void)reloadListView
{
    // self.listEmptyView.hidden = YES;
    [self.listTableView reloadData];
    if ([self.dataListManager.items count] == 0)
    {
        [self showEmptyView];
    }
    else
    {
        [self hiddeEmptyView];
    }
}

- (void)layoutSubviews
{
    self.listEmptyView.frame = [self frameForEmptyView];
}

- (CGRect)frameForEmptyView {
    if ([TTDeviceHelper isPadDevice]) {
      
        
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        return CGRectMake(padding, self.listTableView.contentInset.top , self.frame.size.width - padding*2, self.frame.size.height - self.listTableView.contentInset.top);
        
    }
    return  CGRectMake(0, self.listTableView.contentInset.top, self.frame.size.width, self.frame.size.height - self.listTableView.contentInset.top);
}

- (void)showEmptyView
{
    if (!self.listEmptyView) {
        self.listEmptyView = [[ExploreSubscribeListEmptyView alloc] initWithFrame:[self frameForEmptyView]];
        if ([TTDeviceHelper isPadDevice]) {
            self.wrapperView = [[TTViewWrapper alloc] initWithFrame:self.bounds];
            [_wrapperView addSubview:_listEmptyView];
            _wrapperView.targetView = _listEmptyView;
            [self addSubview:_wrapperView];
        }
        else {
            [self addSubview:_listEmptyView];
        }
    }
    if ([TTDeviceHelper isPadDevice]) {
        _wrapperView.hidden = NO;
    }
    else{
        _listEmptyView.hidden = NO;
    }
}

- (void)hiddeEmptyView
{
    if ([TTDeviceHelper isPadDevice]) {
        _wrapperView.hidden = YES;
    }
    else{
        _listEmptyView.hidden = YES;
    }
}

- (void)pullAndRefresh
{
    [self.listTableView triggerPullDown];
}

- (void)scrollToTopEnable:(BOOL)enable
{
    self.listTableView.scrollsToTop = enable;
}

- (void)listViewWillEnterForground
{
    [self tryAutoReloadIfNeed];
}

- (void)tryAutoReloadIfNeed
{
    if([[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:self.currentCategory.categoryID] && [self.dataListManager.items count] > 0) {
        [self pullAndRefresh];
    }
}

#pragma mark -- UITableViewDataSource, UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [[self.dataListManager items] count];
    return count + 1; // 1 more cell for "添加订阅"
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float result = 0;
    if(indexPath.row == 0)
    {
        result = 56.f;
    }
    else if (indexPath.row - 1 < [self.dataListManager.items count])
    {
        id data = [[self.dataListManager items] objectAtIndex:indexPath.row - 1];
        if ([data isKindOfClass:[ExploreEntry class]] && [((ExploreEntry *)data).type intValue] == 1)
        {
            return [ExploreSubscribePGCCell heightForData:data cellWidth:0 listType:0];
        }
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * normalSubscribeCellIdentifier = @"normalSubscribeCellIdentifier";
    static NSString * addSubscribeCellIndentifier = @"addSubscribeCellIndentifier";
    static NSString * preventCrashCellIdentifier = @"preventCrashCellIdentifier";
    if(indexPath.row == 0)
    {
        AddSubscribeCell * cell = [tableView dequeueReusableCellWithIdentifier:addSubscribeCellIndentifier];
        if (!cell)
        {
            cell = [[AddSubscribeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addSubscribeCellIndentifier];
        }
        
        return cell;
    }
    else
    {
        NSUInteger dataIndex = indexPath.row - 1;
        id data = [[self.dataListManager items] objectAtIndex:dataIndex];
        
        if ([data isKindOfClass:[ExploreEntry class]])
        {
            ExploreEntry * entry = (ExploreEntry *)data;
            if ([entry.type intValue] == 1) // pgc
            {
                ExploreSubscribePGCCell * cell = [tableView dequeueReusableCellWithIdentifier:normalSubscribeCellIdentifier];
                if (!cell)
                {
                    cell = [[ExploreSubscribePGCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalSubscribeCellIdentifier];
                }
                
                [cell refreshWithData:entry];
                
                if (dataIndex + 1 == [self.dataListManager items].count) {
                    [cell hideBottomLine];
                }
                return cell;
            }
            else
            {
                // for future use
            }
        }
    }
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:preventCrashCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:preventCrashCellIdentifier];
    }
    cell.textLabel.text = @"";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        id data = [[self.dataListManager items] objectAtIndex:0];
        NSString *carId = @"";
        if ([data isKindOfClass:[ExploreEntry class]])
        {
            ExploreEntry * entry = (ExploreEntry *)data;
            carId = entry.mediaID.stringValue;
        }
        
        ExploreAddEntryListViewController * controller = [[ExploreAddEntryListViewController alloc] init];
        [[TTUIResponderHelper topNavigationControllerFor: self] pushViewController:controller animated:YES];
    }
    else if (indexPath.row - 1 < [self.dataListManager.items count])
    {
        NSUInteger dataIndex = indexPath.row - 1;
        id data = [self.dataListManager.items objectAtIndex:dataIndex];
        if ([data isKindOfClass:[ExploreEntry class]])
        {
            ExploreEntry * entry = data;
            if ([entry.type intValue] == 1) // pgc
            {
                if ([entry.badgeCount intValue] > 0 || [entry.isNewSubscibed boolValue])
                {
                    wrapperTrackEventWithCustomKeys(@"subscription", @"click_pgc_tip", entry.mediaID.stringValue, nil, nil);
                }
                else
                {
                    wrapperTrackEventWithCustomKeys(@"subscription", @"click_pgc", entry.mediaID.stringValue, nil, nil);
                }

                _needClearBadgeDataIndex = dataIndex;
                
                NSString *mediaID = [NSString stringWithFormat:@"%@", entry.mediaID];
                [ArticleMomentProfileViewController openWithMediaID:mediaID enterSource:kPGCProfileEnterSourceChannelSubscriptionSubscribed itemID:nil];
            }
            else
            {
                // for future use
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *row = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if(indexPath.row == 0) return;//第一个cell为添加订阅号，不参与统计
    if([[_cellIsDisplayedDictionary allKeys] containsObject:row]){
        //do nothing
    }
    else{
        
        NSUInteger dataIndex = indexPath.row - 1;
        id data = [[self.dataListManager items] objectAtIndex:dataIndex];
        
        if ([data isKindOfClass:[ExploreEntry class]])
        {
            ExploreEntry * entry = (ExploreEntry *)data;
            
            wrapperTrackEventWithCustomKeys(@"sub_old", @"sub_show_account_old", entry.mediaID.stringValue, nil, nil);
        }
        [_cellIsDisplayedDictionary setObject:@(YES) forKey:row];//记录哪些cell已经统计过了
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    self.listTableView.backgroundColor = self.backgroundColor;

}

- (void)didDisappear
{
    [super didDisappear];
    
    if (_needClearBadgeDataIndex >= 0 && _needClearBadgeDataIndex < [self.dataListManager.items count])
    {
        ExploreEntry * entry = [self.dataListManager.items objectAtIndex:_needClearBadgeDataIndex];
        if ([entry.isNewSubscibed boolValue])
        {
            [[ExploreEntryManager sharedManager] clearNewSubcribedTip:entry];
        }
        
        if ([entry.badgeCount intValue] > 0)
        {
            [[ExploreEntryManager sharedManager] clearBadgeCount:entry];
        }
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:_needClearBadgeDataIndex + 1 inSection:0];
        [((ExploreSubscribePGCCell *)[self.listTableView cellForRowAtIndexPath:indexPath]) hideBadge];
    }
    
    _needClearBadgeDataIndex = -1;
}

- (void)willAppear
{
    [super willAppear];


    [_cellIsDisplayedDictionary removeAllObjects];
    NSArray * visibleCells = [_listTableView visibleCells];
    for (UITableViewCell * cell in visibleCells) {
        if ([cell isKindOfClass:[ExploreSubscribePGCCell class]]) {
            NSIndexPath *indexPath = [_listTableView indexPathForCell:cell];
            NSString *row = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            if(indexPath.row == 0) return;//第一个cell为添加订阅号，不参与统计
            if([[_cellIsDisplayedDictionary allKeys] containsObject:row]){
                //do nothing
            }
            else{
                NSUInteger dataIndex = indexPath.row - 1;
                id data = [[self.dataListManager items] objectAtIndex:dataIndex];
                
                if ([data isKindOfClass:[ExploreEntry class]])
                {
                    ExploreEntry * entry = (ExploreEntry *)data;
                    
                    wrapperTrackEventWithCustomKeys(@"sub_old", @"sub_show_account_old", entry.mediaID.stringValue, nil, nil);
                }
                [_cellIsDisplayedDictionary setObject:@(YES) forKey:row];//记录哪些cell已经统计过了
            }
        }
    }
    
    // Ugly code
    // 用户通过"订阅更多头条号"进入到"头条号"并添加新的PGC后返回到“订阅频道”时不应显示“小红点”
    if (!self.dataListManager.hasNewUpdatesIndicator)
    {
        [[ArticleBadgeManager shareManger] clearSubscribeHasNewUpdatesIndicator];
    }
}

- (void)willDisappear{
    [super willDisappear];
}

@end
