//
//  FHDetailCourtInfoCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/8.
//

#import "FHDetailCourtInfoCell.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIFont+House.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "FHDetailFoldViewButton.h"
#import "UILabel+House.h"
#import "FHDetailBottomOpenAllView.h"
#import "FHDetailStarsCountView.h"
#import <FHCommonUI/UILabel+House.h>
#import "UIColor+Theme.h"
#import <FHCommonUI/UIView+House.h>
#import "FHCommonDefines.h"
#import <TTBaseLib/UIButton+TTAdditions.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHHouseDetailContactViewModel.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHHouseContactDefines.h>
#import "FHUtils.h"
#import "FHUIAdaptation.h"
#import "FHDetailCommonDefine.h"

@interface FHDetailNewConsultView : UIView
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIImageView *consultImgView;
@property (nonatomic, strong) UIButton *consultBtn;
@property (nonatomic, strong) UIButton *actionBtn;
@property (nonatomic, copy) void (^actionBlock)(void);

@end

@implementation FHDetailNewConsultView

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
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.font = [UIFont themeFontRegular:AdaptFont(16)];
    _nameLabel.textColor = [UIColor themeGray3];
    [self addSubview:_nameLabel];
    
    _infoLabel = [[UILabel alloc]init];
    _infoLabel.font = [UIFont themeFontMedium:AdaptFont(16)];
    _infoLabel.textColor = [UIColor colorWithHexStr:@"#ff9629"];
    [self addSubview:_infoLabel];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    
    _consultBtn = [[UIButton alloc]init];
    [self addSubview:_consultBtn];

    _actionBtn = [[UIButton alloc]init];
    [self addSubview:_actionBtn];
    [_actionBtn addTarget:self action:@selector(consultBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];

    _consultImgView = [[UIImageView alloc] init];
    _consultImgView.image = [UIImage imageNamed:@"plot__message"];
    _consultImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_consultImgView];

    // 布局
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(AdaptOffset(5));
        make.right.mas_lessThanOrEqualTo(AdaptOffset(-30));
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.consultImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoLabel.mas_right).offset(AdaptOffset(3));
        make.centerY.mas_equalTo(self).offset(-1);
        make.height.mas_equalTo(AdaptOffset(15));
        make.width.mas_equalTo(AdaptOffset(16));
    }];
    [self.consultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.consultImgView);
    }];
    [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.infoLabel);
        make.right.mas_equalTo(self.consultImgView.mas_right);
    }];
}

- (void)consultBtnDidClick:(UIButton *)btn
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

@end

@interface FHDetailCourtInfoCell ()

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) FHDetailNewConsultView *consultView;
@property (nonatomic, strong)   NSMutableDictionary       *houseShowCache; // 埋点缓存

@end

@implementation FHDetailCourtInfoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailCourtInfoCellModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *subview in self.topView.subviews) {
        [subview removeFromSuperview];
    }
    self.consultView.hidden = YES;
    FHDetailCourtInfoCellModel *model = (FHDetailCourtInfoCellModel *)data;

    adjustImageScopeType(model)
    
    if (model.surroundingInfo.location.length > 0) {
        [self showLabelWithKey:@"位置:" value:[NSString stringWithFormat:@"%@",model.surroundingInfo.location] parentView:self.topView];
    }
    CGFloat height = 0;
    CGFloat topOffset = AdaptOffset(15);
    if (model.surroundingInfo.surrounding) {
        self.consultView.hidden = NO;
        self.consultView.nameLabel.text = @"配套:";
        self.consultView.infoLabel.text = model.surroundingInfo.surrounding.text;
        height = 20;
    }else {
        self.consultView.hidden = YES;
        topOffset = 0;
    }
    [self.consultView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
        make.top.equalTo(self.topView.mas_bottom).mas_offset(topOffset);
    }];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc]init];
        containerView.clipsToBounds = YES;
        containerView.layer.cornerRadius = 10;
        [self.contentView addSubview:containerView];
        _containerView = containerView;
    }
    return _containerView;
}

- (UIView *)topView {
    if (!_topView) {
        UIView *topView = [[UIView alloc]init];
        topView = [[UIView alloc] init];
        [self.containerView addSubview:topView];
        _topView = topView;
    }
    return _topView;
}

- (FHDetailNewConsultView *)consultView {
    if (!_consultView) {
        FHDetailNewConsultView *consultView = [[FHDetailNewConsultView alloc]init];
        __weak typeof(self)wself = self;
        consultView.backgroundColor = [UIColor clearColor];
        consultView.actionBlock = ^{
            [wself imAction];
        };
        [self.containerView addSubview:consultView];
        _consultView = consultView;
    }
    return _consultView;
}
// 小区信息
- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"";
}


#pragma mark - FHDetailScrollViewDidScrollProtocol

- (void)imAction
{
    FHDetailCourtInfoCellModel *model = (FHDetailCourtInfoCellModel *)self.currentData;
    if (model.surroundingInfo.surrounding.chatOpenurl.length > 0) {

        NSMutableDictionary *imExtra = @{}.mutableCopy;
        imExtra[@"source_from"] = @"education_type";
        imExtra[@"im_open_url"] = model.surroundingInfo.surrounding.chatOpenurl;
        imExtra[kFHClueEndpoint] = [NSString stringWithFormat:@"%ld",FHClueEndPointTypeC];
        imExtra[kFHCluePage] = [NSString stringWithFormat:@"%ld",FHClueIMPageTypeCNewHouseLocation];
        imExtra[@"from"] = @"app_newhouse_askneighbourhood";
        
        if([self.baseViewModel.detailData isKindOfClass:FHDetailNewModel.class]) {
            FHDetailNewModel *detailNewModel = (FHDetailNewModel *)self.baseViewModel.detailData;
            if(detailNewModel.data.surroundingInfo.associateInfo) {
                imExtra[kFHAssociateInfo] = detailNewModel.data.surroundingInfo.associateInfo;
            }
        }
        
        [model.contactViewModel onlineActionWithExtraDict:imExtra];
        if ([self.baseViewModel respondsToSelector:@selector(addClickOptionLog:)]) {
            [self.baseViewModel addClickOptionLog:@"education_type"];
        }
    }
}

- (void)showLabelWithKey:(NSString *)key value:(NSString *)value parentView:(UIView *)parentView
{
    UILabel *nameKey = [UILabel createLabel:key textColor:@"" fontSize:AdaptFont(16)];
    nameKey.textColor = [UIColor themeGray3];
    UILabel *nameValue = [UILabel createLabel:value textColor:@"" fontSize:AdaptFont(16)];
    nameValue.numberOfLines = 1;
    nameValue.textColor = [UIColor themeGray1];
    nameValue.lineBreakMode = NSLineBreakByTruncatingTail;
    [parentView addSubview:nameKey];
    [parentView addSubview:nameValue];
    [nameKey sizeToFit];
    CGFloat width = nameKey.width;
    [nameKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(parentView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(width);
        make.top.bottom.equalTo(parentView);
    }];
    [nameValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameKey.mas_right).mas_offset(AdaptOffset(5));
        make.top.equalTo(nameKey);
        make.right.equalTo(parentView);
    }];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _houseShowCache = [NSMutableDictionary new];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"位置及周边配套";

    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.contentView addSubview:_headerView];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(30);
        make.right.mas_equalTo(self.shadowImage).offset(-15);
        make.left.mas_equalTo(self.shadowImage).offset(15);
        make.height.mas_equalTo(46);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.shadowImage).offset(15);
        make.right.mas_equalTo(self.shadowImage).offset(-15);
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(15);
        make.bottom.equalTo(self.contentView).offset(-12);
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).mas_offset(AdaptOffset(15));
        make.right.mas_equalTo(self.containerView).mas_offset(AdaptOffset(-15));
        make.top.mas_equalTo(self.containerView).mas_offset(10);
    }];
    [self.consultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).mas_offset(AdaptOffset(15));
        make.right.mas_equalTo(self.containerView).mas_offset(AdaptOffset(-15));
        make.top.equalTo(self.topView.mas_bottom).mas_offset(AdaptOffset(15));
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.containerView);
    }];
}

@end

@implementation FHDetailCourtInfoCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end
