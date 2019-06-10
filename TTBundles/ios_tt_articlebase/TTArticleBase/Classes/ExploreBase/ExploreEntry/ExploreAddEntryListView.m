//
//  ExploreAddEntryListView.m
//  Article
//
//  Created by Zhang Leonardo on 14-11-23.
//
//

#import "ExploreAddEntryListView.h"
#import "ArticleTitleImageView.h"
#import "ExploreEntry.h"
#import "ExploreEntryGroup.h"
#import "ExploreAddEntryGroupCell.h"
#import "ExploreAddEntryListCell.h"
#import "ExploreEntryManager.h"
#import "FriendDataManager.h"
#import "NetworkUtilities.h"
#import "SSNavigationBar.h"

#import "UIImage+TTThemeExtension.h"
#import <TTAccountBusiness.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import "ExploreEntryDefines.h"
#import "ArticleURLSetting.h"

#define kArticleXPSubscriptionChannelListWidth 70

static NSInteger subscribeCount = 0;

@interface ExploreAddEntryListView ()
<
TTAccountMulticastProtocol
> {
    BOOL                    _hasFetchedRemoteData;
    NSInteger               _currentChannelIndex;
}
@property (nonatomic, strong) NSString *needShowGroupID;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UITableView *channelGroupTableView;
@property (nonatomic, strong) UITableView *channelListTableView;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property(nonatomic, retain) NSArray * entryGroups;

@end

@implementation ExploreAddEntryListView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _channelGroupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kArticleXPSubscriptionChannelListWidth, CGRectGetMaxY(self.frame)) style:UITableViewStylePlain];
        _channelGroupTableView.delegate = self;
        _channelGroupTableView.dataSource = self;
        _channelGroupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _channelGroupTableView.rowHeight = [ExploreAddEntryGroupCell defaultHeight];
        if (@available(iOS 11.0, *)) {
            _channelGroupTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [self addSubview:_channelGroupTableView];
        
        _channelListTableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_channelGroupTableView.frame), CGRectGetMinY(_channelGroupTableView.frame), CGRectGetWidth(self.frame)-CGRectGetMaxX(_channelGroupTableView.frame), CGRectGetHeight(_channelGroupTableView.frame)) style:UITableViewStylePlain];
        _channelListTableView.delegate = self;
        _channelListTableView.dataSource = self;
        _channelListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _channelListTableView.rowHeight = [ExploreAddEntryListCell defaultHeight];
        if (@available(iOS 11.0, *)) {
            _channelListTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [self addSubview:_channelListTableView];
        
        _currentChannelIndex = 0;
        
        [self selectInitialGroup];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.frame = CGRectMake(0, 0, 30, 30);
        [self addSubview:_activityIndicatorView];
        
        // 监听用户登录状态的变化，用户退出登录的通知
        [TTAccount addMulticastDelegate:self];

        [self reloadThemeUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame showGroupID:(NSString *)needShowGroupID
{
    self = [self initWithFrame:frame];
    if(self) {
        self.needShowGroupID = needShowGroupID;
        [self selectInitialGroup];
    }
    
    return self;
}

- (void)themeChanged:(NSNotification*)notification
{
    
    [_backButton setImage:[UIImage themedImageNamed:@"titlebar_details_go_back.png"] forState:UIControlStateNormal];
    [_backButton setImage:[UIImage themedImageNamed:@"titlebar_details_go_back_press.png"] forState:UIControlStateHighlighted];

    self.backgroundColor = [UIColor colorWithDayColorName:@"f5f5f5" nightColorName:@"303030"];
    _channelGroupTableView.backgroundColor = [UIColor colorWithDayColorName:@"f5f5f5" nightColorName:@"303030"];
    _channelListTableView.backgroundColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"252525"];
//    _channelListTableView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self trySSLayoutSubviews];
    _channelListTableView.contentInset = _channelGroupTableView.contentInset;
    
    _channelListTableView.frame = CGRectMake(CGRectGetMaxX(_channelGroupTableView.frame), CGRectGetMinY(_channelGroupTableView.frame), CGRectGetWidth(self.frame)-CGRectGetMaxX(_channelGroupTableView.frame), CGRectGetHeight(_channelGroupTableView.frame));
}

- (void)ssLayoutSubviews
{
    [super ssLayoutSubviews];
    [self updateFrames];
}

- (void)updateThemes
{
}

- (void)updateFrames
{
    _channelGroupTableView.frame = CGRectMake(0, 0, kArticleXPSubscriptionChannelListWidth, CGRectGetMaxY(self.frame));
    _channelListTableView.frame = CGRectMake(CGRectGetMaxX(_channelGroupTableView.frame), CGRectGetMinY(_channelGroupTableView.frame), CGRectGetWidth(self.frame)-CGRectGetMaxX(_channelGroupTableView.frame), CGRectGetHeight(_channelGroupTableView.frame));
    
    _activityIndicatorView.center = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height / 2.f);
}

- (void)willAppear
{
    [super willAppear];
    if ([_entryGroups count] == 0) {
        [_activityIndicatorView startAnimating];
        
        if (!_hasFetchedRemoteData && TTNetworkConnected()) {
            _hasFetchedRemoteData = YES;
            [self startGetEntryGroups];
        }
        else {
            [self loadGroupsAndReloadList];
        }
    }
}

- (void)willDisappear
{
    [super willDisappear];
}

- (void)loadGroupsAndReloadList
{
    self.entryGroups = [self getEntryGroups];
    [_activityIndicatorView stopAnimating];
    [_channelListTableView reloadData];
    
    [self selectInitialGroup];
}

- (void)selectInitialGroup
{
    if([self tableView:_channelGroupTableView numberOfRowsInSection:0] > 0) {
        NSIndexPath *indexPath = nil;
        if(self.needShowGroupID) {
            ExploreEntryGroup *group = [_entryGroups firstObject];
            if(group) {
                indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                _currentChannelIndex = [indexPath row];
                self.needShowGroupID = nil;
            }
        } else {
            indexPath = [NSIndexPath indexPathForRow:_currentChannelIndex inSection:0];
        }
        if(indexPath) {
            [_channelGroupTableView reloadData];
            [_channelGroupTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            [_channelGroupTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            if (_channelGroupTableView.indexPathForSelectedRow.row != indexPath.row || _channelGroupTableView.indexPathForSelectedRow.section != indexPath.section) {
                [self tableView:_channelGroupTableView didSelectRowAtIndexPath:indexPath];
            }
        }
    }
}
 



#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == _channelGroupTableView) {
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(tableView == _channelGroupTableView) {
        return [_entryGroups count];
    }

    if(_currentChannelIndex >= [_entryGroups count]) {
        return 0;
    }
    
    ExploreEntryGroup *group = _entryGroups[_currentChannelIndex];
    
    return group.entryList.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *channelCellIdentifier = @"channelCellIdentifier";
    static NSString *subscriptionCellIdentifier = @"subscriptionCellIdentifier";
    
    if(tableView == _channelGroupTableView) {
        ExploreAddEntryGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
        if(!cell) {
            cell = [[ExploreAddEntryGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:channelCellIdentifier];
        }
        
        ExploreEntryGroup *group = _entryGroups[indexPath.row];
        [cell setGroupTitle:group.name];
        if (indexPath.row == _currentChannelIndex) {
            cell.selected = YES;
        }
        
        return cell;
    }
    
    ExploreAddEntryListCell *cell = [tableView dequeueReusableCellWithIdentifier:subscriptionCellIdentifier];
    if(!cell) {
        cell = [[ExploreAddEntryListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subscriptionCellIdentifier];
    }
    ExploreEntryGroup *group = _entryGroups[_currentChannelIndex];
    ExploreEntry *channel = nil;
    channel = group.entryList[indexPath.row];
    
    [cell fillWithChannelInfo:channel];
    cell.cellDelegate = self;
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _channelGroupTableView) {
        [_channelListTableView setContentOffset:CGPointMake(0,-_channelListTableView.contentInset.top) animated:NO];
        _currentChannelIndex = indexPath.row;
        [_channelListTableView reloadData];
        wrapperTrackEvent(@"subscription", @"change_cat");
        return;
    }
    if (_currentChannelIndex < [_entryGroups count]) {
        ExploreEntryGroup *group = _entryGroups[_currentChannelIndex];
        if (indexPath.row < [group.entryList count]) {

            wrapperTrackEvent(@"subscription", @"enter_pgc");
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ExploreAddEntryListCellDelegate
- (void)channelListCell:(ExploreAddEntryListCell *)cell subscribeChannel:(ExploreEntry *)channel
{
//    if ([TTFirstConcernManager firstTimeGuideEnabled]){//第一次关注动画
//        TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//        [manager showFirstConcernAlertViewWithDismissBlock:nil];
//    }
    
    //[[ExploreEntryManager sharedManager] subscribeExploreEntry:channel notify:YES notifyFinishBlock:nil];
    [self follow:channel actionType:FriendActionTypeFollow];
}

- (void)channelListCell:(ExploreAddEntryListCell *)cell unsubscribeChannel:(ExploreEntry *)channel
{
    //[[ExploreEntryManager sharedManager] unsubscribeExploreEntry:channel notify:YES notifyFinishBlock:nil];
    [self follow:channel actionType:FriendActionTypeUnfollow];
}

#pragma mark - TTAccountMulticastProtocol
 
- (void)onAccountLogout
{
    subscribeCount = 0;
}

- (void)follow:(ExploreEntry *)channel actionType:(FriendActionType)actionType {
    NSString *userID = [NSString stringWithFormat:@"%@", channel.userID];
    NSMutableDictionary *followDic = [NSMutableDictionary dictionary];
    [followDic setValue:userID forKey:@"id"];
    //[followDic setValue:@(FriendFollowNewReasonAddEntryList) forKey:@"new_reason"];
    [followDic setValue:@(TTFollowNewSourceAddEntryList) forKey:@"new_source"];
    
    if (actionType == FriendActionTypeFollow) {
        [[TTFollowManager sharedManager] follow:followDic completion:nil];
    } else {
        [[TTFollowManager sharedManager] unfollow:followDic completion:nil];
    }
}

#pragma mark -- get entry groups

- (void)startGetEntryGroups
{
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting articleEntryListURLString] params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        if(!error)
        {
            // 获取推荐Channel列表
            NSArray *tmpData = [jsonObj tt_arrayValueForKey:@"data"];

            [tmpData enumerateObjectsUsingBlock:^(NSDictionary *channelGroupDic, NSUInteger idx, BOOL *stop) {
                if (![channelGroupDic isKindOfClass:[NSDictionary class]]) {
                    return;
                }
                NSMutableDictionary *fixedChannelGroupInfo = [NSMutableDictionary dictionaryWithDictionary:channelGroupDic];
                [fixedChannelGroupInfo setObject:[NSString stringWithFormat:@"%@", channelGroupDic[@"id"]] forKey:@"id"];
                ExploreEntryGroup *group = [ExploreEntryGroup objectWithDictionary:fixedChannelGroupInfo];
                group.orderIndex = idx;
                [group save];
                
                NSArray *channelList = [fixedChannelGroupInfo tt_arrayValueForKey:@"list"];
                
                NSMutableOrderedSet *channelOrderedSet = [NSMutableOrderedSet orderedSet];
                [channelList enumerateObjectsUsingBlock:^(NSDictionary *channelInfo, NSUInteger channelIndex, BOOL *channelStop) {
                    if (![channelInfo isKindOfClass:[NSDictionary class]]) {
                        return;
                    }
                    NSMutableDictionary *fixedChannelInfo = [NSMutableDictionary dictionaryWithDictionary:channelInfo];
                    [fixedChannelInfo setObject:[NSString stringWithFormat:@"%@", channelInfo[@"id"]] forKey:@"id"];
                    
                    //此处判断当前版本是否支持该channel
                    if ([fixedChannelInfo[@"type"] integerValue] != ExploreEntryTypePGC) {
                        return ;
                    }
                    
                    ExploreEntry *channel = [ExploreEntry objectWithDictionary:fixedChannelInfo];
                    
                    if(channel) {
                        channel.originIndex = @(channelIndex);
                        [channel save];
                        [channelOrderedSet addObject:channel];
                    }
                }];
                
                group.entryList = channelOrderedSet;
                
            }];
        }
        
        [self loadGroupsAndReloadList];
    }];
    
}

- (NSArray *)getEntryGroups
{
    NSArray *entryGroups = [ExploreEntryGroup objectsWithQuery:nil orderBy:@"orderIndex ASC" offset:0 limit:NSIntegerMax];
    return entryGroups;
}

@end
