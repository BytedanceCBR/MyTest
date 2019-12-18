//
//  FHDetailSuggestTipCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailSuggestTipCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailStarsCountView.h"
#import "FHUtils.h"
#import "FHHouseContactDefines.h"

@interface FHDetailSuggestTipCell ()

//@property (nonatomic, strong)   UIView       *tipBgView;
@property (nonatomic, weak) UIImageView *titleImageView;
@property (nonatomic, weak)UILabel *titleLab;
@property (nonatomic, weak)UILabel *infoLab;
@property (nonatomic, weak)UIButton *imBtn;


@property (nonatomic, strong)   UILabel       *tipLabel;
@property (nonatomic, strong)   UILabel       *subtitleLabel;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIImageView       *trendIcon;
@property (nonatomic, strong)   UIView       *bgView;
@property(nonatomic, strong) FHDetailStarsCountView *starView;

@end

@implementation FHDetailSuggestTipCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailSuggestTipModel class]]) {
        return;
    }
    self.currentData = data;
    //
    FHDetailSuggestTipModel *model = (FHDetailSuggestTipModel *)data;
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    if (model.buySuggestion && model.buySuggestion.type.length > 0) {
        self.infoLab.text = model.buySuggestion.content;
    }
    FHDetailContactModel *contactPhone = model.contactPhone;
    if (contactPhone.unregistered) {
        self.imBtn.hidden = YES;
        [self.infoLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.shadowImage).offset(-50);
        }];
        [self.imBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    }
    
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"trade_tips";
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIImageView *)titleImageView {
    if (!_titleImageView) {
        UIImageView *titleImageView = [[UIImageView alloc]init];
        titleImageView.image = [UIImage imageNamed:@"tip_title_image"];
        [self.contentView addSubview:titleImageView];
        _titleImageView = titleImageView;
    }
    return _titleImageView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *titleLab = [UILabel createLabel:@"购房专业提示" textColor:@"" fontSize:20];
        titleLab.textColor = [UIColor themeGray1];
        titleLab.font = [UIFont themeFontMedium:20];
        [self.contentView addSubview:titleLab];
        _titleLab = titleLab;
    }
    return _titleLab;
}

- (UILabel *)infoLab {
    if (!_infoLab) {
        UILabel *infoLab = [UILabel createLabel:@"当前房源整体条件优于同小区大部分房源，建议咨询经纪人了解议价空间" textColor:@"" fontSize:14];
        infoLab.textColor = [UIColor themeGray2];
        infoLab.font = [UIFont themeFontRegular:14];
        infoLab.numberOfLines = 0;
        [self.contentView addSubview:infoLab];
        _infoLab = infoLab;
    }
    return _infoLab;
}

- (UIButton *)imBtn {
    if (!_imBtn) {
        UIButton *imBtn = [[UIButton alloc]init];
        [imBtn setTitle: @"咨询经纪人该房源底价" forState:UIControlStateNormal];
        [imBtn setTitleColor: [UIColor colorWithHexStr:@"#ff9629"] forState:UIControlStateNormal];
        imBtn.titleLabel.font = [UIFont themeFontMedium:16];
        imBtn.backgroundColor = [UIColor colorWithHexStr:@"#fff8ef"];
        [imBtn addTarget:self action:@selector(im_click:) forControlEvents:UIControlEventTouchUpInside];
        imBtn.layer.cornerRadius = 20;
        [self.contentView addSubview:imBtn];
        _imBtn = imBtn;
    }
    return _imBtn;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(29);
        make.top.equalTo(self.shadowImage).offset(50);
        make.size.mas_offset(CGSizeMake(24, 24));
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleImageView.mas_right).offset(4);
        make.centerY.equalTo(self.titleImageView);
    }];
    
    [self.infoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleImageView);
        make.top.equalTo(self.titleLab.mas_bottom).offset(24);
        make.right.equalTo(self.contentView).offset(-31);
    }];
    
    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleImageView);
        make.right.equalTo(self.contentView).offset(-31);
        make.top.equalTo(self.infoLab.mas_bottom).offset(22);
        make.height.mas_offset(40);
        make.bottom.equalTo(self.shadowImage).offset(-50);
    }];
}

- (void)im_click:(UIButton *)btn {
    FHDetailSuggestTipModel *model = (FHDetailSuggestTipModel *)self.currentData;
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    if (model.extraInfo.bargain.openUrl.length>0) {
        imExtra[@"im_open_url"] = model.extraInfo.bargain.openUrl;
    }else {
        return;
    }
    imExtra[@"realtor_position"] = @"trade_tips";
    imExtra[@"element_from"] = @"app_oldhouse_price";
    imExtra[kFHClueEndpoint] = @(FHClueEndPointTypeC);
    imExtra[kFHCluePage] = @(FHClueIMPageTypePresentation);
     [model.contactViewModel onlineActionWithExtraDict:imExtra];
//    [model.phoneCallViewModel imchatActionWithPhone:model.contactPhone realtorRank:@"0" extraDic:imExtra];
}
@end


// FHDetailSuggestTipModel
@implementation FHDetailSuggestTipModel

@end
