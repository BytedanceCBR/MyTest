//
//  FHSuggestionSubscribCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/20.
//

#import "FHSuggestionSubscribCell.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import <Masonry.h>
#import "FHSugSubscribeModel.h"

@interface FHSuggestionSubscribCell()

@end

@implementation FHSuggestionSubscribCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    
    _backImageView = [UIImageView new];
    [self.contentView addSubview:_backImageView];
    [_backImageView setBackgroundColor:[UIColor redColor]];
    [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.bottom.mas_equalTo(self.contentView);
    }];
    
    // label
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontMedium:14];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(36);
        make.top.mas_equalTo(19);
        make.height.mas_equalTo(20);
    }];
    // secondaryLabel
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.font = [UIFont themeFontRegular:11];
    _subTitleLabel.textColor = [UIColor themeGray3];
    _subTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_subTitleLabel];
    
    
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(0);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.height.mas_equalTo(16);
    }];
    
    _bottomContentLabel = [[UILabel alloc] init];
    _bottomContentLabel.font = [UIFont themeFontRegular:12];
    _bottomContentLabel.textColor = [UIColor themeGray2];
    _bottomContentLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_bottomContentLabel];
    [_bottomContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(6);
        make.top.equalTo(self.subTitleLabel.mas_bottom);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_greaterThanOrEqualTo(63);
    }];
    
    _subscribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_subscribeBtn setTitle:@"订阅" forState:UIControlStateNormal];
    _subscribeBtn.layer.masksToBounds = YES;
    _subscribeBtn.layer.borderColor = [UIColor themeRed1].CGColor;
    _subscribeBtn.layer.borderWidth = 0.5;
    
    [self.contentView addSubview:_subscribeBtn];
    [_subscribeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(6);
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_greaterThanOrEqualTo(63);
    }];
    
}

- (void)refreshUI:(JSONModel *)data
{
    if ([data isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
        FHSugSubscribeDataDataSubscribeInfoModel *model = (FHSugSubscribeDataDataSubscribeInfoModel *)data;
        _titleLabel.text = @"订阅当前搜索条件";
        _subTitleLabel.text = @"新上房源立刻通知";
        _bottomContentLabel.text = [NSString stringWithFormat:@"当前选择：%@",model.text];
    }
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
