//
//  FHBrowsingHistoryContentCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/15.
//

#import "FHBrowsingHistoryContentCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "FHBrowseHistoryHouseDataModel.h"

@interface FHBrowsingHistoryContentCell()

@property (nonatomic, strong) UILabel *timeContentLabel;

@end

@implementation FHBrowsingHistoryContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.timeContentLabel = [[UILabel alloc] init];
    self.timeContentLabel.textColor = [UIColor themeGray1];
    self.timeContentLabel.font = [UIFont themeFontMedium:14];
    self.timeContentLabel.textAlignment = NSTextAlignmentLeft;
    [self.timeContentLabel sizeToFit];
    [self.contentView addSubview:_timeContentLabel];
    
    [self.timeContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
}

- (void)refreshWithData:(id)data {
    FHBrowseHistoryContentModel *model = (FHBrowseHistoryContentModel *)data;
    self.timeContentLabel.text = model.text;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
