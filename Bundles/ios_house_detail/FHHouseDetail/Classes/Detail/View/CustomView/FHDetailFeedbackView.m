//
//  FHDetailFeedbackView.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/7/16.
//

#import "FHDetailFeedbackView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "TTAccountManager.h"
#import "FHEnvContext.h"
#import "FHDetailOldModel.h"
#import "FHDetailRentModel.h"
#import "FHDetailHouseOutlineInfoCell.h"
#import "FHURLSettings.h"
#import "ToastManager.h"
#import "FHHouseDetailAPI.h"
#import "TTReachability.h"
#import "FHUserTracker.h"
#import "TTDeviceHelper.h"
#import "HPGrowingTextView.h"
#import "UIColor+TTVideo.h"
#import "MAAnnotationView.h"
#import "YYTextView.h"
#import "NSString+BTDAdditions.h"
#import "SSCommonLogic.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "TTSandBoxHelper.h"
#import <TTBaseLib/UITextView+TTAdditions.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define CellId @"cellid"
#define KEY_CONTENT_SIZE @"contentSize"
#define DEFAULT_DIALOG_HEIGHT  100
#define MAX_LENGTH 300


@interface FHBCommonSelectItemCell : UICollectionViewCell

@property(nonatomic, strong) UILabel *label;
@property(nonatomic, assign) BOOL isSelected;

@end

@interface FHDetailFeedbackView () <UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate>

@property(nonatomic, strong) UIView *emptyView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIButton *closeBtn;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *dividerView;

@property(nonatomic, strong) UILabel *starInfoLabel;
@property(nonatomic, strong) UILabel *lengthInfoLabel;
@property(nonatomic, strong) UITextView *inputTextView;
@property(nonatomic, strong) UITextView *placeHolderTextView;
@property(nonatomic, strong) UIView *inputTextViewBg;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIButton *btnConfirm;

//Star Button
@property(nonatomic, strong) UIButton *starBtn1;
@property(nonatomic, strong) UIButton *starBtn2;
@property(nonatomic, strong) UIButton *starBtn3;
@property(nonatomic, strong) UIButton *starBtn4;
@property(nonatomic, strong) UIButton *starBtn5;
@property(nonatomic, strong) NSMutableArray *starBtnArray;


@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, copy) NSString *imprId;
@property(nonatomic, copy) NSString *searchId;

@property(nonatomic, strong) NSMutableArray *selections;
@property(nonatomic, assign) BOOL *hasShowInputView;
@property(nonatomic, strong) NSMutableArray *selectionedArray;
@property(nonatomic, assign) NSInteger selectStar;

@end

@implementation FHDetailFeedbackView

- (void)show:(UIView *)parentView {
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(parentView);
    }];
    [self initVars];
    [self traceRealtorEvaluatePopupShow];
}

- (void)hide {
    [self removeFromSuperview];
}

- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:KEY_CONTENT_SIZE];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstaints];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeNotifiction:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
        [self resetViewState];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];

    self.emptyView = [[UIView alloc] init];
    _emptyView.backgroundColor = [UIColor clearColor];
    _emptyView.userInteractionEnabled = YES;
    [self addSubview:_emptyView];

    self.containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.userInteractionEnabled = YES;
    [self addSubview:_containerView];

    self.titleLabel = [self labelWithFont:[UIFont themeFontMedium:18] textColor:[UIColor themeGray1]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"您对沟通的经纪人是否满意";
    [self.containerView addSubview:_titleLabel];

    self.closeBtn = [[UIButton alloc] init];
    UIImage *img = ICON_FONT_IMG(24, @"\U0000e673", nil);
    [_closeBtn setImage:img forState:UIControlStateNormal];
    _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:_closeBtn];

    _dividerView = [[UIView alloc] init];
    [_dividerView setBackgroundColor:[UIColor colorWithHexStr:@"#e8eaeb"]];
    [self.containerView addSubview:_dividerView];

    self.starBtn1 = [self createStarButton:1];
    [self.containerView addSubview:_starBtn1];

    self.starBtn2 = [self createStarButton:2];
    [self.containerView addSubview:_starBtn2];

    self.starBtn3 = [self createStarButton:3];
    [self.containerView addSubview:_starBtn3];

    self.starBtn4 = [self createStarButton:4];
    [self.containerView addSubview:_starBtn4];

    self.starBtn5 = [self createStarButton:5];
    [self.containerView addSubview:_starBtn5];

    _starBtnArray = [[NSMutableArray alloc] initWithCapacity:5];
    [_starBtnArray addObject:self.starBtn1];
    [_starBtnArray addObject:self.starBtn2];
    [_starBtnArray addObject:self.starBtn3];
    [_starBtnArray addObject:self.starBtn4];
    [_starBtnArray addObject:self.starBtn5];

    _starInfoLabel = [self labelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    _starInfoLabel.text = @"您的评价会让经纪人做的更好";
    _starInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:_starInfoLabel];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 14;
    layout.itemSize = CGSizeMake((SCREEN_WIDTH - 30 * 2 - 11) / 2, 36);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.allowsMultipleSelection = YES;
    _collectionView.allowsSelection = YES;
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:[FHBCommonSelectItemCell class] forCellWithReuseIdentifier:CellId];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView addObserver:self forKeyPath:KEY_CONTENT_SIZE options:NSKeyValueObservingOptionNew context:nil];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.containerView addSubview:_collectionView];

    _inputTextViewBg = [[UIView alloc] init];
    _inputTextViewBg.layer.cornerRadius = 4;
    _inputTextViewBg.layer.masksToBounds = YES;
    _inputTextViewBg.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_inputTextViewBg];

    _inputTextView = [[UITextView alloc] init];
    _inputTextView.editable = YES;
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.textContainer.lineFragmentPadding = 0;
    _inputTextView.textContainerInset = UIEdgeInsetsZero;
    _inputTextView.textColor = [UIColor themeGray1];
    _inputTextView.font = [UIFont themeFontRegular:14];
    _inputTextView.delegate = self;
    [self.containerView addSubview:_inputTextView];

    _placeHolderTextView = [[UITextView alloc] init];
    _placeHolderTextView.text = @"您可输入具体评价，以便经纪人为您提供更好的服务";
    _placeHolderTextView.editable = NO;
    _placeHolderTextView.userInteractionEnabled = NO;
    _placeHolderTextView.backgroundColor = [UIColor clearColor];
    _placeHolderTextView.textContainer.lineFragmentPadding = 0;
    _placeHolderTextView.textContainerInset = UIEdgeInsetsZero;
    _placeHolderTextView.textColor = [UIColor themeGray4];
    _placeHolderTextView.font = [UIFont themeFontRegular:14];
    [self.containerView addSubview:_placeHolderTextView];

    _lengthInfoLabel = [self labelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    _lengthInfoLabel.text = [NSString stringWithFormat:@"%d/%d", 0, 300];
    _lengthInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:_lengthInfoLabel];

    _btnConfirm = [[UIButton alloc] init];
    [_btnConfirm setTitle:@"匿名提交" forState:UIControlStateNormal];
    [_btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnConfirm setBackgroundColor:[UIColor colorWithHexString:@"#ff5869" alpha:0.3]];
    _btnConfirm.layer.cornerRadius = 4;
    [_btnConfirm addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _btnConfirm.enabled = NO;
    [self.containerView addSubview:_btnConfirm];

    self.bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:_bottomView];
}


- (void)checkConfirmButtonEnableState {
    BOOL enabled = YES;

    if ([SSCommonLogic isForceEnableRealtorConfirmBtn]) {
        enabled = YES;
    } else {
        if (self.selectStar < 4) {
            if (self.inputTextView.text.length >= 5 && !isEmptyString([self.inputTextView.text btd_trimmed])) {
                enabled = YES;
            } else {
                enabled = NO;
            }
        } else {
            enabled = YES;
        }
    }

    if (enabled) {
        [self.btnConfirm setBackgroundColor:[UIColor colorWithHexString:@"#ff5869"]];
        self.btnConfirm.enabled = YES;
    } else {
        [self.btnConfirm setBackgroundColor:[UIColor colorWithHexString:@"#ff5869" alpha:0.3]];
        self.btnConfirm.enabled = NO;
    }
}


- (void)hideInputView {
    self.hasShowInputView = NO;

    //TODO if reset view updateConstraints CollectionView & inputView
    [self.starBtn3 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dividerView.mas_bottom).offset(30);
    }];

    [self.inputTextViewBg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];

    [self.inputTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
}

- (void)showInputView {
    self.hasShowInputView = YES;

    [self.starBtn3 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dividerView.mas_bottom).offset(20);
    }];

    [self.inputTextViewBg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(80);
        make.top.mas_equalTo(self.collectionView.mas_bottom).mas_offset(14);
    }];

    [self.inputTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];

    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.starInfoLabel.mas_bottom).mas_offset(20);
    }];
}


- (void)resetViewState {
    [self hideInputView];
    self.lengthInfoLabel.hidden = YES;
    _selectStar = -1;
}

- (void)initConstaints {
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }

    if (bottom < 0) {
        bottom = 0;
    }

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_greaterThanOrEqualTo(241 + bottom);
    }];

    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.containerView.mas_top);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(18);
        make.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(25);
    }];

    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.width.height.mas_equalTo(20);
    }];

    [self.dividerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(17);
        make.width.mas_equalTo(self.containerView);
    }];

    [self.starBtn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dividerView.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.containerView);
        make.width.height.mas_equalTo(30);
    }];

    [self.starBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.starBtn3);
        make.right.mas_equalTo(self.starBtn3.mas_left).mas_offset(-20);
        make.width.height.mas_equalTo(30);
    }];

    [self.starBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.starBtn3);
        make.right.mas_equalTo(self.starBtn2.mas_left).mas_offset(-20);
        make.width.height.mas_equalTo(30);
    }];

    [self.starBtn4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.starBtn3);
        make.left.mas_equalTo(self.starBtn3.mas_right).mas_offset(20);
        make.width.height.mas_equalTo(30);
    }];

    [self.starBtn5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.starBtn3);
        make.left.mas_equalTo(self.starBtn4.mas_right).mas_offset(20);
        make.width.height.mas_equalTo(30);
    }];

    [self.starInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.starBtn3.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(20);
    }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.starInfoLabel.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.containerView).offset(30);
        make.right.mas_equalTo(self.containerView).offset(-30);
        make.height.mas_equalTo(0);
    }];

    [self.inputTextViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).offset(30);
        make.right.mas_equalTo(self.containerView).offset(-30);
        make.height.mas_equalTo(60);
        make.top.mas_equalTo(self.collectionView.mas_bottom).mas_offset(0);
    }];

    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.inputTextViewBg).offset(10);
        make.right.mas_equalTo(self.inputTextViewBg).offset(-10);
        make.top.mas_equalTo(self.inputTextViewBg).offset(10);
        make.height.mas_equalTo(40);
    }];

    [self.placeHolderTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.inputTextView);
    }];

    [self.lengthInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.inputTextViewBg.mas_right).offset(-10);
        make.bottom.mas_equalTo(self.inputTextViewBg.mas_bottom).mas_offset(-5);
        make.height.mas_equalTo(20);
    }];

    [self.btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(self.inputTextViewBg.mas_bottom).mas_offset(20);
        make.left.mas_equalTo(self.containerView).mas_offset(30);
        make.right.mas_equalTo(self.containerView).mas_offset(-30);
    }];

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.btnConfirm.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(bottom + 0.5);
    }];
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (UIButton *)createStarButton:(NSInteger)tag {
    UIButton *btn = [[UIButton alloc] init];
    btn.imageView.contentMode = UIViewContentModeCenter;
    UIImage *img = [UIImage imageNamed:@"detail_feedback_star_grey"];
    [btn setImage:img forState:UIControlStateNormal];
    btn.tag = tag;
    btn.adjustsImageWhenHighlighted = NO;
    [btn addTarget:self action:@selector(starBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)setStarButtonSelected:(UIButton *)btn select:(BOOL)select {
    if (select) {
        UIImage *img = [UIImage imageNamed:@"detail_feedback_star_yellow"];
        [btn setImage:img forState:UIControlStateNormal];
    } else {
        UIImage *img = [UIImage imageNamed:@"detail_feedback_star_grey"];
        [btn setImage:img forState:UIControlStateNormal];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:KEY_CONTENT_SIZE]) {
        NSValue *value = change[NSKeyValueChangeNewKey];
        if (value) {
            CGSize size = [value CGSizeValue];
            if (size.height > 1) {
                [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(size.height);
                }];
                [self layoutIfNeeded];
            }
        }
    }
}

- (NSMutableArray *)selectionedArray {
    if (!_selectionedArray) {
        _selectionedArray = [[NSMutableArray alloc] init];
    }
    return _selectionedArray;
}

- (void)initVars {
    id data = self.viewModel.detailData;
    if ([data isKindOfClass:[FHDetailOldModel class]]) {
        FHDetailOldModel *model = (FHDetailOldModel *) data;

        if (model.data.logPb[@"impr_id"]) {
            self.imprId = model.data.logPb[@"impr_id"];
        }

        if (model.data.logPb[@"search_id"]) {
            self.searchId = model.data.logPb[@"search_id"];
        }
    }
}

- (void)starBtnClick:(id)sender {
    UIButton *btn = (UIButton *) sender;
    NSInteger tag = btn.tag;
    if (tag == self.selectStar) {
        return;
    }
    self.selectStar = tag;

    for (int i = 0; i < tag && i < self.starBtnArray.count; i++) {
        if ([[self.starBtnArray objectAtIndex:i] respondsToSelector:@selector(setSelected:)]) {
            [self setStarButtonSelected:[self.starBtnArray objectAtIndex:i] select:YES];
        }
    }

    for (int i = tag; i < self.starBtnArray.count; i++) {
        if ([[self.starBtnArray objectAtIndex:i] respondsToSelector:@selector(setSelected:)]) {
            [self setStarButtonSelected:[self.starBtnArray objectAtIndex:i] select:NO];
        }
    }

    if (!self.hasShowInputView) {
        [self showInputView];
    }

    FHRealtorEvaluatioinConfigModel *realtorEvaluatioinConfigModel = [[FHEnvContext sharedInstance] getConfigFromCache].realtorEvaluationConfig;

    [self.starInfoLabel setTextColor:[UIColor colorWithHexString:@"#ff8151"]];
    if (tag > 0 && tag <= realtorEvaluatioinConfigModel.scoreTags.count) {
        [self.starInfoLabel setText:[realtorEvaluatioinConfigModel.scoreTags objectAtIndex:(tag - 1)]];
    } else {
        if (tag == 1) {
            [self.starInfoLabel setText:@"非常不满意"];
        } else if (tag == 2) {
            [self.starInfoLabel setText:@"不满意"];
        } else if (tag == 3) {
            [self.starInfoLabel setText:@"一般"];
        } else if (tag == 4) {
            [self.starInfoLabel setText:@"满意"];
        } else if (tag == 5) {
            [self.starInfoLabel setText:@"非常满意"];
        }
    }

    if (tag >= 4) {
        self.placeHolderTextView.text = !isEmptyString(realtorEvaluatioinConfigModel.goodPlaceholder) ? realtorEvaluatioinConfigModel.goodPlaceholder : @"您可输入具体评价，以便经纪人为您提供更好的服务";
//        if (self.selectStar <=3 || self.selectStar < 0) {
        self.selections = realtorEvaluatioinConfigModel.goodTags;
        [self.collectionView reloadData];
//        }
        [self checkConfirmButtonEnableState];
    } else {
        self.placeHolderTextView.text = !isEmptyString(realtorEvaluatioinConfigModel.badPlaceholder) ? realtorEvaluatioinConfigModel.badPlaceholder : @"请输入不少于5个字的评价，让经纪人做得更好";
        [self checkConfirmButtonEnableState];
//        if (self.selectStar > 3 || self.selectStar < 0) {
        self.selections = realtorEvaluatioinConfigModel.badTags;
        [self.collectionView reloadData];
//        }
    }
}

- (void)btnClick:(id)sender {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }

    UIButton *btn = (UIButton *) sender;
    NSInteger tag = btn.tag;
    [self hide];


    NSMutableArray *tags = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.selectionedArray.count; i++) {
        if ([[self.selectionedArray objectAtIndex:i] isKindOfClass:[FHRealtorEvaluatioinTagModel class]]) {
            FHRealtorEvaluatioinTagModel *model = [self.selectionedArray objectAtIndex:i];
            [tags addObject:model.id];
        }
    }

    [FHHouseDetailAPI requestRealtorEvaluationFeedback:self.viewModel.houseId realtorId:self.realtorId content:self.inputTextView.text score:self.selectStar
                                                  tags:tags completion:^(bool succss, NSError *_Nonnull error) {
                if (succss) {
                    [[ToastManager manager] showToast:@"提交成功，感谢您的评价"];
                } else {
                    [[ToastManager manager] showToast:@"提交失败"];
                }
            }];
    [self traceRealtorEvaluatePopupClick:@"confirm" starNum:[NSString stringWithFormat:@"%i", self.selectStar]];
}

- (void)close {
    [self hide];
    [self traceRealtorEvaluatePopupClick:@"cancel" starNum:@"0"];
    [[ToastManager manager] showToast:@"您未提交评价"];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (self.placeHolderTextView) {
        self.placeHolderTextView.hidden = textView.text.length > 0 ? YES : NO;
    }
    NSString *str = textView.text;
    if (str.length > MAX_LENGTH) {
        self.inputTextView.text = [str substringToIndex:MAX_LENGTH];
    }
    self.lengthInfoLabel.text = [NSString stringWithFormat:@"%d/%d", self.inputTextView.text.length, MAX_LENGTH];

    if (self.inputTextView.text.length > 0) {
        self.lengthInfoLabel.hidden = NO;
    } else {
        self.lengthInfoLabel.hidden = YES;
    }

    [self checkConfirmButtonEnableState];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

}

#pragma mark - keyboard

- (void)keyboardWillChangeNotifiction:(NSNotification *)notification {
    NSValue *beginInfoValue = notification.userInfo[UIKeyboardFrameBeginUserInfoKey];
    NSValue *endInfoValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];

    CGRect frame;
    [endInfoValue getValue:&frame];

    frame = [self convertRect:frame toView:self];

    CGRect bframe;
    [beginInfoValue getValue:&bframe];

    bframe = [self convertRect:bframe toView:self];

    self.bottom = CGRectGetMinY(bframe);

    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions) [curve integerValue] animations:^{
        self.bottom = CGRectGetMinY(frame);
    }                completion:^(BOOL finished) {

    }];
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    NSValue *endInfoValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];

    CGRect frame;
    [endInfoValue getValue:&frame];
    frame = [self.viewController.view convertRect:frame toView:self.viewController.view];

    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions) [curve integerValue] animations:^{
        self.bottom = CGRectGetMinY(frame);
    }                completion:^(BOOL finished) {

    }];
}

#pragma mark -- collection view--

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selections.count > 6 ? 6 : self.selections.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHBCommonSelectItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];

    if ([self.selections[indexPath.item] isKindOfClass:[FHRealtorEvaluatioinTagModel class]]) {
        FHRealtorEvaluatioinTagModel *model = self.selections[indexPath.item];
        [cell.label setText:model.text];
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldSelect = YES;
    BOOL isContain = [[collectionView indexPathsForSelectedItems] containsObject:indexPath];
    if (isContain) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self.selectionedArray removeObject:self.selections[indexPath.item]];
        shouldSelect = NO;
    }
    return shouldSelect;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectionedArray removeObject:self.selections[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectionedArray addObject:self.selections[indexPath.item]];
}

#pragma mark - 埋点相关

- (void)traceRealtorEvaluatePopupShow {
    NSMutableDictionary *tracerDic = [self.viewModel.detailTracerDic mutableCopy];
    tracerDic[@"realtor_id"] = self.realtorId ? self.realtorId : @"be_null";
    tracerDic[@"request_id"] = self.requestId ?: UT_BE_NULL;
    if (self.viewModel.contactViewModel && self.viewModel.contactViewModel.contactPhone) {
        tracerDic[@"realtor_logpb"] = self.viewModel.contactViewModel.contactPhone.realtorLogpb;
    } else {
        tracerDic[@"realtor_logpb"] = UT_BE_NULL;
    }
    TRACK_EVENT(@"realtor_evaluate_popup_show", tracerDic);
}

- (void)traceRealtorEvaluatePopupClick:(NSString *)position starNum:(NSString *)num {
    NSMutableDictionary *tracerDic = [self.viewModel.detailTracerDic mutableCopy];
    tracerDic[@"realtor_id"] = self.realtorId ? self.realtorId : @"be_null";
    tracerDic[@"click_position"] = position ? position : @"be_null";
    tracerDic[@"request_id"] = self.requestId ?: UT_BE_NULL;
    tracerDic[@"star_num"] = num ? num : @"be_null";
    if (self.viewModel.contactViewModel && self.viewModel.contactViewModel.contactPhone) {
        tracerDic[@"realtor_logpb"] = self.viewModel.contactViewModel.contactPhone.realtorLogpb;
    } else {
        tracerDic[@"realtor_logpb"] = UT_BE_NULL;
    }
    TRACK_EVENT(@"realtor_evaluate_popup_click", tracerDic);
}

- (void)traceClickFeedback {
    NSMutableDictionary *tracerDic = [self.viewModel.detailTracerDic mutableCopy];
    tracerDic[@"enter_from"] = @"realtor_evaluate_popup";
    tracerDic[@"realtor_id"] = self.realtorId ?: UT_BE_NULL;
    tracerDic[@"request_id"] = self.requestId ?: UT_BE_NULL;
    TRACK_EVENT(@"click_feedback", tracerDic);
}


@end


@implementation FHBCommonSelectItemCell {


}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isSelected = NO;
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.layer.cornerRadius = 4;
        _label.layer.masksToBounds = YES;
        _label.layer.borderWidth = 0.5f;
        _label.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        [_label setBackgroundColor:[UIColor whiteColor]];
        [_label setTextColor:[UIColor themeGray2]];
        [_label setFont:[UIFont systemFontOfSize:14]];
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        [self.label setBackgroundColor:[UIColor colorWithHexStr:@"#fff2ed"]];
        [self.label setTextColor:[UIColor colorWithHexStr:@"#ff8151"]];
        self.label.layer.borderColor = [UIColor colorWithHexString:@"#ff8151"].CGColor;
    } else {
        [self.label setBackgroundColor:[UIColor whiteColor]];
        [self.label setTextColor:[UIColor themeGray2]];
        self.label.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
    }
}
@end
