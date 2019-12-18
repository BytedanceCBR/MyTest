//
//  FHIntroduceView.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import "FHIntroduceView.h"
#import <UIColor+Theme.h>
#import "FHIntroduceItemView.h"

@interface FHIntroduceView ()<FHIntroduceItemViewDelegate>

@property (nonatomic ,strong) FHIntroduceModel *model;
@property (nonatomic , strong) UIScrollView *scrollView;

@end

@implementation FHIntroduceView

- (instancetype)initWithFrame:(CGRect)frame model:(FHIntroduceModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        [self initView];
    }
    return self;
}

- (void)initView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.backgroundColor = [UIColor colorWithHexString:@"f4f5f6"];
    [self addSubview:_scrollView];
    
    if(_model.items.count > 0){
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * _model.items.count, self.bounds.size.height);
    }
    
    for (NSInteger i = 0; i < self.model.items.count; i++) {
        FHIntroduceItemModel *item = self.model.items[i];
        FHIntroduceItemView *itemView = [[FHIntroduceItemView alloc] initWithFrame:CGRectMake(self.bounds.size.width * i, 0, self.bounds.size.width, self.bounds.size.height) model:item];
        itemView.delegate = self;
        [_scrollView addSubview:itemView];
    }
}

#pragma mark - FHIntroduceItemViewDelegate

- (void)close {
    [self removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
