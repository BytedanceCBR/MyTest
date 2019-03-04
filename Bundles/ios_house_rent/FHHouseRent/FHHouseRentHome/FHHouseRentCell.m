//
//  FHHouseRentCell.m
//  FHHouseRent
//
//  Created by leo on 2018/11/18.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHHouseRentCell.h"
#import <Masonry/Masonry.h>
#import <YYText/YYText.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "FHCommonDefines.h"
#import "FHHouseRentModel.h"


#define HOR_MARGIN 20
#define ICON_WIDTH 114
#define ICON_HEIGHT 85
#define PRICE_DEFAULT_TOP 71
#define PRICE_SINGLE_TITLE_TOP 51

@implementation FHImageCornerView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.frame = self.bounds;
    layer.path = maskPath.CGPath;
    self.layer.mask = layer;
}

@end

@implementation FHTagItem

+ (instancetype)instanceWithText:(NSString *)text
                       withColor:(NSString *)textColor
                     withBgColor:(NSString *)bgColor {
    FHTagItem* item = [[FHTagItem alloc] initWithText:text
                                            withColor:textColor
                                          withBgColor:bgColor];
    return item;
}

- (instancetype)initWithText:(NSString *)text
                   withColor:(NSString *)textColor
                 withBgColor:(NSString *)bgColor {
    self = [super init];
    if (self) {
        self.text = text;
        self.textColor = textColor;
        self.bgColor = bgColor;
    }
    return self;
}

@end

@interface FHHouseRentCell ()
@property (nonatomic, strong) UIView* infoContainerView;
//@property (nonatomic, strong) CAShapeLayer *tagShapeLayer;

@property (nonatomic, weak) FHImageCornerView* tagBgView;
@end

@implementation FHHouseRentCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)prepareForReuse {
    
    [super prepareForReuse];
    self.tagBgView.hidden = YES;
    self.imageTagView.hidden = YES;
//    self.tagShapeLayer.hidden = YES;

}

-(void)setupUI {

    self.iconView = [[UIImageView alloc] init];
    _iconView.contentMode = UIViewContentModeScaleAspectFill;
    _iconView.clipsToBounds = YES;
    _iconView.layer.cornerRadius = 4;
    _iconView.layer.masksToBounds = true;
    _iconView.layer.borderWidth = 0.5;
    _iconView.layer.borderColor = [UIColor themeGray6].CGColor;
    [self.contentView addSubview:_iconView];
    _iconView.image = [UIImage imageNamed:@"default_image"];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.width.mas_equalTo(ICON_WIDTH);
        make.height.mas_equalTo(ICON_HEIGHT);
        make.bottom.mas_equalTo(-10);
    }];
    
    self.imageTagView = [[UILabel alloc]init];
    _imageTagView.textAlignment = NSTextAlignmentCenter;
    _imageTagView.textColor = [UIColor whiteColor];
    _imageTagView.font = [UIFont themeFontRegular:10];
    
//    self.tagShapeLayer = [[CAShapeLayer alloc] init];
//    _tagShapeLayer.frame = CGRectMake(0, 0, 48, 17);
//    UIBezierPath *bpath = [UIBezierPath bezierPathWithRoundedRect:_tagShapeLayer.frame byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
//    _tagShapeLayer.path = [bpath CGPath];

    //fix label layer hide by tagshapelayer in ios 9
    FHImageCornerView *tagBgView = [[FHImageCornerView alloc] init];
//    [tagBgView.layer addSublayer:_tagShapeLayer];
    [self.contentView addSubview:tagBgView];
    self.tagBgView = tagBgView;
    
    [self.contentView addSubview:_imageTagView];
    [_imageTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView).offset(0.5);
        make.top.mas_equalTo(self.iconView).offset(0.5);
        make.size.mas_equalTo(CGSizeMake(48, 17));
    }];
    
    [tagBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.imageTagView);
    }];
    
    
    self.infoContainerView = [[UIView alloc] init];
    [self.contentView addSubview:_infoContainerView];
    [_infoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).mas_offset(15);
        make.height.mas_equalTo(90);
        make.top.mas_equalTo(self.iconView).offset(-3);
        make.right.mas_equalTo(-20);
    }];

     self.majorTitle = [[UILabel alloc] init];
    int fontSize = (SCREEN_WIDTH == 320) ? 14 : 16;
    _majorTitle.font = [UIFont themeFontRegular:fontSize];
    _majorTitle.textColor = [UIColor themeGray1];
    _majorTitle.preferredMaxLayoutWidth = SCREEN_WIDTH - 2*HOR_MARGIN -ICON_WIDTH - 15;
    [_infoContainerView addSubview:_majorTitle];
    [_majorTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.infoContainerView);
        make.height.mas_equalTo(22);
    }];

    self.extendTitle = [[UILabel alloc] init];
    _extendTitle.font = [UIFont themeFontRegular:12];
    _extendTitle.textColor = [UIColor themeGray2];
    [_infoContainerView addSubview:_extendTitle];
    [_extendTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.infoContainerView);
        make.top.mas_equalTo(self.majorTitle.mas_bottom).mas_offset(4);
        make.height.mas_equalTo(17);
    }];

    self.tagsLabel = [[YYLabel alloc] init];
    [_infoContainerView addSubview:_tagsLabel];
    [_tagsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoContainerView).offset(-3.5);
        make.right.mas_equalTo(self.infoContainerView).offset(3.5);
        make.top.mas_equalTo(self.extendTitle.mas_bottom).mas_offset(7);
        make.height.mas_equalTo(15);
    }];

    self.priceLabel = [[UILabel alloc] init];
    _priceLabel.font = [UIFont themeFontMedium:14];
    _priceLabel.textColor = [UIColor themeRed1];
    [_infoContainerView addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.infoContainerView);
//        make.top.mas_equalTo(self.tagsLabel.mas_bottom).mas_offset(6);
        make.top.mas_equalTo(71);
        make.height.mas_equalTo(20);
    }];
}

-(void)setTags:(NSArray<FHTagItem*>*)tags {
    
    if (tags.count == 0) {
        self.tagsLabel.hidden = YES;
        self.majorTitle.numberOfLines = 2;
                
        CGFloat height = [self.majorTitle sizeThatFits:CGSizeMake(self.majorTitle.preferredMaxLayoutWidth, CGFLOAT_MAX)].height;
        CGFloat priceTop = PRICE_DEFAULT_TOP;
        if (height < 22) {
            height = 22;
        }else if (height > 50){
            height = 50;
        }
        
        //系统单行高度22.5  双行 45
        if (height < 24) {
            priceTop = PRICE_SINGLE_TITLE_TOP;
        }
        
        [self.majorTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(priceTop);
        }];
        
        [self setNeedsUpdateConstraints];
        
    }else{
        
        CGFloat tagLabelWidth = [[UIScreen mainScreen] bounds].size.width - 170;
        __block NSMutableAttributedString* tagsAttributeString = [[NSMutableAttributedString alloc] init];
        __block CGFloat height = 0;
        [tags enumerateObjectsUsingBlock:^(FHTagItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSAttributedString* tag = [self createTagAttrString:obj];
            [tagsAttributeString appendAttributedString:tag];
            
            YYTextLayout* layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(tagLabelWidth, MAXFLOAT) text:tagsAttributeString];
            CGFloat lineHeigh = layout.textBoundingSize.height;
            if (lineHeigh > height) {
                if (idx != 0) {
                    [tagsAttributeString deleteCharactersInRange:NSMakeRange(tagsAttributeString.length - tag.length, tag.length)];
                } else {
                    height = lineHeigh;
                }
            }
        }];
        self.tagsLabel.attributedText = tagsAttributeString;
        
        self.tagsLabel.hidden = NO;
        self.majorTitle.numberOfLines = 1;
        
        [self.majorTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(22);
        }];
        
        [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(PRICE_DEFAULT_TOP);
        }];
    }
    
    [self setNeedsLayout];
}

-(void)setHouseImages:(FHHouseRentDataItemsHouseImageTagModel *)houseImageTagModel
{
    if (!houseImageTagModel) {
        self.imageTagView.hidden = YES;
        self.tagBgView.hidden = YES;
//        self.tagShapeLayer.fillColor = [[UIColor clearColor] CGColor];
        self.imageTagView.text = nil;
    }else{
        self.imageTagView.hidden = NO;
        UIColor *bgColor = [UIColor colorWithHexString:houseImageTagModel.backgroundColor];
//        self.tagShapeLayer.fillColor = [bgColor CGColor];
        self.tagBgView.hidden = NO;
        self.imageTagView.textColor = [UIColor colorWithHexString: houseImageTagModel.textColor];
        self.imageTagView.text = houseImageTagModel.text;
        self.tagBgView.backgroundColor = bgColor;

    }
//    self.tagShapeLayer.hidden = self.imageTagView.hidden;
}

-(NSAttributedString*)createTagAttrString:(FHTagItem*)item {
    NSMutableAttributedString* result = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@  ", item.text]];
    result.yy_font = [UIFont themeFontRegular:10];
    result.yy_color = [UIColor colorWithHexString:item.textColor];
    [result yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO]
                        range:NSMakeRange(2, item.text.length)];
    YYTextBorder* border = [YYTextBorder borderWithFillColor:[UIColor colorWithHexString:item.bgColor]
                                                cornerRadius:2];
    border.insets = UIEdgeInsetsMake(0, -3, 0, -3);
    [result yy_setTextBackgroundBorder:border range:NSMakeRange(2, item.text.length)];
    return result;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
