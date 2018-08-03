//
//  WDDetailAnswerEmptyView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/27.
//
//

#import "WDDetailAnswerEmptyView.h"
#import "WDDetailAnswerEmptyCell.h"
#import "WDDefines.h"

static NSString *kTTEmptyContentCellIdentifier = @"TTEmptyContentCell";

@interface WDDetailAnswerEmptyView ()<UITableViewDataSource, UITableViewDelegate, WDDetailAnswerEmptyCellDelegate>

@property (nonatomic, strong) SSThemedTableView *tableView;

@property (nonatomic, assign) NSInteger emptyReason;
@property (nonatomic, strong) NSError *error;

@end

@implementation WDDetailAnswerEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)startShow {
    
    _tableView = [[SSThemedTableView alloc] initWithFrame:self.bounds];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView registerClass:[WDDetailAnswerEmptyCell class] forCellReuseIdentifier:kTTEmptyContentCellIdentifier];
    
    [self addSubview:_tableView];
}

- (void)setEmptyTypeReason:(NSInteger)reason error:(NSError *)error {
    _emptyReason = reason;
    _error = error;
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerEmptyViewDidScrollWithContentOffsetY:)]) {
        [_delegate wd_detailAnswerEmptyViewDidScrollWithContentOffsetY:scrollView.contentOffset.y];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerEmptyViewStopScrollWithContentOffsetY:)]) {
        [_delegate wd_detailAnswerEmptyViewStopScrollWithContentOffsetY:scrollView.contentOffset.y];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerEmptyViewStopScrollWithContentOffsetY:)]) {
        [_delegate wd_detailAnswerEmptyViewStopScrollWithContentOffsetY:scrollView.contentOffset.y];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WDDetailAnswerEmptyCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:kTTEmptyContentCellIdentifier];
    emptyCell.delegate = self;
    if (_emptyReason == 1) {
        [emptyCell setNetworkProblem];
    }
    else if (_emptyReason == 2) {
        [emptyCell setHasBeenDeletedWithError:_error];
    }
    return emptyCell;
}

#pragma mark - WDDetailAnswerEmptyCellDelegate

- (void)wd_detailAnswerEmptyCellReloadContent {
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerEmptyViewReconnectLoadData)]) {
        [_delegate wd_detailAnswerEmptyViewReconnectLoadData];
    }
}

#pragma mark - getter & setter


@end
