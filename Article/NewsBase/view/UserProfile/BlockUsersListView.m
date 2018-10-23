//
//  BlockUsersListView.m
//  Article
//
//  Created by Huaqing Luo on 8/3/15.
//
//

#import "BlockUsersListView.h"
#import "TTBlockManager.h"
#import "NetworkUtilities.h"
#import "BlockUsersListCell.h"
#import "ArticleFriendModel.h"

#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"


static float const kBlockUserListCellHeight = 66;

#define RequestBlockUsersNum 50
#define kBlockUserCellIndentifier @"kBlockUserCellIndentifier"

@interface BlockUsersListView () <UITableViewDataSource, UITableViewDelegate, TTBlockManagerDelegate, BlockUsersListCellDelegate,UIViewControllerErrorHandler>
{
    BOOL _canLoadMore;
    NSInteger _offset;
}

@property (nonatomic, strong) SSThemedTableView       * listView;
@property (nonatomic, strong) NSMutableArray          * blockUsers;

@property (nonatomic, strong) TTBlockManager        * dataManager;

@end

@implementation BlockUsersListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _canLoadMore = NO;
        _offset = 0;
        
        self.dataManager = [[TTBlockManager alloc] init];
        _dataManager.delegate = self;
        
        self.blockUsers = [NSMutableArray array];
        
        self.listView = [[SSThemedTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.backgroundView = nil;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_listView];
        
        __weak typeof(self) wself = self;
        [_listView tt_addDefaultPullDownRefreshWithHandler:^{
            [wself tt_startUpdate];
            [wself loadData];
        }];
        
        _listView.hasMore = _canLoadMore;
        [_listView tt_addDefaultPullUpLoadMoreWithHandler:^{
            [wself tt_startUpdate];
            [wself loadMore];
        }];
        
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    _listView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

#pragma mark -- View Lifecycles

- (void)didAppear
{
    [super didAppear];
    [self loadData];
}

#pragma mark -- UIViewControllerErrorHandler
- (BOOL)tt_hasValidateData {
    if ([_blockUsers count]>0) {
        return YES;
    }
    return NO;
}

#pragma mark -- private

- (void)loadData
{
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"无网络链接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
    
        _offset = 0;
        [_dataManager getBlockedUsersWithOffset:_offset count:RequestBlockUsersNum];
        
    }
}

- (void)loadMore
{
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"无网络链接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        [_dataManager getBlockedUsersWithOffset:_offset count:RequestBlockUsersNum];
        
    }
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_blockUsers count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row < [_blockUsers count]) {
        NewFriendListCellUnit *cellUnit = [[NewFriendListCellUnit alloc] initWithFrame:CGRectMake(0, 0, tableView.width, kBlockUserListCellHeight)];
        ArticleFriendModel *model = [_blockUsers objectAtIndex:row];
        [cellUnit setFriendModel:model];
        return [cellUnit calculateHeight];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row < [_blockUsers count]) {
        BlockUsersListCell * cell = [tableView dequeueReusableCellWithIdentifier:kBlockUserCellIndentifier];
        if (!cell) {
            cell = [[BlockUsersListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBlockUserCellIndentifier width:(_listView.width)];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell setBlockUser:[_blockUsers objectAtIndex:row]];
        [cell refreshUI];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row < [_blockUsers count]) {
        
        wrapperTrackEvent(@"blacklist", @"list_click_information");
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -- TTBlockManagerDelegate

- (void)blockUserManager:(TTBlockManager *)manager getBlockedUsersResult:(NSDictionary *)result error:(NSError *)error;
{
    
    NSString * msg;
    if (!error) {
        
        if (_offset == 0) {
            [_blockUsers removeAllObjects];
        }

        NSDictionary * data = result;
        _canLoadMore = NO;
        if ([data valueForKey:@"has_more"]) {
            _canLoadMore = [[data valueForKey:@"has_more"] boolValue];
        }
        if ([data valueForKey:@"users"]) {
            NSArray * blockUsers = [data valueForKey:@"users"];
            for (NSDictionary * userDict in blockUsers) {
                ArticleFriendModel * blockUser = [[ArticleFriendModel alloc] initWithDictionary:userDict];
                [_blockUsers addObject:blockUser];
            }
            _offset += [blockUsers count];

            msg = @"暂无数据";

            [_listView reloadData];
        }
    } else {
        msg = @"获取数据失败,请稍后重试";
    }
    
    if (self.listView.pullDownView.isUserPullAndRefresh) {
        [self.listView finishPullDownWithSuccess:!error];
    }
    else
        [self.listView finishPullUpWithSuccess:!error];

    
    self.ttViewType = TTFullScreenErrorViewTypeBlacklistEmpty;
    [self tt_endUpdataData:NO error:error tip:msg tipTouchBlock:nil];

}


#pragma mark -- BlockUsersListCellDelegate

- (void)blockUsersListCell:(BlockUsersListCell *)cell didBlockUser:(BOOL)blocking
{
    if (blocking) {
        --_offset;
    } else {
        ++_offset;
    }
}

@end
