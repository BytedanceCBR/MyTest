//
//  TTVideoAlbumView.m
//  Article
//
//  Created by 刘廷勇 on 16/1/6.
//
//

#import "TTVideoAlbumView.h"
#import "TTDetailNatantRelateReadView.h"
#import "TTAlphaThemedButton.h"
#import "TTVideoAlbumFetcher.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIButton+TTAdditions.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTDeviceHelper.h"
#import "TTTrackerWrapper.h"
#import "TTUIResponderHelper.h"
#import "TTVRelatedItem+TTVArticleProtocolSupport.h"


#define kTopViewHeight 44.0

@interface TTVideoAlbumTableViewCell : SSThemedTableViewCell

@property (nonatomic, strong) Article *article;
@property (nonatomic, strong) UIView *cellView;
@property (nonatomic, assign) BOOL isCurrentPlaying;

@end

@implementation TTVideoAlbumTableViewCell

- (void)setArticle:(Article *)article
{
    if (_article != article) {
        _article = article;
        [self refresh];
    }
}

- (void)refresh {
    TTDetailNatantRelateReadView *cellView = (TTDetailNatantRelateReadView *)self.cellView;
    [cellView refreshArticle:self.article];
    [cellView refreshTitleWithTags:nil];
    [cellView hideFromLabel:YES];
    [cellView hideBottomLine:YES];
    
    if ([self.cellView respondsToSelector:NSSelectorFromString(@"commentCountLabel")]) {
        UILabel *countLabel = [self.cellView valueForKey:@"commentCountLabel"];
        NSString *playCountString = [TTBusinessManager formatCommentCount:[[self.article.videoDetailInfo objectForKey:VideoWatchCountKey] longLongValue]];
        countLabel.text = [NSString stringWithFormat:@"%@次播放", playCountString];
        [countLabel sizeToFit];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.cellView.frame =self.contentView.bounds;
    [self refresh];
}

- (UIView *)cellView
{
    if (!_cellView) {
        TTDetailNatantRelateReadView *cellView = [TTDetailNatantRelateReadView genViewForArticle:self.article width:self.width infoFlag:@1 forVideoDetail:YES];
        cellView.viewModel.pushAnimation = NO;
        cellView.viewModel.isSubVideoAlbum = YES;
        _cellView = cellView;
        _cellView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_cellView];
    }
    return _cellView;
}

- (void)setIsCurrentPlaying:(BOOL)isCurrentPlaying
{
    if (_isCurrentPlaying != isCurrentPlaying) {
        _isCurrentPlaying = isCurrentPlaying;
        ((TTDetailNatantRelateReadView *)self.cellView).viewModel.isCurrentPlaying = isCurrentPlaying;
    }
}

@end


@interface TTVideoAlbumView () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIViewControllerErrorHandler>
{
    BOOL didBeginDraggingFromTop;
}

@property (nonatomic, copy) NSArray *albumItems;

@property (nonatomic, strong) SSThemedView *topView;
@property (nonatomic, strong) SSThemedLabel *albumName;
@property (nonatomic, strong) SSThemedLabel *albumSource;
@property (nonatomic, strong) TTAlphaThemedButton *closeButton;
@property (nonatomic, strong) SSThemedView *seperator;
@property (nonatomic, strong) SSThemedTableView *albumTableView;
@property (nonatomic, assign) NSInteger currentPlayingIndex;
@property (nonatomic, assign) NSTimeInterval startTime;


@end

@implementation TTVideoAlbumView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentPlayingIndex = -1;
        self.backgroundColorThemeKey = kColorBackground4;
        [self addSubview:self.topView];
        [self addSubview:self.albumTableView];
    }
    return self;
}

- (void)fetchAlbum
{
    [self tt_startUpdate];
    if (self.item) {
        [TTVideoAlbumFetcher startFetchWithURL:self.item.videoItem.album.URL completion:^(NSArray *albums, NSError *error) {
            if (albums.count > 0) {
                self.albumItems = albums;
            }
            [self tt_endUpdataData:NO error:error];
        }];
    }
    else{
        [TTVideoAlbumFetcher startFetchWithURL:self.article.sourceURL completion:^(NSArray *albums, NSError *error) {
            if (albums.count > 0) {
                self.albumItems = albums;
            }
            [self tt_endUpdataData:NO error:error];
        }];
    }
}

- (void)refreshData
{
    [self fetchAlbum];
}

- (void)emptyViewBtnAction
{
    [self fetchAlbum];
}

- (BOOL)tt_hasValidateData
{
    if ([self.albumItems count] > 0) {
        return YES;
    }
    return NO;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && newSuperview != [TTUIResponderHelper mainWindow]) {
        if ([self.albumItems count] == 0) {
            [self fetchAlbum];
        }
    }
}

- (void)setAlbumItems:(NSArray *)albumItems
{
    if (_albumItems != albumItems) {
        _albumItems = albumItems;
        [self reload];
        [self scrollToCurrentPlayingCell];
    }
}

- (void)setArticle:(Article *)article
{
    if (_article != article) {
        _article = article;
        NSString *leftTitle = @"合辑";
        NSString *logoText = _article.relatedVideoExtraInfo[kArticleInfoRelatedVideoTagKey];
        if (!isEmptyString(logoText)) {
            leftTitle = logoText;
        }
        self.albumName.text = [leftTitle stringByAppendingFormat:@"：%@" ,_article.title];
        self.albumSource.text = _article.source;
        
        self.albumItems = nil;
        [self fetchAlbum];
    }
}

- (void)setItem:(TTVRelatedItem *)item
{
    if (_item != item) {
        _item = item;
        NSString *leftTitle = @"合辑";
        NSString *logoText = item.relatedVideoExtraInfo[kArticleInfoRelatedVideoTagKey];
        if (!isEmptyString(logoText)) {
            leftTitle = logoText;
        }
        self.albumName.text = [leftTitle stringByAppendingFormat:@"：%@" ,item.title];
        self.albumSource.text = item.source;
        
        self.albumItems = nil;
        [self fetchAlbum];
    }
}


- (void)setCurrentPlayingArticle:(Article *)currentPlayingArticle
{
    if (_currentPlayingArticle != currentPlayingArticle) {
        _currentPlayingArticle = currentPlayingArticle;
        if ([_currentPlayingArticle isVideoSubject]) {
            [self scrollToCurrentPlayingCell];
        } else {
            [self dismissSelf];
        }
    }
    _startTime = CFAbsoluteTimeGetCurrent();

}

- (void)updateConstraints
{
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(kTopViewHeight);
    }];
    
    [self.albumTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.topView.mas_bottom);
    }];
    
    [self.albumName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(12);
        make.centerY.equalTo(self.topView);
    }];
    
    [self.albumSource mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.albumName.mas_right).offset(6);
        make.right.lessThanOrEqualTo(self.topView).offset(-60);
        make.centerY.equalTo(self.topView);
    }];
    
    [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topView);
        make.right.equalTo(self.topView).offset(-12);
    }];
    
    [self.seperator mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(12);
        make.right.equalTo(self.topView).offset(-12);
        make.bottom.equalTo(self.topView);
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    [super updateConstraints];
}

- (SSThemedTableView *)albumTableView
{
    if (!_albumTableView) {
        _albumTableView = [[SSThemedTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _albumTableView.backgroundColor = [UIColor clearColor];
        _albumTableView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0);
        _albumTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_albumTableView registerClass:[TTVideoAlbumTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTVideoAlbumTableViewCell class])];
        _albumTableView.delegate = self;
        _albumTableView.dataSource = self;
    }
    return _albumTableView;
}

- (SSThemedView *)topView
{
    if (!_topView) {
        _topView = [[SSThemedView alloc] init];
        _topView.backgroundColor = [UIColor clearColor];
        [_topView addSubview:self.albumName];
        [_topView addSubview:self.albumSource];
        [_topView addSubview:self.closeButton];
        [_topView addSubview:self.seperator];
    }
    return _topView;
}

- (SSThemedLabel *)albumName
{
    if (!_albumName) {
        _albumName = [[SSThemedLabel alloc] init];
        _albumName.textColorThemeKey = kColorText1;
        _albumName.font = [UIFont systemFontOfSize:17];
    }
    return _albumName;
}

- (SSThemedLabel *)albumSource
{
    if (!_albumSource) {
        _albumSource = [[SSThemedLabel alloc] init];
        _albumSource.textColorThemeKey = kColorText3;
        _albumSource.font = [UIFont systemFontOfSize:12];
    }
    return _albumSource;
}

- (TTAlphaThemedButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [[TTAlphaThemedButton alloc] init];
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        _closeButton.imageName = @"tt_titlebar_close";
        _closeButton.highlightedImageName = @"tt_titlebar_close_press";
        [_closeButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton addTarget:self action:@selector(sendCloseTrack) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton addTarget:self action:@selector(endStayTrack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (SSThemedView *)seperator
{
    if (!_seperator) {
        _seperator = [[SSThemedView alloc] init];
        _seperator.backgroundColorThemeKey = kColorLine10;
    }
    return _seperator;
}

#pragma mark -
#pragma mark tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.albumItems count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class className = [TTDetailNatantRelateReadViewModel class];
    return [className imgSizeForViewWidth:tableView.width].height + kAlbumTopPadding + kAlbumBottomPadding;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTVideoAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTVideoAlbumTableViewCell class]) forIndexPath:indexPath];
    cell.article = self.albumItems[indexPath.row][@"article"];
    ((TTDetailNatantRelateReadView *)cell.cellView).viewModel.fromArticle = self.currentPlayingArticle;
    if (self.item) {
        ((TTDetailNatantRelateReadView *)cell.cellView).viewModel.videoAlbumID = [self.item.videoDetailInfo valueForKey:@"col_no"];
    }
    else{
        ((TTDetailNatantRelateReadView *)cell.cellView).viewModel.videoAlbumID = [self.article.videoDetailInfo valueForKey:@"col_no"];
    }
    if (self.currentPlayingIndex >= 0 && indexPath.row == self.currentPlayingIndex) {
        cell.isCurrentPlaying = YES;
    } else {
        cell.isCurrentPlaying = NO;
    }
    return cell;
}

#pragma mark -
#pragma mark methods

- (void)findCurrentPlayingCell
{
    for (NSInteger index = 0; index < [self.albumItems count]; index++) {
        Article *article = self.albumItems[index][@"article"];
        BOOL isPlaying = [self isPlayingArticle:article];
        if (isPlaying) {
            self.currentPlayingIndex = index;
        }
    }
    [self.albumTableView reloadData];
}

- (void)scrollToCurrentPlayingCell
{
    [self findCurrentPlayingCell];
    if (self.currentPlayingIndex >= 0 && self.currentPlayingIndex < [self.albumItems count]) {
        NSInteger index = self.currentPlayingIndex;
        if (self.currentPlayingIndex > 1) {
            index -= 2;
        } else if (self.currentPlayingIndex > ([self.albumItems count] - 3)) {
            index = [self.albumItems count] - 1;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.albumTableView scrollToRowAtIndexPath:indexPath
                                   atScrollPosition:(index == ([self.albumItems count] - 1)) ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop animated:YES];
    }
}

- (BOOL)isPlayingArticle:(Article *)article
{
    return [[self videoIDFromArticle:self.currentPlayingArticle] isEqualToString:[self videoIDFromArticle:article]];
}

- (NSString *)videoIDFromArticle:(Article *)article
{
    NSString *vid = [[article videoDetailInfo] valueForKey:VideoInfoIDKey];
    if ([vid isKindOfClass:[NSString class]] && [vid length] > 0) {
        return vid;
    }
    return nil;
}

- (void)sendCloseTrack
{
    NSString *media_id = [self.currentPlayingArticle.mediaInfo valueForKey:@"media_id"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:media_id forKey:@"ext_value"];
    wrapperTrackEventWithCustomKeys(@"video", @"close_album", self.currentPlayingArticle.groupModel.groupID, nil, dic);
}

- (void)endStayTrack
{
    NSTimeInterval now = CFAbsoluteTimeGetCurrent();
    double duration = now - _startTime;
    if (duration < 0) {
        duration = 0;
    }
    duration = duration * 1000;
//    wrapperTrackEventWithCustomKeys(@"stay_category", @"video_album", [[NSNumber numberWithFloat:duration] stringValue], nil, nil);
    _startTime = 0;
}

#pragma mark -
#pragma mark gesture delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.albumTableView && scrollView.contentOffset.y == -scrollView.contentInset.top) {
        didBeginDraggingFromTop = YES;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (didBeginDraggingFromTop && scrollView == self.albumTableView && velocity.y < 0 && (*targetContentOffset).y == -scrollView.contentInset.top) {
        [self dismissSelf];
        [self sendCloseTrack];
        [self endStayTrack];
    }
    didBeginDraggingFromTop = NO;
}

#pragma mark -
#pragma mark public methods

- (void)reload
{
    [self.albumTableView reloadData];
    [self findCurrentPlayingCell];
}

- (void)dismissSelf
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, self.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [TTVideoAlbumHolder dispose];
    }];
}

@end


@implementation TTVideoAlbumHolder

static TTVideoAlbumHolder *holder = nil;
+ (instancetype)holder
{
    if (!holder) {
        holder = [TTVideoAlbumHolder new];
    }
    return holder;
}

+ (void)dispose
{
    holder = nil;
}

@end
