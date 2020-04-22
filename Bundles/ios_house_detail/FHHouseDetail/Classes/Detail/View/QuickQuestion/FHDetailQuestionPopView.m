//
//  FHDetailQuestionPopView.m
//  FHBAccount
//
//  Created by 张静 on 2019/10/11.
//

#import "FHDetailQuestionPopView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "Masonry.h"
#import <TTThemed/SSThemed.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <FHCommonUI/FHRoundShadowView.h>
#import "FHDetailQuestionButton.h"
#import <FHHouseBase/UIImage+FIconFont.h>

#define LEFT_MARGIN 10
#define TOP_MARGIN 5
#define kFHDetailPopCellId @"kFHDetailPopCellId"
#define CELLWIDTH 46

@implementation FHDetailQuestionPopMenuItem



@end

@interface FHDetailQuestionPopItemCell: UITableViewCell

@property(nonatomic , strong) FHRoundShadowView *shadowView;
@property(nonatomic , strong) UIView *containerView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIImageView *rightArrow;

@end

@implementation FHDetailQuestionPopItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self initConstraints];
    }
    return self;
}

- (void)setupUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.shadowView];
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.rightArrow];
}

- (void)initConstraints
{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(LEFT_MARGIN);
        make.right.mas_equalTo(-LEFT_MARGIN);
        make.top.mas_equalTo(TOP_MARGIN);
        make.bottom.mas_equalTo(-TOP_MARGIN);
    }];
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.containerView);
        make.right.mas_equalTo(self.rightArrow.mas_left).mas_offset(1);
    }];
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16);
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self.titleLabel);
    }];
}

- (UIView *)shadowView
{
    if (!_shadowView) {
        _shadowView = [[FHRoundShadowView alloc] initWithFrame:CGRectZero];
        _shadowView.layer.shadowColor = [[UIColor colorWithHexString:@"#000000" alpha:0.1] CGColor];
    }
    return _shadowView;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        CALayer * layer = _containerView.layer;
        layer.borderColor = [UIColor themeGray6].CGColor;
        layer.borderWidth = 0.5;
        layer.cornerRadius = 4;
        layer.masksToBounds = YES;
    }
    return _containerView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.font = [UIFont themeFontRegular:14];
    }
    return _titleLabel;
}

- (UIImageView *)rightArrow
{
    if (!_rightArrow) {
        _rightArrow = [[UIImageView alloc]initWithImage:ICON_FONT_IMG(14, @"\U0000e6c3", [UIColor themeRed1])];
    }
    return _rightArrow;
}

@end

@interface FHDetailQuestionPopView () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIControl *contentBgView;
@property(nonatomic,strong)UIButton *maskView;
@property(nonatomic, assign)CGPoint arrowPoint;
@property(nonatomic , strong) FHDetailQuestionButton *questionBtn;

@end

@implementation FHDetailQuestionPopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.frame = [UIScreen mainScreen].bounds;
    self.contentBgView = [[UIControl alloc] initWithFrame:self.bounds];
    self.contentBgView.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.4];
    [self addSubview:_contentBgView];

    [self.contentBgView addSubview:self.questionBtn];
    [self.contentBgView addSubview:self.tableView];

    CGFloat bottomMargin = 0;
    if (@available(iOS 11.0, *)) {
        bottomMargin = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
    }

    CGFloat width = 260;
    CGFloat height = CELLWIDTH * self.menus.count;
    [self.questionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(-80 - bottomMargin);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.width.mas_equalTo(width);
        make.bottom.mas_equalTo(self.questionBtn.mas_top).mas_offset(height / 2);
        make.height.mas_equalTo(0);
    }];
    
    self.questionBtn.isFold = NO;
    [self.questionBtn.btn addTarget:self action:@selector(questionBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[FHDetailQuestionPopItemCell class] forCellReuseIdentifier:kFHDetailPopCellId];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;

    [self.contentBgView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.bottom = self.questionBtn.top + self.tableView.height / 2;
}

- (void)questionBtnDidClick:(UIButton *)btn
{
    self.questionBtn.isFold = !self.questionBtn.isFold;
    if (self.questionBtn.isFold) {
        [self dismiss];
    }
}

- (void)setMenus:(NSArray<FHDetailQuestionPopMenuItem *> *)menus
{
    _menus = menus;
}

- (void)updateTitle:(NSString *)title
{
    [self.questionBtn updateTitle:title];
}

- (void)showAtPoint:(CGPoint)p parentView:(UIView *)parentView
{
    self.maskView = [UIButton buttonWithType:UIButtonTypeCustom];
    _maskView.frame = [UIScreen mainScreen].bounds;
    [_maskView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_maskView addSubview:self];
    
    UIWindow *currentWindow = SSGetMainWindow();
    UIView *superView = currentWindow;
    [superView addSubview:_maskView];

    _arrowPoint = p;

    [self refreshUI];
    [self.tableView reloadData];
    self.tableView.contentSize = CGSizeMake(self.tableView.width, self.tableView.height);
    self.tableView.bottom = self.questionBtn.top + self.tableView.height / 2;

    self.alpha = 0.f;
    _maskView.alpha = 0.f;
    self.tableView.transform = CGAffineTransformMakeScale(1, 0.1f);
    self.tableView.layer.anchorPoint = CGPointMake(0.5, 1);

    self.alpha = 1.f;
    self.maskView.alpha = 1.f;

    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.tableView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)dismiss
{
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animated
{
    if (!animated) {
        self.alpha = 0.f;
        [_maskView removeFromSuperview];
        _maskView = nil;
        [self removeFromSuperview];
        return;
    }
    self.questionBtn.hidden = YES;
    if (self.completionBlock) {
        self.completionBlock();
    }
    [UIView animateWithDuration:0.3f animations:^{
        self->_maskView.alpha = 0.f;
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self->_maskView removeFromSuperview];
        self.maskView = nil;
        [self removeFromSuperview];
    }];
}

- (void)refreshUI
{
    CGPoint arrowPoint = [self convertPoint:self.arrowPoint toView:self.contentBgView];

    CGFloat height = CELLWIDTH * self.menus.count;
    CGFloat width = 260;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height + 5);
        make.bottom.mas_equalTo(self.questionBtn.mas_top).mas_offset(height / 2);
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FHDetailQuestionPopItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHDetailPopCellId];
    if(indexPath.row < self.menus.count) {
        FHDetailQuestionPopMenuItem *item = self.menus[indexPath.row];
        if ([item isKindOfClass:[FHDetailQuestionPopMenuItem class]]) {
            cell.titleLabel.text = item.title;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELLWIDTH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.menus.count) {
        FHDetailQuestionPopMenuItem *item = self.menus[indexPath.row];
        if (![item isKindOfClass:[FHDetailQuestionPopMenuItem class]]) {
            return;
        }
        if (item.itemClickBlock) {
            item.itemClickBlock(item);
        };
        [self dismiss];
    }
}


- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero];
        if (@available(iOS 11.0 , *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (FHDetailQuestionButton *)questionBtn
{
    if (!_questionBtn) {
        _questionBtn = [[FHDetailQuestionButton alloc]init];
        _questionBtn.isFold = YES;
    }
    return _questionBtn;
}

@end
