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
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHDetailSchoolInfoItemView ()

@property(nonatomic, strong)FHDetailSchoolInfoItemModel *itemModel;
@property (nonatomic, weak)   UIButton       *foldBtn;
@property (nonatomic, strong)   UIView       *schoolView;
@property (nonatomic, strong)   UILabel       *schoolKey;
@property (nonatomic, strong)   UILabel       *schoolLabel;

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
    UILabel *nameKey = [UILabel createLabel:@"学校资源:" textColor:@"" fontSize:15];
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
    self.clipsToBounds = YES;

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
    UIImage *img = ICON_FONT_IMG(16, @"\U0000e672", nil);//@"detail_fold_down"
    [foldBtn setImage:img forState:UIControlStateNormal];
    [foldBtn setImage:img forState:UIControlStateHighlighted];
    [foldBtn setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -20, -20, -10)];
    [foldBtn addTarget:self action:@selector(foldBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.foldBtn = foldBtn;
    [self addSubview:foldBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(foldBtnDidClick)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
    
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
    self.bottomY = self.schoolLabel.bottom;
    
    UIView *schoolView = [[UIView alloc]init];
    schoolView.backgroundColor = [UIColor whiteColor];
    self.schoolView = schoolView;
    [self addSubview:schoolView];
    
    [schoolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(schoolLabel);
        make.right.mas_equalTo(foldBtn.mas_left).mas_offset(-4);
        make.top.mas_equalTo(schoolLabel.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    if (_itemModel.schoolItem.schoolList.count > 1) {

        self.foldBtn.hidden = NO;
        CGFloat schoolHeight = 0;
        for (NSInteger index = 1; index < _itemModel.schoolItem.schoolList.count; index++) {
            FHDetailDataNeighborhoodInfoSchoolInfoModel *schoolInfo = _itemModel.schoolItem.schoolList[index];
            schoolHeight = [self showSchoolItem:schoolInfo parentView:self.schoolView bottomY:schoolHeight];
        }
        self.schoolHeight = schoolHeight;
        [schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(foldBtn.mas_left).mas_offset(-4);
            make.height.mas_equalTo(self.schoolHeight);
        }];
    }else {
        self.foldBtn.hidden = YES;
        [schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(foldBtn.mas_left).mas_offset(20);
        }];
    }
}

- (void)foldBtnDidClick
{
    _itemModel.isFold = !_itemModel.isFold;
    UIImage *img = nil;
    if (_itemModel.isFold) {
        img = ICON_FONT_IMG(16, @"\U0000e672", nil); //@"detail_fold_down"
    }else {
        img = ICON_FONT_IMG(16, @"\U0000e65f", nil); //@"detail_fold_up"
    }
    
    [self.foldBtn setImage:img forState:UIControlStateNormal];
    [self.foldBtn setImage:img forState:UIControlStateHighlighted];

    if (self.foldBlock) {
    
        CGFloat height = [self viewHeight];
        self.foldBlock(self, height);
    }

}

- (CGFloat)viewHeight
{
    CGFloat height = _itemModel.isFold ? self.schoolLabel.bottom : self.schoolHeight + self.schoolLabel.bottom;
    return height;
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
