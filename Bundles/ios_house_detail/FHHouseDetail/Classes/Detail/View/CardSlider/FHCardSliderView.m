//
//  FHCardSliderView.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import "FHCardSliderView.h"
#import "FHCardSliderFlowLayout.h"
#import "FHCardSliderCell.h"
#import <Masonry/Masonry.h>
#import "FHCardSliderCellModel.h"
#import "FHUserTracker.h"
#import "TTRoute.h"

static const int groupCount = 51;//最好奇数（定位到中间）  如：3，5，11~51，101
static const float timerInterval = 3.0f;
@interface FHCardSliderView()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>

@property(nonatomic , assign) FHCardSliderViewType type;
//@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableDictionary *clientShowDict;
    
@end

@implementation FHCardSliderView
{
    NSInteger _selectedIndex;
    NSInteger _isReloadPage;
}

- (instancetype)initWithFrame:(CGRect)frame type:(FHCardSliderViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        _isLoop = NO;
        _isAuto = NO;
        [self configUI];
    }
    return self;
}

- (void)dealloc
{
    [self cancelTimer];
}

- (void)configUI
{
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)cancelTimer {
    if (!self.timer) {
        return;
    }

    [self.timer invalidate];
    self.timer = nil;
}

- (void)startTimer {
    if (self.timer) {
        return;
    }

    self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(cardInfiniteScrolling) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)addTimer
{
    _isReloadPage = YES;
    if (!self.dataSource || self.dataSource.count <= 0) {
        return;
    }
    [self cancelTimer];
    
    if(self.isLoop){
        NSInteger centerIndex = (groupCount/2)*self.dataSource.count;
        
        if(self.type == FHCardSliderViewTypeHorizontal){
            [self.collectionView setContentOffset:CGPointMake(centerIndex * self.collectionView.bounds.size.width, 0) animated:NO];
        }else{
            [self.collectionView setContentOffset:CGPointMake(0, centerIndex * self.collectionView.bounds.size.height) animated:NO];
        }
        
        _selectedIndex = centerIndex;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(cardInfiniteScrolling) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)cardInfiniteScrolling
{
    NSInteger totalCount = self.isLoop ? (self.dataSource.count * groupCount) : self.dataSource.count;
    if(_selectedIndex + 1 < totalCount){
        _selectedIndex++;
        
        if(self.type == FHCardSliderViewTypeHorizontal){
            [self.collectionView setContentOffset:CGPointMake(_selectedIndex * self.collectionView.bounds.size.width, 0) animated:YES];
        }else{
            [self.collectionView setContentOffset:CGPointMake(0, _selectedIndex * self.collectionView.bounds.size.height) animated:YES];
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    NSInteger totalCount = self.isLoop ? (self.dataSource.count * groupCount) : self.dataSource.count;
    return totalCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHCardSliderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHCardSliderCell class]) forIndexPath:indexPath];
    NSInteger totalCount = self.isLoop ? (self.dataSource.count * groupCount) : self.dataSource.count;
    if (indexPath.row < totalCount) {
        [cell setCellData:self.dataSource[indexPath.row%self.dataSource.count]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger totalCount = self.isLoop ? (self.dataSource.count * groupCount) : self.dataSource.count;
    if (indexPath.row >= totalCount || indexPath.row != _selectedIndex) {
        return;
    }
    
    FHCardSliderCellModel *cellModel = self.dataSource[indexPath.row%self.dataSource.count];
    if(cellModel.schema.length > 0){
        NSURL *url = [NSURL URLWithString:cellModel.schema];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.isAuto){
        [self cancelTimer];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(self.isAuto){
        [self startTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.type == FHCardSliderViewTypeHorizontal){
        _selectedIndex = (scrollView.contentOffset.x + 20)/self.collectionView.bounds.size.width;
        if (_selectedIndex >= ((self.dataSource.count*groupCount-1-visibleItemsCount) || _selectedIndex == 0) && self.isLoop) {
            NSInteger centerIndex = (groupCount/2)*self.dataSource.count;
            [self.collectionView setContentOffset:CGPointMake(centerIndex * self.collectionView.bounds.size.width, 0) animated:NO];
            _selectedIndex = centerIndex;
        }
    }else{
        _selectedIndex = (scrollView.contentOffset.y + 20)/self.collectionView.bounds.size.height;
        if ((_selectedIndex >= (self.dataSource.count*groupCount-1-visibleItemsCount) || _selectedIndex == 0) && self.isLoop) {
            NSInteger centerIndex = (groupCount/2)*self.dataSource.count;
            [self.collectionView setContentOffset:CGPointMake(0, centerIndex * self.collectionView.bounds.size.height) animated:NO];
            _selectedIndex = centerIndex;
        }
    }
    [self trackCardShow];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(self.type == FHCardSliderViewTypeHorizontal){
        _selectedIndex = (scrollView.contentOffset.x + 20)/self.collectionView.bounds.size.width;
        if ((_selectedIndex >= (self.dataSource.count*groupCount-1-visibleItemsCount) || _selectedIndex == 0) && self.isLoop) {
            NSInteger centerIndex = (groupCount/2)*self.dataSource.count;
            [self.collectionView setContentOffset:CGPointMake(centerIndex * self.collectionView.bounds.size.width, 0) animated:NO];
            _selectedIndex = centerIndex;
        }
    }else{
        _selectedIndex = (scrollView.contentOffset.y + 20)/self.collectionView.bounds.size.height;
        if ((_selectedIndex >= (self.dataSource.count*groupCount-1-visibleItemsCount) || _selectedIndex == 0) && self.isLoop) {
            NSInteger centerIndex = (groupCount/2)*self.dataSource.count;
            [self.collectionView setContentOffset:CGPointMake(0, centerIndex * self.collectionView.bounds.size.height) animated:NO];
            _selectedIndex = centerIndex;
        }
    }
    [self trackCardShow];
}

#pragma mark - Get & Set
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        FHCardSliderFlowLayout *flowLayout = [[FHCardSliderFlowLayout alloc] init];
        flowLayout.type = self.type;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.clipsToBounds = NO;
        _collectionView.bounces = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[FHCardSliderCell class] forCellWithReuseIdentifier:NSStringFromClass([FHCardSliderCell class])];
    }
    return _collectionView;
}

- (void)setCardListData:(NSArray *)cardList{
    if (cardList && cardList.count > 0) {
        self.dataSource = cardList;
    }else{
        self.dataSource = [[NSArray alloc] init];
    }
    
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if (_isReloadPage && _isAuto) {
        [self addTimer];
    }
}

+ (CGFloat)getViewHeight {
    return (160*[[UIScreen mainScreen] bounds].size.width/375);
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if(self.isAuto){
        if (newWindow) {
            [self startTimer];
        } else {
            [self cancelTimer];
        }
    }
}

- (void)trackCardShow {

    FHCardSliderCellModel *cellModel = self.dataSource[_selectedIndex%self.dataSource.count];

    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }

    NSString *groupId = cellModel.groupId;
    if(groupId){
        if (self.clientShowDict[groupId]) {
            return;
        }

        self.clientShowDict[groupId] = @(_selectedIndex);
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(self.tracerDic){
        [dict addEntriesFromDictionary:self.tracerDic];
    }
    [dict removeObjectsForKeys:@[@"card_type"]];
    dict[@"rank"] = @(_selectedIndex);
    dict[@"group_id"] = cellModel.groupId;
    TRACK_EVENT(@"card_show", dict);
}

@end


