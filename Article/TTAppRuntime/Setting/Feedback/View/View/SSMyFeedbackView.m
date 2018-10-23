//
//  SSMyFeedbackView.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-7.
//
//

#import "SSMyFeedbackView.h"
#import "SSFeedbackManager.h"
#import "SSFeedbackModel.h"
#import "SSFeedbackCell.h"
#import "TTPhotoScrollViewController.h"
#import "TTIndicatorView.h"
 
#import "UIImage+TTThemeExtension.h"

@interface SSMyFeedbackView()<UITableViewDataSource, UITableViewDelegate, SSFeedbackManagerDelegate, SSFeedbackCellDelegate>
{
    BOOL _isFirstReload;//default is YES
    BOOL _isLoading;
    BOOL _hasMore;
}
@property(nonatomic, retain)UITableView * listView;
@property(nonatomic, retain)NSMutableArray * feedbackModels;
@property(nonatomic, retain)SSFeedbackManager * feedbackManager;
//@property(nonatomic, retain)SSFeedbackListHeaderView * listHeaderView;
@end

@implementation SSMyFeedbackView

- (void)dealloc
{
    _feedbackManager.delegate = nil;
//    self.listHeaderView = nil;
    self.feedbackManager = nil;
    self.listView = nil;
    self.feedbackModels = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isFirstReload = YES;
        _isLoading = NO;
        _hasMore = YES;
        self.feedbackModels = [NSMutableArray arrayWithCapacity:100];
        NSArray * recentModels = [SSFeedbackManager recentFeedbackModels];
        [_feedbackModels addObjectsFromArray:recentModels];
        self.feedbackManager = [[SSFeedbackManager alloc] init];
        _feedbackManager.delegate = self;
        [self buildView];
        [self listViewReloadScrollToBottom:YES];
        [self loadDataIsLoadMore:NO];
        [self reloadThemeUI];
    }
    return self;
}


- (void)buildView
{
    self.listView = [[UITableView alloc] initWithFrame:[self frameForListView]];
    
    // fix: 没有定位到tableView最下方的问题
    self.listView.estimatedRowHeight = 0;
    self.listView.estimatedSectionFooterHeight = 0;
    self.listView.estimatedSectionHeaderHeight = 0;
    if (@available(iOS 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _listView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    _listView.backgroundColor = [UIColor clearColor];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:_listView];
    
//    self.listHeaderView = [[[SSFeedbackListHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 66.f)] autorelease];
//    _listHeaderView.backgroundColor = [UIColor clearColor];
//    _listView.tableHeaderView = _listHeaderView;
}

- (void)willAppear
{
    [super willAppear];
    [self loadDataIsLoadMore:NO];
}

- (void)willDisappear
{
    [super willDisappear];
}

- (void)themeChanged:(NSNotification *)notification
{
//    if ([_listView.tableHeaderView respondsToSelector:@selector(refreshUI)]) {
//        [_listView.tableHeaderView performSelector:@selector(refreshUI)];
//    }
}

- (CGRect)frameForListView
{
    return self.bounds;
}

- (void)listViewReloadScrollToBottom:(BOOL)scrollBottom
{
    [_listView reloadData];
    if (_isFirstReload || scrollBottom) {
        [self scrollToBottom];
        _isFirstReload = NO;
    }
}

- (void)scrollToBottom
{
    [_listView scrollRectToVisible:CGRectMake(0, _listView.contentSize.height - 10, _listView.contentSize.width, 10) animated:NO];

}


#pragma mark --  data

- (void)loadDataIsLoadMore:(BOOL)isLoadMore
{
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    if (!isLoadMore) {
//        SSFeedbackModel * model = nil;
//        if ([_feedbackModels count] > 0) {
//            model = [_feedbackModels objectAtIndex:0];
//        }
        [_feedbackManager startFetchComments:NO contextID:nil];//reload 不传ID
    }
    else {
        SSFeedbackModel * model = [_feedbackModels lastObject];
        [_feedbackManager startFetchComments:NO contextID:model.feedbackID];
    }
}

#pragma mark -- UITableViewDelegate & dataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = [_feedbackModels count];
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 300.f;
    if (indexPath.row < [_feedbackModels count]) {
        return [SSFeedbackCell heightForRowByModel:[_feedbackModels objectAtIndex:indexPath.row] listViewWidth:tableView.bounds.size.width];
    }
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"identifier";
    static NSString * loadMoreIdentifier = @"loadMoreIdentifier";
    if (indexPath.row < [_feedbackModels count]) {
        SSFeedbackModel * model = [_feedbackModels objectAtIndex:indexPath.row];
        
        SSFeedbackCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[SSFeedbackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.delegate = self;
        }
        [cell refreshFeedbackModel:model];
        return cell;
    }
    else {//
        SSLog(@"may error");
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:loadMoreIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = @"";
        return cell;
    }
}

#pragma mark -- SSFeedbackManagerDelegate

- (void)feedbackManager:(SSFeedbackManager *)manager fetchedNewModels:(NSArray *)feedbackModels userInfo:(NSDictionary *)userinfo error:(NSError *)error
{
    if (manager == _feedbackManager) {
        _isLoading = NO;
        
        BOOL hasMore = [[userinfo objectForKey:@"hasMore"] boolValue];
        BOOL isLoadMore = [[userinfo objectForKey:@"isLoadMore"] boolValue];
        _hasMore = hasMore;
        
        if (error) {
            //提示error
            NSString * tipMsg = NSLocalizedString(@"后台服务繁忙，请稍后重试?", nil);
            if (error.code == kNoNetworkErrorCode) {
                tipMsg = NSLocalizedString(@"网络不给力，请稍后重试", nil);
            }
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        }
        else {
            
            //API返回的数据是从新到旧排序，显示需要从旧到新排序
            NSArray * tmpModels = [[feedbackModels reverseObjectEnumerator] allObjects];
            
            if (!isLoadMore) {
                [_feedbackModels removeAllObjects];
                [_feedbackModels addObjectsFromArray:tmpModels];
                SSFeedbackModel * defaultModel = [SSFeedbackManager queryDefaultFeedbackModel];
                if (defaultModel != nil) {
                    if ([_feedbackModels count] == 0) {
                        [_feedbackModels addObject:defaultModel];
                    }
                    else {
                        [_feedbackModels insertObject:defaultModel atIndex:0];
                    }
                }
            }
            else {
                if ([_feedbackModels count] > 0) {
                    for (int i = 0; i < [tmpModels count]; i++) {
                        [_feedbackModels insertObject:[tmpModels objectAtIndex:i] atIndex:i];
                    }
                }
                else {
                    [_feedbackModels addObjectsFromArray:tmpModels];
                }
            }
            
            [self listViewReloadScrollToBottom:!isLoadMore];
        }
                
        [SSFeedbackManager saveFeedbackModels:_feedbackModels];
    }
}

#pragma mark -- SSFeedbackCellDelegate
- (void)feedbackCellImgButtonClicked:(SSFeedbackModel *)model
{
    if (!isEmptyString(model.imageURLStr)) {
        TTPhotoScrollViewController * showImageViewController = [[TTPhotoScrollViewController alloc] init];
        showImageViewController.imageURLs = @[model.imageURLStr];
        [showImageViewController presentPhotoScrollView];
    }
}

@end
