//
//  FHHouseNewTopContainer.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewTopContainer.h"
#import "FHHouseNewEntrancesView.h"
#import "FHHouseNewBillboardView.h"
#import "FHHouseNewTopContainerViewModel.h"
#import "Masonry.h"
#import "FHFakeInputNavbar.h"
#import <TTBaseLib/TTBaseMacro.h>

@interface FHHouseNewTopContainer()
@property (nonatomic, strong) FHHouseNewEntrancesView *entrancesView;
@property (nonatomic, strong) FHHouseNewBillboardView *billboardView;

@property (nonatomic, strong) FHHouseNewTopContainerViewModel *containerViewModel;
@end

@implementation FHHouseNewTopContainer

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (!viewModel || ![viewModel isKindOfClass:FHHouseNewTopContainerViewModel.class] || ![viewModel isValid]) return 0.0f;
    FHHouseNewTopContainerViewModel *containerViewModel = (FHHouseNewTopContainerViewModel *)viewModel;
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    if ([containerViewModel.entrancesViewModel isValid]) {
        height += [FHHouseNewEntrancesView viewHeightWithViewModel:containerViewModel.entrancesViewModel];
    }
    
    if ([containerViewModel.billboardViewModel isValid]) {
        height += [FHHouseNewBillboardView viewHeightWithViewModel:containerViewModel.billboardViewModel];
    }
    return height;
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
    [self addSubview:self.entrancesView];
    [self addSubview:self.billboardView];
}

- (void)setupConstraints {
    [self.entrancesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];

    [self.billboardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
}

- (void)refreshConstraints {
    CGFloat topY = [FHFakeInputNavbar perferredHeight];
    if (!self.entrancesView.hidden) {
        CGFloat height = [FHHouseNewEntrancesView viewHeightWithViewModel:self.containerViewModel.entrancesViewModel];
        [self.entrancesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(topY);
            make.height.mas_equalTo(height);
        }];
        
        topY += height;
    }
    
    if (!self.billboardView.hidden) {
        CGFloat height = [FHHouseNewBillboardView viewHeightWithViewModel:self.containerViewModel.billboardViewModel];
        [self.billboardView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(topY);
            make.height.mas_equalTo(height);
        }];
        
        topY += height;
    }
}

- (FHHouseNewEntrancesView *)entrancesView {
    if (!_entrancesView) {
        _entrancesView = [[FHHouseNewEntrancesView alloc] init];
        _entrancesView.hidden = YES;
    }
    return _entrancesView;
}

- (FHHouseNewBillboardView *)billboardView {
    if (!_billboardView) {
        _billboardView = [[FHHouseNewBillboardView alloc] init];
        _billboardView.hidden = YES;
        WeakSelf;
        _billboardView.onStateChanged = ^{
            StrongSelf;
            self.billboardView.hidden = ![self.containerViewModel.billboardViewModel isValid];
            if (!self.billboardView.hidden) {
                self.billboardView.viewModel = self.containerViewModel.billboardViewModel;
            }
            
            [self refreshConstraints];
            
            if (self.onStateChanged) {
                self.onStateChanged();
            }
        };
    }
    return _billboardView;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    self.entrancesView.hidden = ![self.containerViewModel.entrancesViewModel isValid];
    if (!self.entrancesView.hidden) {
        self.entrancesView.viewModel = self.containerViewModel.entrancesViewModel;
    }
    
    self.billboardView.hidden = ![self.containerViewModel.billboardViewModel isValid];
    if (!self.billboardView.hidden) {
        self.billboardView.viewModel = self.containerViewModel.billboardViewModel;
    }
    
    [self refreshConstraints];
}

- (FHHouseNewTopContainerViewModel *)containerViewModel {
    return (FHHouseNewTopContainerViewModel *)self.viewModel;
}

@end
