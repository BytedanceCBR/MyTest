//
//  FHRecommendSecondhandHouseTitleCell.m
//  AFgzipRequestSerializer
//
//  Created by 郑识途 on 2019/1/7.
//

#import "FHRecommendSecondhandHouseTitleCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHSearchHouseModel.h>

@interface FHRecommendSecondhandHouseTitleCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation FHRecommendSecondhandHouseTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont themeFontSemibold:18];
        self.titleLabel.textColor = [UIColor themeGray1];
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

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHSearchGuessYouWantContentModel class]]) {
        FHSearchGuessYouWantContentModel *model = (FHSearchGuessYouWantContentModel *)data;
        self.titleLabel.text = model.text;
    }
}

+ (CGFloat)heightForData:(id)data
{
    return 45;
}

- (void)setupUI {

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(24);
    }];
}


@end
