//
//  FHHouseFindHelpRegionCell.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/27.
//

#import "FHHouseFindHelpRegionCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>
#import "FHHouseFindHelpRegionSheet.h"

@interface FHHouseFindHelpRegionCell()

@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) UIImageView *foldArrow;
@property(nonatomic, strong) UILabel *regionLabel;

@end

@implementation FHHouseFindHelpRegionCell

- (void)updateWithTitle:(NSString *)title
{
    if (title.length > 0) {
        self.regionLabel.text = title;
        self.regionLabel.textColor = [UIColor themeGray1];
    }else {
        self.regionLabel.text = @"请选择区域";
        self.regionLabel.textColor = [UIColor themeGray3];
    }
}

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
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.regionLabel];
    [self.bgView addSubview:self.foldArrow];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
    }];
    [self.regionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(self.bgView);
    }];
    [self.foldArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self.bgView);
    }];
    self.bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showRegionSheet)];
    [self.bgView addGestureRecognizer:tap];
}

- (void)showRegionSheet
{
    CGRect frame = [UIScreen mainScreen].bounds;
    CGFloat bottomHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }
    frame.size.height = REGION_CONTENT_HEIGHT + bottomHeight;
    FHHouseFindHelpRegionSheet *sheet = [[FHHouseFindHelpRegionSheet alloc]initWithFrame:frame];
    NSArray *itemList = @[@"heheheh",@"heheheh",@"heheheh",@"heheheh",@"heheheh",@"hehedddddddddheh",@"heheheh",@"heheheh"];
    [sheet showWithItemList:itemList];
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor themeGray7];
        _bgView.layer.cornerRadius = 4;
    }
    return _bgView;
}

- (UIImageView *)foldArrow
{
    if (!_foldArrow) {
        _foldArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"housefind_entrance_arrow"]];
    }
    return _foldArrow;
}

- (UILabel *)regionLabel
{
    if (!_regionLabel) {
        _regionLabel = [[UILabel alloc]init];
        _regionLabel.text = @"请选择区域";
        _regionLabel.textColor = [UIColor themeGray3];
        _regionLabel.font = [UIFont themeFontRegular:14];
    }
    return _regionLabel;
}

@end
