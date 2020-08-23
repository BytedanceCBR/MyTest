//
//  FHDetailListSectionTitleCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2019/12/2.
//

#import "FHDetailListSectionTitleCell.h"
@interface FHDetailListSectionTitleCell()
@property (weak, nonatomic)UILabel *titleLab;
@end

@implementation FHDetailListSectionTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailListSectionTitleModel class]]) {
        return;
    }
    FHDetailListSectionTitleModel *model = (FHDetailListSectionTitleModel *)data;
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
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.top.mas_equalTo(self.contentView).mas_offset(1);
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

@implementation FHDetailListSectionTitleModel


@end
