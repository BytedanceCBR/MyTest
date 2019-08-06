//
// Created by zhulijun on 2019-06-03.
// 小区话题列表页Cell
//

#import "FHTopicCell.h"
#import "FHTopicListModel.h"
#import "BDWebImage.h"


@interface FHTopicCell ()

@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UIImageView *singleImageView;

@end

@implementation FHTopicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUI];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUI {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_contentLabel];

    self.singleImageView = [[UIImageView alloc] init];
    _singleImageView.clipsToBounds = YES;
    _singleImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_singleImageView];
}

- (void)initConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(50);
    }];

    [self.singleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(100);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:FHTopicListResponseItemModel.class]) {
        return;
    }
    FHTopicListResponseItemModel* itemData = (FHTopicListResponseModel *)data;
    self.contentLabel.text = itemData.title;
    [self.singleImageView bd_setImageWithURL:[NSURL URLWithString:itemData.des] placeholder:nil];

}

@end
