//
//  FHNeighborhoodDetailStrategyArticleCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailStrategyArticleCell.h"
#import "UIImageView+BDWebImage.h"
#import <TTBaseMacro.h>
#import "UIDevice+BTDAdditions.h"

@interface FHNeighborhoodDetailStrategyArticleCell ()

@property(nonatomic , strong) UILabel *contentLabel;
@property(nonatomic , strong) UIImageView *singleImageView;
@property(nonatomic , strong) UIImageView *iconImageView;
@property(nonatomic , strong) UILabel *iconLabel;
@property(nonatomic , strong) UILabel *descLabel;
@property(nonatomic , strong) UIView *bottomLine;

@end

@implementation FHNeighborhoodDetailStrategyArticleCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 102);
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodDataStrategyArticleListModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNeighborhoodDataStrategyArticleListModel *model = (FHDetailNeighborhoodDataStrategyArticleListModel *)data;
    if (model) {
        self.contentLabel.text = model.title;
        self.iconLabel.text = model.articleType;
        self.descLabel.text = model.desc;
        self.bottomLine.hidden = model.hiddenBottomLine;
        if(isEmptyString(model.picture)){
            _singleImageView.hidden = YES;
            [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.contentView).offset(-16);
            }];
        }else{
            _singleImageView.hidden = NO;
            [self.singleImageView bd_setImageWithURL:[NSURL URLWithString:model.picture] placeholder:nil];
            [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.contentView).offset(-102);
            }];
        }
        
        self.iconImageView.image = [UIImage imageNamed:@"neighborhood_detail_xingfu_icon"];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUIs];
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    _contentLabel.numberOfLines = 2;
    [self.contentView addSubview:_contentLabel];
    
    //单图
    self.singleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _singleImageView.hidden = YES;
    _singleImageView.clipsToBounds = YES;
    _singleImageView.contentMode = UIViewContentModeScaleAspectFill;
    _singleImageView.backgroundColor = [UIColor themeGray6];
    _singleImageView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _singleImageView.layer.borderWidth = 0.5;
    _singleImageView.layer.masksToBounds = YES;
    _singleImageView.layer.cornerRadius = 10;
    [self.contentView addSubview:_singleImageView];
    
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _iconImageView.clipsToBounds = YES;
    _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    _iconImageView.backgroundColor = [UIColor themeGray6];
    _iconImageView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _iconImageView.layer.borderWidth = 0.5;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.layer.cornerRadius = 8;
    [self.contentView addSubview:_iconImageView];
    
    self.iconLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_iconLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [_descLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_descLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_descLabel];
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_bottomLine];
}

- (void)initConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.right.mas_equalTo(self.contentView).offset(-102);
    }];
    
    [self.singleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-16);
        make.width.height.mas_equalTo(70);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.singleImageView.mas_bottom);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.width.height.mas_equalTo(16);
    }];
    
    [self.iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(4);
        make.right.mas_equalTo(self.descLabel.mas_left).offset(-10);
        make.height.mas_equalTo(14);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.right.mas_equalTo(self.contentLabel.mas_right);
        make.height.mas_equalTo(14);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.right.mas_equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo([UIDevice btd_onePixel]);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
