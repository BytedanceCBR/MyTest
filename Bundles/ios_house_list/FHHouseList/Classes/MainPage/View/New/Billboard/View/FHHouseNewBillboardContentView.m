//
//  FHHouseNewBillboardContentView.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewBillboardContentView.h"
#import "Masonry.h"
#import "FHHouseNewBillboardItemView.h"
#import "FHHouseNewBillboardContentViewModel.h"
#import "FHHouseNewBillboardItemViewModel.h"
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"

static NSInteger const TitleTopMargin = 15.0f;
static NSInteger const TitleHeight = 25.0f;
static NSInteger const ButtonHeight = 44.0f;
static NSInteger const ButtonBottomMargin = 16.0f;

@interface FHHouseNewBillboardContentView() {
    NSMutableArray *_itemViewList;
}
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *itemsContainerView;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) FHHouseNewBillboardContentViewModel *contentViewModel;
@end

@implementation FHHouseNewBillboardContentView

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (!viewModel || ![viewModel isKindOfClass:FHHouseNewBillboardContentViewModel.class] || ![viewModel isValid]) return 0.0f;
    FHHouseNewBillboardContentViewModel *contentViewModel = (FHHouseNewBillboardContentViewModel *)viewModel;
    NSArray<FHHouseNewBillboardItemViewModel *> *items = contentViewModel.items;
    if (!items || !items.count) return 0.0f;
    CGFloat height = TitleHeight + TitleTopMargin + ButtonHeight + ButtonBottomMargin;
    for (FHHouseNewBillboardItemViewModel *item in items) {
        height += [FHHouseNewBillboardItemView viewHeightWithViewModel:item];
    }
    return height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _itemViewList = [NSMutableArray array];
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.titleLabel];
    [self addSubview:self.itemsContainerView];
    [self addSubview:self.moreButton];
}

- (void)setupConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(TitleTopMargin);
        make.height.mas_equalTo(TitleHeight);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-ButtonBottomMargin);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    [self.itemsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.bottom.mas_equalTo(self.moreButton.mas_top);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        _titleLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UIView *)itemsContainerView {
    if (!_itemsContainerView) {
        _itemsContainerView = [[UIView alloc] init];
    }
    return _itemsContainerView;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] init];
        _moreButton.backgroundColor = [UIColor colorWithHexStr:@"#ffeee5"];
        _moreButton.layer.cornerRadius = ButtonHeight / 2;
        _moreButton.layer.masksToBounds = YES;
        [_moreButton setTitleColor:[UIColor colorWithHexStr:@"#fe5500"] forState:UIControlStateNormal];
        _moreButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [_moreButton addTarget:self action:@selector(onMoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (FHHouseNewBillboardContentViewModel *)contentViewModel {
    return (FHHouseNewBillboardContentViewModel *)self.viewModel;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    [self refreshUI];
}

- (void)refreshUI {
    self.titleLabel.text = self.contentViewModel.title;
    [self.moreButton setTitle:self.contentViewModel.buttonText forState:UIControlStateNormal];
    NSArray *items = self.contentViewModel.items;
    FHHouseNewBillboardItemView *lastItemView = nil;
    for (NSInteger index = 0; index < items.count; index++) {
        FHHouseNewBillboardItemViewModel *item = [items objectAtIndex:index];
        FHHouseNewBillboardItemView *itemView = nil;
        if (_itemViewList.count > index) {
            itemView = [_itemViewList objectAtIndex:index];
        } else {
            itemView = [[FHHouseNewBillboardItemView alloc] init];
            [self.itemsContainerView addSubview:itemView];
            [_itemViewList addObject:itemView];
        }
        
        item.isLastItem = (index == items.count - 1);
        itemView.viewModel = item;
        CGFloat height = [FHHouseNewBillboardItemView viewHeightWithViewModel:item];
        itemView.frame = CGRectMake(0, lastItemView.bottom, self.itemsContainerView.width, height);
        
        lastItemView = itemView;
    }
    
    if (_itemViewList.count > items.count) {
        for (NSInteger index = _itemViewList.count - 1; index >= items.count; index--) {
            FHHouseNewBillboardItemView *itemView = [_itemViewList objectAtIndex:index];
            [itemView removeFromSuperview];
            [_itemViewList removeObject:itemView];
        }
    }
}

- (void)onMoreButtonClicked:(id)sender {
    if ([self.contentViewModel respondsToSelector:@selector(onClickButton)]) {
        [self.contentViewModel onClickButton];
    }
}

@end

