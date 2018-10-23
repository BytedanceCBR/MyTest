//
//  WDListQuestionHeaderTagView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/5/11.
//
//

#import "WDListQuestionHeaderTagView.h"
#import "WDListViewModel.h"
#import "WDQuestionEntity.h"
#import "WDQuestionTagEntity.h"
#import "WDSettingHelper.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import "TTUIResponderHelper.h"
#import "WDDefines.h"

#import <TTUIWidget/TTNavigationController.h>
#import <KVOController/NSObject+FBKVOController.h>


#define kCreateTagButtonWidth (58)
#define kEditTagButtonWidth (58)

@interface WDListQuestionHeaderTagView ()

@property (nonatomic, strong) WDListViewModel *viewModel;

@property (nonatomic, strong) WDListQuestionHeaderCollectionView *collectionView;
@property (nonatomic, strong) SSThemedButton *editTagButton;

// 和上面两个不会共存
@property (nonatomic, strong) SSThemedButton *createTagButton;

@end

@implementation WDListQuestionHeaderTagView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel {
    if (self = [super initWithFrame:frame]) {
        _viewModel = viewModel;
        
        self.backgroundColorThemeKey = kColorBackground4;
        
        // 三种情况：他人的没有按钮，只能看看；自己的有标签，显示编辑按钮；无标签仅显示添加按钮
        if ([TTDeviceHelper isPadDevice]) {
    
        }
        else if (_viewModel.canEditTags) {
            if (!_viewModel.hasTags) {
                [self addSubview:self.createTagButton];
            }
            else {
                [self addSubview:self.editTagButton];
                [self addSubview:self.collectionView];
            }
        }
        else {
            [self addSubview:self.collectionView];
        }
        
        WeakSelf;
        [self.KVOController observe:self.viewModel.questionEntity keyPath:@"tagEntities" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self reload];
        }];
        
        [self.KVOController observe:self.viewModel.questionEntity keyPath:@"shouldShowEdit" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self reload];
        }];
        
    }
    return self;
}

- (void)reload {
    CGFloat left = 0;
    CGFloat width = SSWidth(self);
    if ([TTDeviceHelper isPadDevice]) {
        
    }
    else if (_viewModel.canEditTags) {

    }
    else {
        // never happen here
        self.collectionView.width = width;
        [self.collectionView reloadData];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

# pragma mark response

- (void)enterEditTagVC {
    
}

- (void)editTagButtonClicked {
    [self enterEditTagVC];
}

- (void)createTagButtonClicked {
    [self enterEditTagVC];
}

# pragma mark getter 

- (SSThemedButton *)createTagButton {
    if (!_createTagButton) {
        _createTagButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, kCreateTagButtonWidth, SSHeight(self))];
        _createTagButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _createTagButton.titleColorThemeKey = kColorText5;
        _createTagButton.highlightedTitleColorThemeKey = kColorText5Highlighted;
        [_createTagButton setTitle:NSLocalizedString(@"添加标签", nil) forState:UIControlStateNormal];
        [_createTagButton addTarget:self action:@selector(createTagButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createTagButton;
}

- (SSThemedButton *)editTagButton {
    if (!_editTagButton) {
        CGFloat x = SSWidth(self) - kEditTagButtonWidth;
        _editTagButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(x, 0, kEditTagButtonWidth, SSHeight(self))];
        _editTagButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _editTagButton.titleColorThemeKey = kColorText5;
        _editTagButton.highlightedTitleColorThemeKey = kColorText5Highlighted;
        [_editTagButton setTitle:NSLocalizedString(@"编辑标签", nil) forState:UIControlStateNormal];
        [_editTagButton addTarget:self action:@selector(editTagButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editTagButton;
}

- (WDListQuestionHeaderCollectionView *)collectionView
{
    if (!_collectionView) {
        CGFloat width = SSWidth(self);
        if (_viewModel.canEditTags) {
            width = SSWidth(self) - kEditTagButtonWidth - kWDCellRightPadding;
        }
        _collectionView = [[WDListQuestionHeaderCollectionView alloc] initWithViewModel:self.viewModel frame:CGRectMake(0, 0, width, SSHeight(self))];
        _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _collectionView;
}

@end
