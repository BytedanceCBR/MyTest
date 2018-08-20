//
//  TTVVideoDetailAlbumView.m
//  Article
//
//  Created by lishuangyang on 2017/6/18.
//
//

#import "TTVVideoDetailAlbumView.h"
#import "TTDetailNatantRelateReadView.h"
#import "TTAlphaThemedButton.h"
#import "TTVideoAlbumFetcher.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIButton+TTAdditions.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"
#import "TTVRelatedItem+TTVArticleProtocolSupport.h"

#import "TTVVideoDetailAlbumCellView.h"
#import <KVOController/KVOController.h>

#define kTopViewHeight 44.0

@interface TTVVideoAlbumTableViewCell : SSThemedTableViewCell

@property (nonatomic, strong)id<TTVArticleProtocol> protoedArticle;
@property (nonatomic, strong) UIView *cellView;
@property (nonatomic, assign) BOOL isCurrentPlaying;
@property (nonatomic, copy)NSDictionary *logPb;

@end

@implementation TTVVideoAlbumTableViewCell


- (void)protoedArticle:(id<TTVArticleProtocol>)protoedArticle{
    if (_protoedArticle != protoedArticle) {
        _protoedArticle = protoedArticle;
        [self refresh];
    }
}

- (void)refresh {
    TTVVideoDetailAlbumCellView *cellView = (TTVVideoDetailAlbumCellView *)self.cellView;
    [cellView refreshArticle:self.protoedArticle];
//    [cellView hideFromLabel:YES];
    [cellView hideBottomLine:YES];
    
    if ([self.cellView respondsToSelector:NSSelectorFromString(@"commentCountLabel")]) {
        UILabel *countLabel = [self.cellView valueForKey:@"commentCountLabel"];
        NSString *playCountString = [TTBusinessManager formatCommentCount:[[self.protoedArticle.videoDetailInfo objectForKey:VideoWatchCountKey] longLongValue]];
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
        TTVVideoDetailAlbumCellView *cellView = [TTVVideoDetailAlbumCellView genViewForArticle:self.protoedArticle width:self.width infoFlag:0 forVideoDetail:YES];
        cellView.viewModel.pushAnimation = NO;
        cellView.viewModel.isSubVideoAlbum = YES;
        cellView.viewModel.logPb = self.logPb;
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


@interface TTVVideoDetailAlbumView () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIViewControllerErrorHandler>
{
    BOOL didBeginDraggingFromTop;
}

@property (nonatomic, strong) SSThemedView *topView;
@property (nonatomic, strong) SSThemedLabel *albumName;
@property (nonatomic, strong) SSThemedLabel *albumSource;
@property (nonatomic, strong) TTAlphaThemedButton *closeButton;
@property (nonatomic, strong) SSThemedView *seperator;
@property (nonatomic, strong) SSThemedTableView *albumTableView;
@property (nonatomic, assign) NSInteger currentPlayingIndex;
@property (nonatomic, assign) NSTimeInterval startTime;


@end

@implementation TTVVideoDetailAlbumView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentPlayingIndex = -1;
        self.backgroundColorThemeKey = kColorBackground4;
        [self addSubview:self.topView];
        [self addSubview:self.albumTableView];
        if (!self.viewModel) {
            self.viewModel = [[TTVVideoDetailAlbumViewModel alloc] init];
        }
        [self addKVO];
        _startTime = CFAbsoluteTimeGetCurrent();
        
    }
    return self;
}

- (void)viewModelFetchAlbum
{
    [self tt_startUpdate];
    if (self.viewModel) {
        [self.viewModel fetchAlbumsWithURL:self.viewModel.item.videoItem.album.URL completion:^(NSArray *albums, NSError *error) {
            
            self.albumName.text = self.viewModel.albumName;
            self.albumSource.text = _viewModel.item.source;
    
            [self reload];
            [self scrollToCurrentPlayingCell];
            [self tt_endUpdataData:NO error:error];
        }];
    }
}

- (void)reload
{
    [self.albumTableView reloadData];
    [self findCurrentPlayingCell];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && newSuperview != [TTUIResponderHelper mainWindow]) {
        if ([self.viewModel.albumItems count] == 0) {
            [self viewModelFetchAlbum];
        }
    }
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

- (void)dismissSelf
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, self.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [TTVVideoAlbumHolder dispose];
    }];
}

#pragma mark - help methods

- (void)scrollToCurrentPlayingCell
{
    [self findCurrentPlayingCell];
    if (self.currentPlayingIndex >= 0 && self.currentPlayingIndex < [self.viewModel.albumItems count]) {
        NSInteger index = self.currentPlayingIndex;
        if (self.currentPlayingIndex > 1) {
            index -= 2;
        } else if (self.currentPlayingIndex > ([self.viewModel.albumItems count] - 3)) {
            index = [self.viewModel.albumItems count] - 1;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.albumTableView scrollToRowAtIndexPath:indexPath
                                   atScrollPosition:(index == ([self.viewModel.albumItems count] - 1)) ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop animated:YES];
    }
}


- (void)findCurrentPlayingCell
{
    for (NSInteger index = 0; index < [self.viewModel.albumItems count]; index++) {
        Article *article = self.viewModel.albumItems[index][@"article"];
        BOOL isPlaying = [self isPlayingArticle:article];
        if (isPlaying) {
            self.currentPlayingIndex = index;
        }
    }
    [self.albumTableView reloadData];
}


- (BOOL)isPlayingArticle:(id<TTVArticleProtocol> )article
{
    return [[self videoIDFromArticle:self.viewModel.currentPlayingArticle] isEqualToString:[self videoIDFromArticle:article]];
}

- (NSString *)videoIDFromArticle:(id<TTVArticleProtocol> )article
{
    NSString *vid = [[article videoDetailInfo] valueForKey:VideoInfoIDKey];
    if ([vid isKindOfClass:[NSString class]] && [vid length] > 0) {
        return vid;
    }
    return nil;
}


#pragma mark -
#pragma mark tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel.albumItems count];
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
    TTVVideoAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTVVideoAlbumTableViewCell class]) forIndexPath:indexPath];
    cell.logPb = self.viewModel.logPb;
    cell.protoedArticle = self.viewModel.albumItems[indexPath.row][@"protoedArticle"];
    ((TTVVideoDetailAlbumCellView *)cell.cellView).viewModel.fromArticle = self.viewModel.currentPlayingArticle;
    if (self.viewModel) {
        ((TTVVideoDetailAlbumCellView *)cell.cellView).viewModel.videoAlbumID = [self.viewModel.currentPlayingArticle.videoDetailInfo valueForKey:@"col_no"];
    }
    if (self.currentPlayingIndex >= 0 && indexPath.row == self.currentPlayingIndex) {
        cell.isCurrentPlaying = YES;
    } else {
        cell.isCurrentPlaying = NO;
    }
    return cell;
}


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

#pragma mark - log related
- (void)sendCloseTrack
{
    NSString *media_id = [self.viewModel.currentPlayingArticle.mediaInfo valueForKey:@"media_id"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:media_id forKey:@"ext_value"];
    wrapperTrackEventWithCustomKeys(@"video", @"close_album", self.viewModel.currentPlayingArticle.groupModel.groupID, nil, dic);
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



#pragma mark - UIViewControllerErrorHandler

- (void)refreshData
{
    [self viewModelFetchAlbum];
}

- (void)emptyViewBtnAction
{
    [self viewModelFetchAlbum];
}


- (BOOL)tt_hasValidateData
{
    if ([self.viewModel.albumItems count] > 0) {
        return YES;
    }
    return NO;
}


#pragma mark - getter and setter

- (SSThemedTableView *)albumTableView
{
    if (!_albumTableView) {
        _albumTableView = [[SSThemedTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _albumTableView.backgroundColor = [UIColor clearColor];
        _albumTableView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0);
        _albumTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_albumTableView registerClass:[TTVVideoAlbumTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTVVideoAlbumTableViewCell class])];
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

- (void)addKVO{
    @weakify(self);
    [self.KVOController observe:self.viewModel keyPath:@keypath(self.viewModel, currentPlayingArticle) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self scrollToCurrentPlayingCell];
    }];
}

@end


@implementation TTVVideoAlbumHolder

static TTVVideoAlbumHolder *holder = nil;
+ (instancetype)holder
{
    if (!holder) {
        holder = [TTVVideoAlbumHolder new];
    }
    return holder;
}

+ (void)dispose
{
    holder = nil;
}

@end
