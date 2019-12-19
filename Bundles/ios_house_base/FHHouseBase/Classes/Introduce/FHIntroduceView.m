//
//  FHIntroduceView.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import "FHIntroduceView.h"
#import <UIColor+Theme.h>
#import "FHIntroduceItemView.h"
#import <UIViewAdditions.h>
#import "FHIntroduceManager.h"
#import <Masonry.h>

@interface FHIntroduceView ()<FHIntroduceItemViewDelegate>

@property (nonatomic , strong) FHIntroduceModel *model;
@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong) UIImageView *indicatorView;
@property (nonatomic , strong) UIButton *jumpBtn;
@property (nonatomic , strong) NSMutableArray *itemViewList;

@end

@implementation FHIntroduceView

- (instancetype)initWithFrame:(CGRect)frame model:(FHIntroduceModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        _itemViewList = [NSMutableArray array];
        [self initView];
        [self initFirstData];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor colorWithHexString:@"f4f5f6"];
    
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    CGFloat top = 0;
    CGFloat safeTop = 0;
    if (@available(iOS 11.0, *)) {
        safeTop = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].top;
    }
    if (safeTop > 0) {
        top += (safeTop - 20);
    }
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, top, self.bounds.size.width, self.bounds.size.height - top - bottom)];
    [self addSubview:_containerView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor colorWithHexString:@"f4f5f6"];
    _scrollView.delegate = self;
    [_containerView addSubview:_scrollView];
    
    for (NSInteger i = 0; i < self.model.items.count; i++) {
        FHIntroduceItemModel *item = self.model.items[i];
        FHIntroduceItemView *itemView = [[FHIntroduceItemView alloc] initWithFrame:CGRectMake(self.bounds.size.width * i, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height) model:item];
        itemView.delegate = self;
        [_scrollView addSubview:itemView];
        [self.itemViewList addObject:itemView];
    }
    
    self.indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.containerView.bounds.size.height - 20, 40, 4)];
    _indicatorView.contentMode = UIViewContentModeScaleAspectFit;
    _indicatorView.image = [UIImage imageNamed:@"fh_introduce_indicator_1"];
    _indicatorView.centerX = self.centerX;
    [_containerView addSubview:_indicatorView];
    
    self.jumpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 64, 32)];
    [_jumpBtn setImage:[UIImage imageNamed:@"fh_introduce_jump"] forState:UIControlStateNormal];
    [_jumpBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    _jumpBtn.right = self.right - 20;
    [_containerView addSubview:_jumpBtn];
}

- (void)initFirstData {
    if(self.model.items.count > 0 && self.itemViewList.count > 0){
        self.scrollView.contentSize = CGSizeMake(self.containerView.bounds.size.width * _model.items.count, self.containerView.size.height);
    
        FHIntroduceItemModel *itemModel = self.model.items[0];
        if(itemModel){
            self.jumpBtn.hidden = !itemModel.showJumpBtn;
        }
        
        FHIntroduceItemView *itemView = self.itemViewList[0];
        [itemView play];
    }
}

#pragma mark - FHIntroduceItemViewDelegate

- (void)close {
    [[FHIntroduceManager sharedInstance] hideIntroduceView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateJumpBtnState];
    [self updateindicatorState];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger curPage = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
    
    if(curPage < self.itemViewList.count){
        FHIntroduceItemView *itemView = self.itemViewList[curPage];
        [itemView play];
    }
}

- (void)updateJumpBtnState {
    NSInteger curPage = ceil(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    if(curPage < self.model.items.count){
        FHIntroduceItemModel *itemModel = self.model.items[curPage];
        self.jumpBtn.hidden = !itemModel.showJumpBtn;
    }
}

- (void)updateindicatorState {
    NSInteger curPage = round(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    if(curPage < self.model.items.count){
        FHIntroduceItemModel *itemModel = self.model.items[curPage];
        if(itemModel.indicatorImageName){
            self.indicatorView.image = [UIImage imageNamed:itemModel.indicatorImageName];
        }else{
            self.indicatorView.image = nil;
        }
    }
}

@end
