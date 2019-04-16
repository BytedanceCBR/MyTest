//
//  FHDetailSchoolInfoItemView.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/16.
//

#import "FHDetailSchoolInfoItemView.h"
#import "FHDetailBaseModel.h"
#import <FHCommonDefines.h>
#import <TTBaseLib/UIButton+TTAdditions.h>
#import <FHCommonUI/UILabel+House.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry.h>
#import <FHCommonUI/UIView+House.h>

@interface FHDetailSchoolInfoItemView ()

@property(nonatomic, strong)FHDetailSchoolInfoItemModel *itemModel;
@property (nonatomic, weak)   UIButton       *foldBtn;
@property (nonatomic, strong)   UIView       *schoolView;
@property (nonatomic, strong)   UILabel       *schoolKey;
@property (nonatomic, strong)   UILabel       *schoolLabel;
@property (nonatomic, assign)   CGFloat       schoolHeight;

@end


@implementation FHDetailSchoolInfoItemView

- (instancetype)initWithSchoolInfoModel:(FHDetailSchoolInfoItemModel *)itemModel
{
    self = [super init];
    if (self) {
        _itemModel = itemModel;
        [self setupUI];
    }
    return self;
}

- (CGFloat)showSchoolItem:(FHDetailDataNeighborhoodInfoSchoolInfoModel *)item parentView:(UIView *)parentView bottomY:(CGFloat)bottomY
{
    UILabel *nameKey = [UILabel createLabel:@"学校资源" textColor:@"" fontSize:15];
    [nameKey sizeToFit];
    nameKey.left = 20;
    nameKey.top = bottomY + 4;
    nameKey.height = 20;
    
    UILabel *nameValue = [UILabel createLabel:item.schoolName textColor:@"" fontSize:14];
    nameValue.textAlignment = NSTextAlignmentLeft;
    nameValue.numberOfLines = 0;
    nameValue.textColor = [UIColor themeGray1];
    [parentView addSubview:nameValue];
    
    nameValue.width = SCREEN_WIDTH - 20 - 20 - nameKey.right - 12;
    [nameValue sizeToFit];
    nameValue.left = 0;
    nameValue.top = nameKey.top;
    
    bottomY = nameValue.bottom;
    return bottomY;
}

- (void)setupUI
{
    if (_itemModel.schoolItem.schoolList.count < 1) {
        return;
    }
    FHDetailDataNeighborhoodInfoSchoolInfoModel *schoolInfo = _itemModel.schoolItem.schoolList[0];
    NSString *schoolTypeName = _itemModel.schoolItem.schoolTypeName;
    NSString *schoolName = schoolInfo.schoolName;

    self.backgroundColor = [UIColor whiteColor];
    UILabel *schoolKey = [UILabel createLabel:schoolTypeName textColor:@"" fontSize:15];
    schoolKey.textColor = [UIColor themeGray3];
    UILabel *schoolLabel = [UILabel createLabel:schoolName textColor:@"" fontSize:14];
    schoolLabel.numberOfLines = 0;
    schoolLabel.textColor = [UIColor themeGray1];
    [schoolKey setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    self.schoolKey = schoolKey;
    self.schoolLabel = schoolLabel;
    [self addSubview:schoolKey];
    [self addSubview:schoolLabel];

    UIButton *foldBtn = [[UIButton alloc]init];
    [foldBtn setImage:[UIImage imageNamed:@"detail_fold_down"] forState:UIControlStateNormal];
    [foldBtn setImage:[UIImage imageNamed:@"detail_fold_down"] forState:UIControlStateHighlighted];
    [foldBtn setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -20, -20, -10)];
    [foldBtn addTarget:self action:@selector(foldBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.foldBtn = foldBtn;
    [self addSubview:foldBtn];

    [schoolKey sizeToFit];
    schoolKey.left = 20;
    schoolKey.top = 10;
    schoolKey.height = 20;
    
    foldBtn.frame = CGRectMake(SCREEN_WIDTH - 20 - 16, schoolKey.top, 16, 16);
    foldBtn.centerY = schoolKey.centerY;
    if (_itemModel.schoolItem.schoolList.count > 1) {
        schoolLabel.width = foldBtn.left - 4 - schoolKey.right - 12;
    }else {
        schoolLabel.width = SCREEN_WIDTH - 20 - schoolKey.right - 12;
    }
    [schoolLabel sizeToFit];
    schoolLabel.left = schoolKey.right + 12;
    schoolLabel.top = schoolKey.top;
    schoolLabel.height = ceil(schoolLabel.height);

    UIView *schoolView = [[UIView alloc]init];
    schoolView.backgroundColor = [UIColor whiteColor];
    schoolView.clipsToBounds = YES;
    self.schoolView = schoolView;
    [self addSubview:schoolView];
    
    [schoolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(schoolLabel);
        make.right.mas_equalTo(foldBtn.mas_left).mas_offset(-4);
        make.top.mas_equalTo(schoolLabel.mas_bottom);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    if (_itemModel.schoolItem.schoolList.count > 1) {

        self.foldBtn.hidden = NO;
        CGFloat schoolHeight = 0;
        for (NSInteger index = 1; index < _itemModel.schoolItem.schoolList.count; index++) {
            FHDetailDataNeighborhoodInfoSchoolInfoModel *schoolInfo = _itemModel.schoolItem.schoolList[index];
            schoolHeight = [self showSchoolItem:schoolInfo parentView:self.schoolView bottomY:schoolHeight];
        }
        self.schoolHeight = schoolHeight;
        [schoolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(foldBtn.mas_left).mas_offset(-4);
        }];
    }else {
        self.foldBtn.hidden = YES;
        [schoolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(foldBtn.mas_left).mas_offset(20);
        }];
    }
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    NSLog(@"zjing layoutSubviews schoolView:%@",self.schoolView);
//    NSLog(@"zjing layoutSubviews self:%@",self);
//}

- (void)foldBtnDidClick:(UIButton *)btn
{
    _itemModel.isFold = !_itemModel.isFold;
    if (_itemModel.isFold) {
        [self.foldBtn setImage:[UIImage imageNamed:@"detail_fold_down"] forState:UIControlStateNormal];
        [self.foldBtn setImage:[UIImage imageNamed:@"detail_fold_down"] forState:UIControlStateHighlighted];
    }else {
        [self.foldBtn setImage:[UIImage imageNamed:@"detail_fold_up"] forState:UIControlStateNormal];
        [self.foldBtn setImage:[UIImage imageNamed:@"detail_fold_up"] forState:UIControlStateHighlighted];
    }
    [self updateSchoolConstraints:YES];
}

- (void)updateSchoolConstraints:(BOOL)animated
{
    if (animated) {
        [_itemModel.tableView beginUpdates];
    }
    if (_itemModel.isFold) {
        
        [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
     }];
        self.schoolView.hidden = YES;
    } else {
        [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.schoolHeight);
        }];
        self.schoolView.hidden = NO;
    }
    [self setNeedsUpdateConstraints];
    
    if (animated) {
        [_itemModel.tableView endUpdates];
    }
}

@end


@implementation FHDetailSchoolInfoItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFold = YES;
    }
    return self;
}

@end
