//
//  FHIntroduceView.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import "FHIntroduceView.h"

@interface FHIntroduceView ()

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
    self.backgroundColor = [UIColor greenColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    [self addSubview:_scrollView];
    
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    view1.backgroundColor = [UIColor redColor];
    [_scrollView addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)];
    view2.backgroundColor = [UIColor blueColor];
    [_scrollView addSubview:view2];
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 2, 0, self.bounds.size.width, self.bounds.size.height)];
    view3.backgroundColor = [UIColor yellowColor];
    [_scrollView addSubview:view3];
}

@end
