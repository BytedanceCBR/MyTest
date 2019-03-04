//
//  FHHouseMsgCell.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHHouseMsgCell.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIImageView+BDWebImage.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "FHHouseType.h"

@interface FHHouseMsgCell()

@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, strong) UIView *infoPanel;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UILabel *priceLabel;
@property(nonatomic, strong) YYLabel *areaLabel;
@property(nonatomic, strong) UILabel *roomSpaceLabel;
@property(nonatomic, strong) UILabel *imageTopLeftLabel;
@property(nonatomic, strong) UIView *imageTopLeftLabelBgView;

@end

@implementation FHHouseMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.imgView = [[UIImageView alloc] init];
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.backgroundColor = [UIColor whiteColor];
    _imgView.layer.borderWidth = 0.5;
    _imgView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.layer.cornerRadius = 4;
    _imgView.layer.masksToBounds = YES;
    [self.contentView addSubview:_imgView];
    
    self.imageTopLeftLabelBgView = [[UIView alloc] init];
    _imageTopLeftLabelBgView.backgroundColor = [UIColor themeRed1];
    _imageTopLeftLabelBgView.hidden = YES;
//    _imageTopLeftLabelBgView.layer.cornerRadius = 4;
//    _imageTopLeftLabelBgView.layer.masksToBounds = YES;
    [self.contentView addSubview:_imageTopLeftLabelBgView];
    
    self.imageTopLeftLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor whiteColor]];
    _imageTopLeftLabel.text = @"新上";
    _imageTopLeftLabel.textAlignment = NSTextAlignmentCenter;
    [self.imageTopLeftLabelBgView addSubview:_imageTopLeftLabel];
    
    self.infoPanel = [[UIView alloc] init];
    [self.contentView addSubview:_infoPanel];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    [self.infoPanel addSubview:_titleLabel];
    
    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray2]];
    [self.infoPanel addSubview:_subTitleLabel];
    
    self.areaLabel = [[YYLabel alloc] init];
    _areaLabel.numberOfLines = 0;
    _areaLabel.font = [UIFont themeFontRegular:12];
    _areaLabel.textColor = [UIColor themeGray1];
    _areaLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.infoPanel addSubview:_areaLabel];
    
    self.priceLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor themeRed1]];
    [self.contentView addSubview:_priceLabel];
    
    self.roomSpaceLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray1]];
    [_roomSpaceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_roomSpaceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_roomSpaceLabel];
}

- (void)initConstraints {
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.top.mas_equalTo(self.contentView).offset(20);
        make.width.mas_equalTo(114);
        make.height.mas_equalTo(85);
    }];
    
    [self.imageTopLeftLabelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imgView.mas_left);
        make.top.mas_equalTo(self.imgView.mas_top);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(17);
    }];
    
    [self.imageTopLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.imageTopLeftLabelBgView);
        make.centerY.mas_equalTo(self.imageTopLeftLabelBgView);
    }];

    [self.infoPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imgView.mas_right).offset(15);
        make.top.mas_equalTo(self.imgView.mas_top);
        make.bottom.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-15);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.infoPanel);
        make.height.mas_equalTo(20);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.infoPanel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(17);
    }];
    
    [self.areaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.infoPanel);
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoPanel);
        make.top.mas_equalTo(self.areaLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(24);
        make.width.lessThanOrEqualTo(@(130));
    }];
    
    [self.roomSpaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceLabel.mas_right).offset(7);
        make.bottom.mas_equalTo(self.priceLabel.mas_bottom).offset(-2);
        make.height.mas_equalTo(19);
    }];
    
    [self layoutIfNeeded];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.imageTopLeftLabelBgView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.imageTopLeftLabelBgView.bounds;
    layer.path = path.CGPath;
    self.imageTopLeftLabelBgView.layer.mask = layer;
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)updateWithModel:(FHHouseMsgDataItemsItemsModel *)model {
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.desc;
    
    if([model.houseType integerValue] == FHHouseTypeNewHouse){
        self.priceLabel.text = model.pricePerSqm;
        self.roomSpaceLabel.text = nil;
    }else{
        self.priceLabel.text = model.price;
        self.roomSpaceLabel.text = model.pricePerSqm;
    }
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    
    NSArray *attrTexts = model.tags;
    
    for (NSInteger i = 0; i < attrTexts.count; i++) {
        FHHouseMsgDataItemsItemsTagsModel *tag = attrTexts[i];
        
        NSAttributedString *attrText = [self createTagAttrStringWithText:tag.content isFirst:(i == 0) textColor:HEXRGBA(tag.textColor) backgroundColor:HEXRGBA(tag.backgroundColor)];
        [text appendAttributedString:attrText];
    }
    
    self.areaLabel.attributedText = text;
    [self updateLayoutWithShowTags:text.string.length > 0];
    
    FHHouseMsgDataItemsItemsImagesModel *imageModel = [model.images firstObject];
    if(imageModel.url){
        [self.imgView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed:@"default_image"]];
    }else{
        self.imgView.image = [UIImage imageNamed:@"default_image"];
    }

    
    if(model.houseImageTag){
        self.imageTopLeftLabel.textColor = HEXRGBA(model.houseImageTag.textColor);
        self.imageTopLeftLabel.text = model.houseImageTag.text;
        self.imageTopLeftLabelBgView.backgroundColor = HEXRGBA(model.houseImageTag.backgroundColor);
        self.imageTopLeftLabelBgView.hidden = NO;
    }else{
        self.imageTopLeftLabelBgView.hidden = YES;
    }
    
    if([model.status integerValue] == 1){ // 已下架
        self.priceLabel.textColor = [UIColor themeGray1];
    }else{
        self.priceLabel.textColor = [UIColor themeRed1];
    }
}

- (NSAttributedString *)createTagAttrStringWithText:(NSString *)text
                                            isFirst:(BOOL)isFirst
                                          textColor:(UIColor *)textColor
                                    backgroundColor:(UIColor *)backgroundColor
{
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"  %@  ",text]];
    attributeText.yy_font = [UIFont themeFontRegular:10];
    attributeText.yy_color = textColor;
    NSRange substringRange = [attributeText.string rangeOfString:text];
    [attributeText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:substringRange];
    YYTextBorder *border = [YYTextBorder borderWithFillColor:backgroundColor cornerRadius:2];
    [border setInsets:UIEdgeInsetsMake(0, -4, 0, -4)];
    [attributeText yy_setTextBackgroundBorder:border range:substringRange];
    
    return attributeText;
}

- (void)updateLayoutWithShowTags:(BOOL)isShowTags
{
    if(isShowTags){
        self.titleLabel.numberOfLines = 1;
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.infoPanel);
            make.height.mas_equalTo(20);
        }];
        
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(17);
        }];
        
        [self.areaLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.infoPanel).offset(-3);
            make.right.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(5);
            make.height.mas_equalTo(15);
        }];
        
        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.areaLabel.mas_bottom).offset(5);
            make.height.mas_equalTo(24);
            make.width.lessThanOrEqualTo(@(130));
        }];
        
    }else{
        self.titleLabel.numberOfLines = 2;
        
        CGSize fitSize = [self.titleLabel sizeThatFits:CGSizeMake(UIScreen.mainScreen.bounds.size.width * (UIScreen.mainScreen.bounds.size.width > 376 ? 0.6 : (UIScreen.mainScreen.bounds.size.width > 321 ? 0.56 : 0.48)), 0)];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.infoPanel).offset(fitSize.height < 30 ? 0 : -5);
            make.height.mas_equalTo(fitSize.height < 30 ? 20 : 50);
        }];
        
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(17);
        }];
        
        [self.areaLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.subTitleLabel.mas_bottom);
            make.height.mas_equalTo(0);
        }];
        
        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.areaLabel.mas_bottom);
            make.height.mas_equalTo(24);
            make.width.lessThanOrEqualTo(@(130));
        }];
    }
}

@end
