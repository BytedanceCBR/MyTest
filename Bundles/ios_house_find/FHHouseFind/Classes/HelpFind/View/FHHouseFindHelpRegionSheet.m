//
//  FHHouseFindHelpRegionSheet.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/27.
//

#import "FHHouseFindHelpRegionSheet.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry.h>
#import <FHCommonUI/UIView+House.h>


@implementation FHHouseFindHelpRegionItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setRegionSelected:(BOOL)regionSelected
{
    _regionSelected = regionSelected;
    if (regionSelected) {
        self.selectImgView.image = [UIImage imageNamed:@"housefind_selected"];
        self.regionLabel.textColor = [UIColor themeRed1];
    }else {
        self.selectImgView.image = [UIImage imageNamed:@"housefind_normal"];
        self.regionLabel.textColor = [UIColor themeGray1];
    }
}

- (void)setupUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.regionLabel];
    [self.contentView addSubview:self.selectImgView];
    
    [self.regionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(20);
        make.height.mas_equalTo(24);
    }];
    [self.selectImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.regionLabel);
        make.right.mas_equalTo(-20);
    }];
}

- (UIImageView *)selectImgView
{
    if (!_selectImgView) {
        _selectImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"housefind_normal"]];
    }
    return _selectImgView;
}

- (UILabel *)regionLabel
{
    if (!_regionLabel) {
        _regionLabel = [[UILabel alloc]init];
        _regionLabel.text = @"请选择区域";
        _regionLabel.textColor = [UIColor themeGray1];
        _regionLabel.font = [UIFont themeFontRegular:14];
    }
    return _regionLabel;
}

@end


@interface FHHouseFindHelpRegionSheet ()
{
    UIView *_bgView;
}
@property(nonatomic, strong )UIView *contentView;
@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UIButton *cancelBtn;
@property(nonatomic, strong) UIButton *finishBtn;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, copy, nullable) FHHouseFindRegionCompleteBlock completeBlock;
@property(nonatomic, copy, nullable) FHHouseFindRegionCancelBlock cancelBlock;

@end

@implementation FHHouseFindHelpRegionSheet

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
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.cancelBtn];
    [self.contentView addSubview:self.finishBtn];
    [self.contentView addSubview:self.tableView];
    [self.tableView registerClass:[FHHouseFindHelpRegionItemCell class] forCellReuseIdentifier:REGION_CELL_ID];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.cancelBtn addTarget:self action:@selector(cancelBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.finishBtn addTarget:self action:@selector(finishBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(42);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.topView);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(52);
        make.top.mas_equalTo(0);
    }];
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.topView);
        make.right.mas_equalTo(-10);
        make.width.mas_equalTo(52);
        make.top.mas_equalTo(0);
    }];
    CGFloat bottomHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomHeight = [UIApplication sharedApplication].delegate.window.tt_safeAreaInsets.bottom;
    }
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cancelBtn.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(REGION_CONTENT_HEIGHT - 42);
    }];
}

- (void)setTableViewDelegate:(id)tableViewDelegate
{
    _tableView.delegate = tableViewDelegate;
    _tableView.dataSource = tableViewDelegate;
}

- (void)showWithCompleteBlock:(FHHouseFindRegionCompleteBlock)completeBlock cancelBlock:(FHHouseFindRegionCancelBlock)cancelBlock
{
    _completeBlock = completeBlock;
    _cancelBlock = cancelBlock;
    
    [self.tableView reloadData];
    
    _bgView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0;
    [[UIApplication sharedApplication].delegate.window addSubview:_bgView];
    _bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelBtnDidClick)];
    [_bgView addGestureRecognizer:tap];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    self.top = screenHeight;
    [UIView animateWithDuration:0.25 animations:^{
        self->_bgView.alpha = 0.4;
        self.top = screenHeight - self.height;
    }];
    
}

- (void)finishBtnDidClick:(UIButton *)btn
{
    if (self.completeBlock) {
        self.completeBlock();
    }
    [self dismiss];
}

- (void)cancelBtnDidClick
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss];
}

- (void)dismiss
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self->_bgView.alpha = 0;
        self.top = screenHeight;
        
    } completion:^(BOOL finished) {
        [self->_bgView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor themeGray7];
    }
    return _topView;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc]init];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateHighlighted];
        [_cancelBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateHighlighted];
    }
    return _cancelBtn;
}

- (UIButton *)finishBtn
{
    if (!_finishBtn) {
        _finishBtn = [[UIButton alloc]init];
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_finishBtn setTitle:@"完成" forState:UIControlStateHighlighted];
        [_finishBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        [_finishBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateHighlighted];
    }
    return _finishBtn;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

@end
