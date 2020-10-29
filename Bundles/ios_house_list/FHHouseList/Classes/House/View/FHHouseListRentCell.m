//
//  FHHouseListRentCell.m
//  FHHouseList
//
//  Created by xubinbin on 2020/10/28.
//

#import "FHHouseListRentCell.h"

@interface FHHouseListRentCell()

@property (nonatomic, strong) UILabel *distanceLabel; // 30 分钟到达

@end

@implementation FHHouseListRentCell

@synthesize tagLabel = _tagLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [super initUI];
    [self.mainImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
    }];
    [self.houseMainImageBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainImageView).offset(3);
        make.left.mas_equalTo(self.mainImageView).offset(3);
        make.right.mas_equalTo(self.mainImageView).offset(-3);
        make.bottom.mas_equalTo(self.mainImageView).offset(-3);
    }];
}

- (YYLabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[YYLabel alloc] init];
        _tagLabel.font = [UIFont themeFontRegular:12];
        _tagLabel.textColor = [UIColor themeGray3];
    }
    return _tagLabel;
}

- (UILabel *)distanceLabel {
    if (!_distanceLabel) {
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _distanceLabel;
}

@end
