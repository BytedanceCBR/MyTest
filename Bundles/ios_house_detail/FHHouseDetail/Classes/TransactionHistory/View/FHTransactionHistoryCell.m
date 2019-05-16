//
//  FHTransactionHistoryCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/20.
//

#import "FHTransactionHistoryCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "TTDeviceHelper.h"

@interface FHTransactionHistoryCell()

@property(nonatomic, strong) UILabel *namelabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UILabel *totalPriceLabel;
@property(nonatomic, strong) UILabel *pricePreSqmLabel;

@end

@implementation FHTransactionHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.namelabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self addSubview:_namelabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self addSubview:_descLabel];
    
    self.totalPriceLabel = [self LabelWithFont:[UIFont themeFontSemibold:16] textColor:[UIColor themeRed1]];
    _totalPriceLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_totalPriceLabel];
    
    self.pricePreSqmLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    _pricePreSqmLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_pricePreSqmLabel];
}

- (void)initConstraints {
    [self.totalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-20);
        make.top.mas_equalTo(self).offset(10);
        make.width.mas_greaterThanOrEqualTo(45);
        make.height.mas_equalTo(22);
    }];
    
    [self.namelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self.totalPriceLabel.mas_left).offset(-5);
        make.top.mas_equalTo(self.totalPriceLabel);
        make.height.mas_equalTo(22);
    }];
    
    [self.pricePreSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-20);
        make.top.mas_equalTo(self.namelabel.mas_bottom).offset(5);
        make.height.mas_equalTo(17);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.pricePreSqmLabel.mas_left).offset(-5);
        make.left.mas_equalTo(self).offset(20);
        make.top.mas_equalTo(self.namelabel.mas_bottom).offset(5);
        make.height.mas_equalTo(17);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)updateWithModel:(FHDetailNeighborhoodDataTotalSalesListModel *)model {
    self.namelabel.text = [NSString stringWithFormat:@"%@/%@",model.floorplan,model.squaremeter];
    //冯康说 用agencyName , 使用datasource 有法律风险 2019.05.14
    self.descLabel.text = [NSString stringWithFormat:@"%@，%@",model.dealDate,model.agencyName];
    self.totalPriceLabel.text = model.pricing;
    self.pricePreSqmLabel.text = model.pricingPerSqm;
}

@end
