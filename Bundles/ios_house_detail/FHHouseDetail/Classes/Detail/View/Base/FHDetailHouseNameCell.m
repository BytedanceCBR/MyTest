//
//  FHDetailHouseNameCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailHouseNameCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHDetailNewModel.h"
#import "YYLabel.h"
#import "YYText.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"

@interface FHDetailHouseNameCell ()

@property (nonatomic, strong)   UIView        *containerView;
@property (nonatomic, strong)   UILabel       *nameLabel;
@property (nonatomic, strong)   UILabel       *aliasLabel;
@property (nonatomic, strong)   UILabel       *secondaryLabel;
@property (nonatomic, strong)   YYLabel       *tagsView;
@property (nonatomic, strong)   UIView       *bottomLine;

@end

@implementation FHDetailHouseNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailHouseNameModel class]]) {
        return;
    }
    self.currentData = data;
    //
    self.bottomLine.hidden = YES;
    FHDetailHouseNameModel *model = (FHDetailHouseNameModel *)data;
    NSInteger type = model.type;
    if (type == 1) {
        // 二手房
        self.bottomLine.hidden = YES;
    } else if (type == 2) {
        // 新房
        self.bottomLine.hidden = NO;
        self.containerView.hidden = NO;
        _aliasLabel.textColor = RGB(0xae, 0xad, 0xad);
        _secondaryLabel.textColor = [UIColor themeGray2];
        _secondaryLabel.font = [UIFont themeFontSemibold:12];
    }
    [self initConstraints:type];
    if (model.isHiddenLine) {
        self.bottomLine.hidden = YES;
    }
    self.nameLabel.text = model.name;
    [self setAlias:model.aliasName];
    [self setTags:model.tags Type:type];
    
    if(self.baseViewModel.houseType == FHHouseTypeSecondHandHouse) {
        if([self.baseViewModel.detailData isKindOfClass:[FHDetailOldModel class]]) {
            FHDetailOldModel *detailOldModel = self.baseViewModel.detailData;
            if(detailOldModel.data.baseExtra.detective.detectiveInfo.showSkyEyeLogo) {
                [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(6);
                }];
            }
        }
    }
    [self layoutIfNeeded];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 10;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

- (void)setupUI {
    
    [self.contentView addSubview:self.containerView];
    self.containerView.hidden = YES;
    
    _nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:24];
    _nameLabel.textColor = [UIColor themeGray1];
    _nameLabel.font = [UIFont themeFontMedium:24];
    _nameLabel.numberOfLines = 2;
    [self.contentView addSubview:_nameLabel];
    
    _aliasLabel = [UILabel createLabel:@"别名" textColor:@"" fontSize:12];
    _aliasLabel.textColor = [UIColor themeGray3];
    _aliasLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_aliasLabel];
    
    _secondaryLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _secondaryLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_secondaryLabel];
    
    _tagsView = [[YYLabel alloc] init];
    _tagsView.numberOfLines = 0;
    _tagsView.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_tagsView];
    
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_bottomLine];
    
    // 布局
    //[self initConstraints:0];
}

-(void) initConstraints:(NSInteger)type
{
    [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.left.mas_equalTo(15);
           make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
    CGFloat nameOffsetX = 0;
    CGFloat secondaryOffsetX = 0;
    CGFloat nameOffsetY = 0;
    CGFloat secondaryOffsetY = 0;
    CGFloat tagsViewOffsetY = 0;
    if (type == 2) {
        nameOffsetX = 11;
        secondaryOffsetX = 8;
        nameOffsetY = 5;
        secondaryOffsetY = 6;
        tagsViewOffsetY = -10;
    }
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 + nameOffsetX);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.top.mas_equalTo(20 + nameOffsetY);
    }];
    [self.aliasLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(4 + secondaryOffsetY);
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.height.mas_equalTo(0);
    }];
    [self.secondaryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.aliasLabel);
        make.left.mas_equalTo(self.aliasLabel.mas_right).offset(4 + secondaryOffsetX);
        make.height.mas_equalTo(0);
    }];
    [self.tagsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.aliasLabel.mas_bottom).offset(-2);
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.bottom.mas_equalTo(self.contentView).offset(-16 + tagsViewOffsetY);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    CGFloat hei = UIScreen.mainScreen.scale > 2 ? 0.34 : 0.5;
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(hei);
    }];
}

- (void)setAlias:(NSString *)alias {
    if (alias.length > 0) {
        self.secondaryLabel.text = alias;
        [self.aliasLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(17);
        }];
        [self.secondaryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(17);
        }];
        [self.tagsView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.aliasLabel.mas_bottom).offset(10);
        }];
        self.aliasLabel.hidden = NO;
        self.secondaryLabel.hidden = NO;
    } else {
        [self.aliasLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.secondaryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.tagsView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.aliasLabel.mas_bottom).offset(-2);
        }];
        self.aliasLabel.hidden = YES;
        self.secondaryLabel.hidden = YES;
    }
}

- (void)setTags:(NSArray *)tags Type:(NSInteger)type {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    __block CGFloat height = 0;
    NSMutableAttributedString *dotAttributedString = [self createTagAttributeTextNormal:@" · " fontSize:12.0 Type:type];
    [tags enumerateObjectsUsingBlock:^(FHHouseTagsModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[FHHouseTagsModel class]]) {
            *stop = YES;
        }
        if (idx > 0) {
            [text appendAttributedString:dotAttributedString];
        }
        NSAttributedString *attr = [self createTagAttributeTextNormal:obj.content fontSize:12.0 Type:type];
        [text appendAttributedString:attr];
        YYTextLayout *tagLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 40, 10000) text:text];
        CGFloat lineHeight = tagLayout.textBoundingSize.height;
        // 只显示一行
        if (lineHeight > height) {
            if (idx == 0) {
                height = lineHeight;
            } else {
                // 删除： · tag
                if ((text.length - (attr.length + 3)) >= 0) {
                    [text deleteCharactersInRange:NSMakeRange((text.length - (attr.length + 3)) , attr.length + 3)];
                }
            }
        }
    }];
    
    self.tagsView.attributedText = text;
}

- (NSMutableAttributedString *)createTagAttributeTextNormal:(NSString *)content fontSize:(CGFloat)fontSize Type:(NSInteger)type {
    NSMutableAttributedString * attributeText = [[NSMutableAttributedString alloc] initWithString:content];
    attributeText.yy_font = [UIFont themeFontRegular:fontSize];
    attributeText.yy_color = [UIColor themeGray3];
    if (type == 2) {
        attributeText.yy_color = RGB(0xae, 0xad, 0xad);
    }
    attributeText.yy_lineSpacing = 2;
    attributeText.yy_lineHeightMultiple = 0;
    attributeText.yy_maximumLineHeight = 0;
    attributeText.yy_minimumLineHeight = 20;
    return attributeText;
}

@end


@implementation FHDetailHouseNameModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = 1;
    }
    return self;
}

@end
