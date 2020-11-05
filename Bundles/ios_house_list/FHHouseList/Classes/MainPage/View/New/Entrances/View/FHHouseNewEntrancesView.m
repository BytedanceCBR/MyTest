//
//  FHHouseNewEntrancesView.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewEntrancesView.h"
#import "FHHouseNewEntrancesViewModel.h"
#import "FHListEntrancesView.h"
#import "Masonry.h"
#import <TTBaseLib/TTBaseMacro.h>

@interface FHHouseNewEntrancesView()
@property (nonatomic, strong) FHListEntrancesView *contentView;
@property (nonatomic, strong) FHHouseNewEntrancesViewModel *entrancesViewModel;
@end

@implementation FHHouseNewEntrancesView

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (!viewModel || ![viewModel isKindOfClass:FHHouseNewEntrancesViewModel.class] || ![viewModel isValid]) return 0.0f;
    return 94.0;
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
    [self addSubview:self.contentView];
}

- (void)setupConstraints {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
}

- (FHListEntrancesView *)contentView {
    if (!_contentView) {
        _contentView = [[FHListEntrancesView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.countPerRow = 5;
        WeakSelf;
        _contentView.clickBlock = ^(NSInteger clickIndex , FHConfigDataOpDataItemsModel *itemModel){
            StrongSelf;
            [self.entrancesViewModel onClickItem:itemModel];
        };
    }
    return _contentView;
}

- (FHHouseNewEntrancesViewModel *)entrancesViewModel {
    return (FHHouseNewEntrancesViewModel *)self.viewModel;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    self.contentView.hidden = ![self.entrancesViewModel isValid];
    if (!self.contentView.hidden) {
        [self.contentView updateWithItems:self.entrancesViewModel.items];
    }
}

@end
