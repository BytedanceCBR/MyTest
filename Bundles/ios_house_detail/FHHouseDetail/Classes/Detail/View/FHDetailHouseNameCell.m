//
//  FHDetailHouseNameCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailHouseNameCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHDetailNewModel.h"
#import "YYLabel.h"
#import <YYText.h>

@interface FHDetailHouseNameCell ()

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
    NSInteger type = ((FHDetailHouseNameModel *)data).type;
    if (type == 1) {
        // 二手房
    } else if (type == 2) {
        // 新房
    }
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

- (UILabel *)createLabel:(NSString *)text textColor:(NSString *)hexColor fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor colorWithHexString:hexColor];
    label.font = [UIFont themeFontRegular:fontSize];
    return label;
}

- (void)setupUI {
    _nameLabel = [self createLabel:@"" textColor:@"#081f33" fontSize:24];
    _nameLabel.font = [UIFont themeFontMedium:24];
    _nameLabel.numberOfLines = 2;
    [self.contentView addSubview:_nameLabel];
    
    _aliasLabel = [self createLabel:@"别名" textColor:@"#a1aab3" fontSize:12];
    _aliasLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_aliasLabel];
    
    _secondaryLabel = [self createLabel:@"" textColor:@"#081f33" fontSize:12];
    [self.contentView addSubview:_secondaryLabel];
    
    _tagsView = [[YYLabel alloc] init];
    _tagsView.numberOfLines = 0;
    _tagsView.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_tagsView];
    
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor colorWithHexString:@"#e8eaeb"];
    [self.contentView addSubview:_bottomLine];
    
    // 布局
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.top.mas_equalTo(20);
    }];
    [self.aliasLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.height.mas_equalTo(0);
    }];
    [self.secondaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.aliasLabel);
        make.left.mas_equalTo(self.aliasLabel.mas_right).offset(4);
        make.height.mas_equalTo(0);
    }];
    [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.aliasLabel.mas_bottom).offset(-2);
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.bottom.mas_equalTo(self.contentView).offset(-16);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    CGFloat hei = UIScreen.mainScreen.scale > 2 ? 0.34 : 0.5;
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (void)setTags:(NSArray *)tags {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    __block CGFloat height = 0;
    NSMutableAttributedString *dotAttributedString = [self createTagAttributeTextNormal:@"." fontSize:12.0];
    [tags enumerateObjectsUsingBlock:^(NSAttributedString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            [text appendAttributedString:dotAttributedString];
        }
        [text appendAttributedString:obj];
        YYTextLayout *tagLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 40, 10000) text:text];
        CGFloat lineHeight = tagLayout.textBoundingSize.height;
        // 只显示一行
        if (lineHeight > height) {
            if (idx == 0) {
                height = lineHeight;
            } else {
                // 删除： · tag
                if ((text.length - (obj.length + 3)) >= 0) {
                    [text deleteCharactersInRange:NSMakeRange((text.length - (obj.length + 3)) , obj.length + 3)];
                }
            }
        }
    }];
    
    self.tagsView.attributedText = text;
}

- (NSMutableAttributedString *)createTagAttributeTextNormal:(NSString *)content fontSize:(CGFloat)fontSize {
    NSMutableAttributedString * attributeText = [[NSMutableAttributedString alloc] initWithString:content];
    attributeText.yy_font = [UIFont themeFontRegular:fontSize];
    attributeText.yy_color = [UIColor colorWithHexString:@"#a1aab3"];
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
