//
//  TTFooterDeleteView.m
//  Article
//
//  Created by fengyadong on 16/11/20.
//
//

#import "TTFooterDeleteView.h"
#import "TTFeedHistoryViewModel.h"
#import "TTAlphaThemedButton.h"
#import "TTHistoryEntryGroup.h"
#import "TTThemedAlertController.h"


@interface TTFooterDeleteView ()

@property (nonatomic, assign) long long totalDeletingCount;
@property (nonatomic, strong) TTAlphaThemedButton *clearAllButton;
@property (nonatomic, strong) TTAlphaThemedButton *deleteButton;
@property (nonatomic, strong) TTFeedMultiDeleteViewModel *viewModel;
@property (nonatomic, assign) BOOL canClearAll;

@end

@implementation TTFooterDeleteView

#pragma mark -- Life Cycle

- (instancetype)initWithFrame:(CGRect)frame viewModel:(TTFeedMultiDeleteViewModel *)viewModel canClearAll:(BOOL)canClearAll {
    if (self = [super initWithFrame:frame]) {
        _viewModel = viewModel;
        _canClearAll = canClearAll;
        [self commonInit];
        [self addKVO];
    }
    return self;
}

- (void)dealloc {
    [self removeKVO];
}

#pragma mark -- Setup

- (void)commonInit {
    [self setupBackgroundView];
    if (self.canClearAll) {
        [self setupClearAllButton];
    }
    [self setupDeleteButton];
    [self setupTopLine];
}

- (void)setupBackgroundView {
    SSThemedView *backgroundView = [[SSThemedView alloc] init];
    backgroundView.backgroundColorThemeKey = kColorBackground3;
    backgroundView.alpha = 0.98f;
    [self addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setupClearAllButton {
    if (!_clearAllButton) {
        _clearAllButton = [[TTAlphaThemedButton alloc] init];
        _clearAllButton.enableHighlightAnim = YES;
        _clearAllButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]];
        _clearAllButton.titleColorThemeKey = kColorText1;
        [_clearAllButton setTitle:NSLocalizedString(@"一键清空", nil) forState:UIControlStateNormal];
        [self addSubview:_clearAllButton];
        [_clearAllButton addTarget:self action:@selector(didTapDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [_clearAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset([TTDeviceUIUtils tt_padding:13.f]);
            make.centerY.equalTo(self);
        }];
    }
}

- (void)setupDeleteButton {
    if (!_deleteButton) {
        _deleteButton = [[TTAlphaThemedButton alloc] init];
        _deleteButton.enableHighlightAnim = YES;
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]];
        _deleteButton.titleColorThemeKey = kColorText4;
        _deleteButton.disabledTitleColorThemeKey = kColorText3;
        [_deleteButton setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
        [_deleteButton addTarget:self action:@selector(didTapDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).with.offset(-[TTDeviceUIUtils tt_padding:13.f]);
            make.centerY.equalTo(self);
        }];
    }
}

- (void)setupTopLine {
    SSThemedView *bottomLine = [[SSThemedView alloc] init];
    bottomLine.backgroundColorThemeKey = kColorLine10;
    [self addSubview:bottomLine];
    
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@([TTDeviceHelper ssOnePixel]));
        make.bottom.equalTo(self.mas_top);
        make.left.right.equalTo(self);
    }];
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    [_clearAllButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset([TTDeviceUIUtils tt_padding:13.f]);
        make.centerY.equalTo(self).offset(-self.tt_safeAreaInsets.bottom / 2);
    }];
    [_deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-[TTDeviceUIUtils tt_padding:13.f]);
        make.centerY.equalTo(self).offset(-self.tt_safeAreaInsets.bottom / 2);
    }];
}

#pragma mark - Public Method

- (void)changeDeletingCountIfNeeded {
    
    long long totalCount = 0;
    long long seperatedCount = self.viewModel.deletingItems.count;
    __block long long groupCount = 0;
    if ([self.viewModel isKindOfClass:[TTFeedHistoryViewModel class]]) {
        
        [((TTFeedHistoryViewModel *)self.viewModel).deletingGroups enumerateObjectsUsingBlock:^(TTHistoryEntryGroup * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.isDeleting) {
                groupCount += obj.totalCount - obj.excludeItems.count;
            }
        }];
    }
    totalCount = seperatedCount + groupCount;
    
    self.totalDeletingCount = totalCount;
    self.deleteButton.enabled = totalCount != 0;
    
    if(totalCount > 0) {
        [self.deleteButton setTitle:[NSString stringWithFormat:@"删除(%lld)", totalCount] forState:UIControlStateNormal];
        self.deleteButton.enabled = YES;
        
    } else {
        [self.deleteButton setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
        self.deleteButton.enabled = NO;
    }
    
    [self.deleteButton updateConstraintsIfNeeded];
}

#pragma mark - Tap Response

- (void)didTapDeleteButton:(id)sender {
    WeakSelf;
    if([self.delegate respondsToSelector:@selector(deleteTitleString)]) {
        [self showDeleteAlertViewClearAll:sender == self.clearAllButton finishBlock:^(BOOL isConfirmed) {
            StrongSelf;
            if (isConfirmed) {
                if (self.didDelete) {
                    self.didDelete(sender == self.clearAllButton ? YES : NO, self.viewModel);
                }
            }
        }];
    }
}

- (void)addKVO {
    [self.viewModel addObserver:self
                     forKeyPath:@"deletingItems.@count"
                        options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
                        context:nil];
}

- (void)removeKVO {
    [self.viewModel removeObserver:self forKeyPath:@"deletingItems.@count"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.viewModel && [keyPath isEqualToString:@"deletingItems.@count"]) {
        [self changeDeletingCountIfNeeded];
    }
}

- (void)showDeleteAlertViewClearAll:(BOOL)clearAll finishBlock:(void(^)(BOOL isConfirmed))finishBlock {
    
    NSString *titleString = nil;
    
    titleString = clearAll ? [self.delegate clearAllTitleString] : [self.delegate deleteTitleString];
    
    if (isEmptyString(titleString)) {
        return;
    }
    
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(titleString, nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        finishBlock(NO);
    }];
    [alert addActionWithTitle:clearAll ? NSLocalizedString(@"清空", nil) :NSLocalizedString(@"删除", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        finishBlock(YES);
    }];
    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
}

@end
