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

#define REGION_CELL_ID @"region_cell_id"

@interface FHHouseFindHelpRegionItemCell: UITableViewCell

@property(nonatomic, strong)UILabel *regionLabel;
@property(nonatomic, strong)UIImageView *selectImgView;
@property(nonatomic, assign)BOOL regionSelected;

@end

@implementation FHHouseFindHelpRegionItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.regionLabel];
    [self.contentView addSubview:self.selectImgView];
    
    [self.regionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(20);
        make.height.mas_equalTo(22);
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


@interface FHHouseFindHelpRegionSheet () <UITableViewDataSource, UITableViewDelegate>
{
    UIView *_bgView;
}
@property(nonatomic, strong)UIView *contentView;
@property(nonatomic, strong)UIButton *cancelBtn;
@property(nonatomic, strong)UIButton *finishBtn;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray *itemList;

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
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.cancelBtn];
    [self.contentView addSubview:self.finishBtn];
    [self.contentView addSubview:self.tableView];
    [self.tableView registerClass:[FHHouseFindHelpRegionItemCell class] forCellReuseIdentifier:REGION_CELL_ID];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.finishBtn addTarget:self action:@selector(finishBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
//        make.height.mas_equalTo(REGION_CONTENT_HEIGHT);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(42);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(52);
        make.top.mas_equalTo(0);
    }];
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(42);
        make.right.mas_equalTo(-10);
        make.width.mas_equalTo(52);
        make.top.mas_equalTo(0);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cancelBtn.mas_bottom);
        make.left.right.bottom.mas_equalTo(0);
    }];
}

- (void)showWithItemList:(NSArray *)itemList
{
    if (itemList.count < 1) {
        return;
    }
    _itemList = itemList;
    [self.tableView reloadData];
    
    _bgView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0;
    [[UIApplication sharedApplication].delegate.window addSubview:_bgView];
    _bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [_bgView addGestureRecognizer:tap];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    self.top = screenHeight;
    [UIView animateWithDuration:0.25 animations:^{
        self->_bgView.alpha = 0.4;
        self.top = screenHeight - REGION_CONTENT_HEIGHT;
    }];
    
}

- (void)finishBtnDidClick:(UIButton *)btn
{
    NSArray *itemList = @[];
    if (self.selectItemsBlock) {
        self.selectItemsBlock(itemList);
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

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _itemList.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseFindHelpRegionItemCell *cell = [tableView dequeueReusableCellWithIdentifier:REGION_CELL_ID];
    // add by zjing for test
    cell.regionLabel.text = @"朝阳";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor themeGray7];
    }
    return _contentView;
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
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, [UIApplication sharedApplication].delegate.window.tt_safeAreaInsets.bottom, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

@end
