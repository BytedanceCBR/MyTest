//
//  FHDetailPriceChangeHistoryCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailPriceChangeHistoryCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"

@interface FHDetailPriceChangeHistoryCell ()

@property (nonatomic, strong)   UIImageView       *leftIconImageView;
@property (nonatomic, strong)   UIImageView       *rightArrowImageView;
@property (nonatomic, strong)   UILabel       *infoLabel;
@property (nonatomic, strong)   UIView       *sepLine;

@end

@implementation FHDetailPriceChangeHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPriceChangeHistoryModel class]]) {
        return;
    }
    self.currentData = data;
    //
    
    FHDetailPriceChangeHistoryModel *model = (FHDetailPriceChangeHistoryModel *)data;
    self.infoLabel.text = model.priceChangeHistory.priceChangeDesc;
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

- (UILabel *)createLabel:(NSString *)text textColor:(NSString *)hexColor fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor colorWithHexString:hexColor];
    label.font = [UIFont themeFontRegular:fontSize];
    return label;
}

- (void)setupUI {
    _leftIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ershou_price_tips_22"]];
    [self.contentView addSubview:_leftIconImageView];
    _rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-detail"]];
    [self.contentView addSubview:_rightArrowImageView];
    _infoLabel = [self createLabel:@"" textColor:@"#3d6e99" fontSize:12];
    [self.contentView addSubview:_infoLabel];
    
    [self.leftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.centerY.mas_equalTo(self.infoLabel);
        make.width.height.mas_equalTo(14);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIconImageView.mas_right).offset(6);
        make.right.mas_equalTo(self.contentView).offset(-32);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.infoLabel);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.height.mas_equalTo(12);
    }];
    [self.sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

@end

// FHDetailPriceChangeHistoryModel
@implementation FHDetailPriceChangeHistoryModel


@end
