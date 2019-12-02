//
//  FHHouseListRecommendTipCell.m
//  FHHouseList
//
//  Created by 张静 on 2019/11/12.
//

#import "FHHouseListRecommendTipCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHSearchHouseModel.h>

@interface FHHouseListRecommendTipCell ()

@property (nonatomic, strong) UILabel *noDataTipLabel;
@property (nonatomic, strong) UIImageView *noDataTipImage;

@end

@implementation FHHouseListRecommendTipCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.noDataTipLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.noDataTipLabel];
        self.noDataTipLabel.font = [UIFont themeFontMedium:12];
        self.noDataTipLabel.textColor = [UIColor themeGray4];
        self.noDataTipImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"house_base_recommend_not_found"]];
        [self.contentView addSubview:self.noDataTipImage];
        [self setupUI];
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

- (void)hideSeprateLine:(BOOL)isFirstCell
{
    [self.noDataTipImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10.5);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(16);
    }];
    
    [self.noDataTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.noDataTipImage.mas_right).offset(5);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(18);
    }];
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
    return 38;
}

- (void)setupUI {
    [self.noDataTipImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(16);
    }];
    [self.noDataTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.noDataTipImage.mas_right).offset(5);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(18);
    }];
}
@end
