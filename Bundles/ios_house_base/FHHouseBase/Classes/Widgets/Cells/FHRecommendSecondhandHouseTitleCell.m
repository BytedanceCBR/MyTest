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
@property (nonatomic, strong) UIView *divider;

@end

@implementation FHRecommendSecondhandHouseTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.divider = [[UIView alloc] init];
        [self.contentView addSubview:self.divider];
        self.divider.backgroundColor = [UIColor themeGray6];
        self.titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont themeFontRegular:18];
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

- (void)hideSeprateLine:(BOOL)isFirstCell
{
    self.divider.hidden = YES;
    
    [self.divider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(0.5);
    }];
    
    if (isFirstCell) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(20);
            make.right.mas_equalTo(self.contentView).offset(-20);
            make.top.mas_equalTo(self.divider.mas_bottom).offset(12);
            make.height.mas_equalTo(24);
        }];
    }else
    {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(20);
            make.right.mas_equalTo(self.contentView).offset(-20);
            make.bottom.equalTo(self.contentView).offset(3);
            make.height.mas_equalTo(24);
        }];
    }
}

- (void)showSeaprateLine
{
    self.divider.hidden = NO;
}

- (void)bindData:(FHRecommendSecondhandHouseTitleModel *)model {
    if ([model.noDataTip isEqualToString:@""]) {
        [self adjustDividerConstraints:NO];
    } else {
        [self adjustDividerConstraints:YES];
    }
    self.titleLabel.text = model.title;
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHSearchGuessYouWantContentModel class]]) {
        FHSearchGuessYouWantTipsModel *model = (FHSearchGuessYouWantTipsModel *)data;
        self.titleLabel.text = model.text;
        self.divider.hidden = YES;
    }
}

+ (CGFloat)heightForData:(id)data
{
    return 45;
}

- (void)setupUI {

    [self.divider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(0.5);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
//        make.top.mas_equalTo(self.divider.mas_bottom).offset(20);
        make.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(24);
    }];
}

- (void)prepareForReuse
{
    [self setupUI];
}

- (void)adjustDividerConstraints : (BOOL) showNodataTip {
    [self.divider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        if (showNodataTip) {
            make.top.mas_equalTo(20);
        } else {
            make.top.mas_equalTo(self.contentView);
        }
        make.height.mas_equalTo(0.5);
    }];
}

@end
