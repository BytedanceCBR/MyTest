//
//  FHDetailSecondhandPeripheryCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2019/12/4.
//

#import "FHDetailSecondhandPeripheryCell.h"
@interface FHDetailSecondhandPeripheryCell()
@property (weak, nonatomic) UIImageView *mainIma;
@property (weak, nonatomic) UILabel *titleLab;
@property (weak, nonatomic) UILabel *descLab;
@property (weak, nonatomic) UILabel *numberHouseLab;
@property (weak, nonatomic) UILabel *averagePriceLab;
@property (weak, nonatomic) UILabel *priceLab;

@end
@implementation FHDetailSecondhandPeripheryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UIImageView *)mainIma {
    if (!_mainIma) {
        UIImageView *mainIma = [[UIImageView alloc]init];
        [self.contentView addSubview:mainIma];
        _mainIma = mainIma;
    }
    return _mainIma;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *titleLab = [[UILabel alloc]init];
        titleLab.textColor = [UIColor themeGray1];
        titleLab.text = @"123123123";
        titleLab.font = [UIFont themeFontMedium:18];
        [self.contentView addSubview:titleLab];
        _titleLab = titleLab;
    }
    return _titleLab;
}

- (UILabel *)descLab {
    if (!_descLab) {
        UILabel *descLab = [[UILabel alloc]init];
        descLab.textColor = [UIColor themeGray1];
        descLab.text = @"123123123";
        descLab.font = [UIFont themeFontRegular:12];
         [self.contentView addSubview:descLab];
        _descLab = descLab;
    }
    return _descLab;
}

- (UILabel *)numberHouseLab {
    if (!_numberHouseLab) {
        UILabel *numberHouseLab = [[UILabel alloc]init];
        numberHouseLab.textColor = [UIColor colorWithHexStr:@"#fe5500"];
        numberHouseLab.text = @"123123123";
        numberHouseLab.font = [UIFont themeFontRegular:12];
        [self.contentView addSubview:numberHouseLab];
        _numberHouseLab = numberHouseLab;
    }
    return _numberHouseLab;
}

- (UILabel *)averagePriceLab {
    if (!_averagePriceLab) {
        UILabel *averagePriceLab = [[UILabel alloc]init];
        averagePriceLab.textColor = [UIColor themeGray1];
        averagePriceLab.text = @"123123123";
        averagePriceLab.font = [UIFont themeFontRegular:12];
        [self.contentView addSubview:averagePriceLab];
        _averagePriceLab= averagePriceLab;
    }
    return _averagePriceLab;
}

- (UILabel *)priceLab {
    if (!_priceLab) {
        UILabel *priceLab = [[UILabel alloc]init];
        priceLab.textColor = [UIColor colorWithHexStr:@"#fe5500"];
        priceLab.text = @"123123123";
        priceLab.font = [UIFont themeFontMedium:16];
        [self.contentView addSubview:priceLab];
        _priceLab = priceLab;
    }
    return _priceLab;
}

- (void)setupUI {
    
}
@end
