//
//  FHHouseNewBillboardView.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewBillboardView.h"
#import "Masonry.h"
#import "FHHouseNewBillboardPlaceholderView.h"
#import "FHHouseNewBillboardItemView.h"
#import "FHHouseNewBillboardContentView.h"
#import "FHHouseNewBillboardContentViewModel.h"
#import "FHHouseNewBillboardViewModel.h"

@interface FHHouseNewBillboardView()<FHHouseNewBillboardViewModelObserver>
//@property (nonatomic, strong) FHHouseNewBillboardPlaceholderView *placeholderView;
@property (nonatomic, strong) FHHouseNewBillboardContentView *contentView;
@property (nonatomic, strong) FHHouseNewBillboardViewModel *billboardViewModel;
@end

@implementation FHHouseNewBillboardView

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (!viewModel || ![viewModel isKindOfClass:FHHouseNewBillboardViewModel.class] || ![viewModel isValid]) return 0.0f;
    FHHouseNewBillboardViewModel *billboardViewModel = (FHHouseNewBillboardViewModel *)viewModel;
//    if (billboardViewModel.loading) return [FHHouseNewBillboardPlaceholderView viewHeight];
    if (![billboardViewModel.contentViewModel isValid]) return 0.0f;
    return [FHHouseNewBillboardContentView viewHeightWithViewModel:billboardViewModel.contentViewModel];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
//    [self addSubview:self.placeholderView];
    [self addSubview:self.contentView];
}

- (void)setupConstraints {
//    [self.placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.mas_equalTo(0);
//    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
}

//- (FHHouseNewBillboardPlaceholderView *)placeholderView {
//    if (!_placeholderView) {
//        _placeholderView = [[FHHouseNewBillboardPlaceholderView alloc] init];
//        _placeholderView.hidden = YES;
//    }
//    return _placeholderView;
//}

- (FHHouseNewBillboardContentView *)contentView {
    if (!_contentView) {
        _contentView = [[FHHouseNewBillboardContentView alloc] init];
        _contentView.hidden = YES;
    }
    return _contentView;
}

- (FHHouseNewBillboardViewModel *)billboardViewModel {
    return (FHHouseNewBillboardViewModel *)self.viewModel;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    [self refreshUI];
}

- (void)refreshUI {
//    self.placeholderView.hidden = !self.billboardViewModel.loading;
//    self.contentView.hidden = self.billboardViewModel.loading;
    self.contentView.hidden = ![self.billboardViewModel.contentViewModel isValid];
    if (!self.contentView.hidden) {
        self.contentView.viewModel = self.billboardViewModel.contentViewModel;
    }
}

- (void)onBillboardDataChanged:(FHHouseNewBillboardViewModel *)viewModel {
    [self refreshUI];
    if (self.onStateChanged) {
        self.onStateChanged();
    }
}

@end
