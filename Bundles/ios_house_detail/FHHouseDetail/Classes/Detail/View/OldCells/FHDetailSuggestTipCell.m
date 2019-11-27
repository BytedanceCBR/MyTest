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

@interface FHDetailSuggestTipCell ()

//@property (nonatomic, strong)   UIView       *tipBgView;
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
    self.trendIcon.hidden = YES;
    if (model.buySuggestion && model.buySuggestion.type.length > 0) {
        self.trendIcon.hidden = NO;
        self.subtitleLabel.text = model.buySuggestion.content;
    }
    if (model.buySuggestion.score.integerValue > 0) {
        [self.starView updateStarsCountWithoutLabel:model.buySuggestion.score.integerValue];
        self.starView.hidden = NO;
    }else {
        [self.starView updateStarsCountWithoutLabel:0];
        self.starView.hidden = YES;
    }
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
        shadowImage.image = [[UIImage imageNamed:@"left_bottom_right"]resizableImageWithCapInsets:UIEdgeInsetsMake(30,30,30,30) resizingMode:UIImageResizingModeStretch];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(-20);
        make.right.mas_equalTo(self.contentView).offset(20);
        make.top.equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(30);
    }];
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bgView];
    
    _trendIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sentiment-satisfied-material"]];
    _trendIcon.contentMode = UIViewContentModeScaleAspectFill;
    [self.bgView addSubview:_trendIcon];

    _tipLabel = [UILabel createLabel:@"购房小建议" textColor:@"" fontSize:16];
    _tipLabel.textColor = [UIColor themeGray1];
    _tipLabel.font = [UIFont themeFontMedium:16];
    [self.bgView addSubview:_tipLabel];
    
    _subtitleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _subtitleLabel.textColor = [UIColor themeGray2];
    _subtitleLabel.numberOfLines = 0;
    [self.bgView addSubview:_subtitleLabel];
    
    _starView = [[FHDetailStarsCountView alloc]init];
    [self.bgView addSubview:_starView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(20);
        make.right.bottom.mas_equalTo(-20);
    }];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.masksToBounds = YES;
    
    self.trendIcon.hidden = YES;
    [self.trendIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(self.bgView);
    }];

    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(22);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(11);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-15);
    }];
    [self.starView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.tipLabel);
        make.width.mas_equalTo(110);
        make.right.mas_equalTo(-20);
    }];
}

@end


// FHDetailSuggestTipModel
@implementation FHDetailSuggestTipModel

@end
