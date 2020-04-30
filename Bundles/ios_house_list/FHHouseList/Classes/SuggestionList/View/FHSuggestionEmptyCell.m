//
//  FHSuggestionEmptyCell.m
//  FHHouseList
//
//  Created by xubinbin on 2020/4/24.
//

#import "FHSuggestionEmptyCell.h"
#import "Masonry.h"
#import <FHCommonUI/UIFont+House.h>
#import "UIColor+Theme.h"

@interface FHSuggestionEmptyCell()

@property(nonatomic, strong) UIImageView *emptyImageView;
@property(nonatomic, strong) UILabel *emptyLabel;
@end

@implementation FHSuggestionEmptyCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.emptyImageView = [[UIImageView alloc] init];
        self.emptyImageView.image = [UIImage imageNamed:@"suggestion_empty"];
        [self.contentView addSubview: _emptyImageView];
        [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(70);
            make.height.mas_equalTo(115);
            make.width.mas_equalTo(115);
            make.centerX.mas_equalTo(0);
        }];
        
        self.emptyLabel = [[UILabel alloc] init];
        self.emptyLabel.text = @"没有找到合适房源，换个条件试试吧";
        self.emptyLabel.font = [UIFont themeFontRegular:14];
        self.emptyLabel.textColor = [UIColor themeGray3];
        [self.contentView addSubview:_emptyLabel];
        [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.emptyImageView.mas_bottom).offset(10);
            make.centerX.mas_equalTo(0);
        }];
        
    }
    return self;
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
