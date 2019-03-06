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

@interface FHDetailSuggestTipCell ()

//@property (nonatomic, strong)   UIView       *tipBgView;
@property (nonatomic, strong)   UILabel       *tipLabel;
@property (nonatomic, strong)   UILabel       *subtitleLabel;
@property (nonatomic, strong)   UIImageView       *trendIcon;
@property (nonatomic, strong)   UIView       *bgView;

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
        if ([model.buySuggestion.type isEqualToString:@"1"]) {
            self.trendIcon.image = [UIImage imageNamed:@"sentiment-satisfied-material"];
        } else if ([model.buySuggestion.type isEqualToString:@"2"]) {
            self.trendIcon.image = [UIImage imageNamed:@"sentiment-neutral-material"];
        } if ([model.buySuggestion.type isEqualToString:@"3"]) {
            self.trendIcon.image = [UIImage imageNamed:@"sentiment-dissatisfied-material"];
        }
    }
    [self layoutIfNeeded];
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

- (void)setupUI {
    
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bgView];
    
    _trendIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sentiment-satisfied-material"]];
    _trendIcon.contentMode = UIViewContentModeScaleAspectFill;
    [self.bgView addSubview:_trendIcon];
    
//    _tipBgView = [[UIView alloc] init];
//    _tipBgView.backgroundColor = [UIColor themeGray7];
//    _tipBgView.layer.cornerRadius = 4.0;
//    _tipBgView.layer.masksToBounds = YES;
//    [self.bgView addSubview:_tipBgView];
    
    _tipLabel = [UILabel createLabel:@"购房小建议" textColor:@"" fontSize:16];
    _tipLabel.textColor = [UIColor themeGray1];
    _tipLabel.font = [UIFont themeFontMedium:16];
    [self.bgView addSubview:_tipLabel];
    
    _subtitleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _subtitleLabel.textColor = [UIColor themeGray3];
    _subtitleLabel.numberOfLines = 0;
    [self.bgView addSubview:_subtitleLabel];
    
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
//    [self.tipBgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(10);
//        make.left.mas_equalTo(-4);
//        make.right.mas_equalTo(self.tipLabel.mas_right).offset(12);
//        make.bottom.mas_equalTo(self.tipLabel.mas_bottom).offset(3);
//    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(15);
        make.left.mas_equalTo(self.bgView).offset(15);
        make.height.mas_equalTo(22);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(11);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-15);
    }];
}

@end


// FHDetailSuggestTipModel
@implementation FHDetailSuggestTipModel

@end
