//
//  FHHouseListRecommendTipCell.m
//  FHHouseList
//
//  Created by 张静 on 2019/11/12.
//

#import "FHHouseListRecommendTipCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHSearchHouseModel.h>
#import <TTBaseLib/TTDeviceHelper.h>

@interface FHHouseListRecommendTipCell ()

@property (nonatomic, strong) UILabel *noDataTipLabel;
@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIView *rightLine;

@end

@implementation FHHouseListRecommendTipCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.noDataTipLabel = [[UILabel alloc] init];
        self.noDataTipLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.noDataTipLabel];
        self.noDataTipLabel.font = [UIFont themeFontMedium:14];
        self.noDataTipLabel.textColor = [UIColor themeGray4];
        [self.contentView addSubview:self.leftLine];
        [self.contentView addSubview:self.rightLine];
        [self initConstraints];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHSearchGuessYouWantTipsModel class]]) {
        FHSearchGuessYouWantTipsModel *model = (FHSearchGuessYouWantTipsModel *)data;
        self.noDataTipLabel.text = model.text;
    }
}

+ (CGFloat)heightForData:(id)data
{
    return 40;
}

- (void)initConstraints {
    [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(1);
        make.width.mas_greaterThanOrEqualTo(30);
    }];
    [self.noDataTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.leftLine.mas_right).offset(15);
        make.height.mas_equalTo(20);
    }];
    [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.noDataTipLabel.mas_right).offset(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(self.leftLine);
    }];
}

- (UIView *)leftLine
{
    if (!_leftLine) {
        _leftLine = [[UIView alloc]init];
        _leftLine.backgroundColor = [UIColor themeGray6];
    }
    return _leftLine;
}

- (UIView *)rightLine
{
    if (!_rightLine) {
        _rightLine = [[UIView alloc]init];
        _rightLine.backgroundColor = [UIColor themeGray6];
    }
    return _rightLine;
}

@end
