//
//  FHHouseDetailTitleCell.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/13.
//

#import "FHHouseDetailTitleCell.h"
#import "FHHouseRealtorDetailInfoModel.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
@interface FHHouseDetailTitleCell()
@property (weak, nonatomic)UILabel *titleLab;
@end
@implementation FHHouseDetailTitleCell

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHHouseRealtorTitleModel class]]) {
        return;
    }
    FHHouseRealtorTitleModel *model = (FHHouseRealtorTitleModel *)data;
    self.title = model.title;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithHexStr:@"#FFFEFE"];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(13);
        make.top.mas_equalTo(self.contentView).mas_offset(5);
        make.centerY.equalTo(self.contentView);
    }];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *titleLab = [[UILabel alloc]init];
        titleLab.font = [UIFont themeFontMedium:20];
        titleLab.textColor = [UIColor themeGray1];
        [self.contentView addSubview:titleLab];
        _titleLab = titleLab;
    }
    return _titleLab;
}

- (void)setTitle:(NSString *)title {
    _titleLab.text = title;
}

@end
