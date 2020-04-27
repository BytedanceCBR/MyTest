//
//  FHDetailNewHouseNewsCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHFloorPanCorePropertyCell.h"
#import "TTRoute.h"
#import "UIColor+Theme.h"
#import "TTLabelTextHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTBaseMacro.h"

@interface FHFloorPanCorePropertyCell ()

@property (nonatomic , strong) UIView *containerView;

@end

@implementation FHFloorPanCorePropertyCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.containerView];
        [self initConstraints];
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

-(void)initConstraints
{
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
}

- (void)maskButtonClick:(UIButton *)button {
   
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHFloorPanCorePropertyCellModel class]]) {
        FHFloorPanCorePropertyCellModel *model = (FHFloorPanCorePropertyCellModel *)data;
        UIView *previouseView = nil;
        for (NSInteger i = 0; i < [model.list count]; i++) {
            UIView *itemContenView = [UIView new];
            itemContenView.backgroundColor = [UIColor clearColor];
            FHFloorPanCorePropertyCellItemModel *itemModel = model.list[i];
            UILabel *nameLabel = [UILabel new];
            nameLabel.numberOfLines = 0;
            nameLabel.attributedText = [self contentAttributeString:itemModel.propertyName textFont:[UIFont themeFontRegular:14] textColor:RGB(0xae, 0xad, 0xad)];
            [itemContenView addSubview:nameLabel];
            
            [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(31);
                make.width.mas_equalTo(70);
                make.top.mas_equalTo(0);
            }];
            
            UILabel *valueLabel = [UILabel new];
            valueLabel.numberOfLines = 0;
            valueLabel.attributedText = [self contentAttributeString:itemModel.propertyValue textFont:[UIFont themeFontMedium:14] textColor:[UIColor themeGray2]];
            [itemContenView addSubview:valueLabel];
            
            [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(nameLabel.mas_right).offset(14);
                make.top.equalTo(nameLabel);
                make.right.equalTo(itemContenView).offset(-31);
                make.bottom.equalTo(itemContenView);
            }];
            
            [self.contentView addSubview:itemContenView];
            
            [itemContenView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (previouseView) {
                    make.top.equalTo(previouseView.mas_bottom).offset(18);
                }else
                {
                    make.top.equalTo(self.contentView).offset(29);
                }
                if (i == [model.list count] - 1) {
                    make.bottom.equalTo(self.contentView).offset(-29);
                }
                make.left.right.equalTo(self.contentView);
            }];
            previouseView = itemContenView;
        }
    }
}

- (NSAttributedString *)contentAttributeString:(NSString *) str textFont:(UIFont *)font textColor:(UIColor *)color {
    NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
       if(!isEmptyString(str)) {
           NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color};
           NSAttributedString *content = [[NSAttributedString alloc] initWithString:str attributes: attributes];
           [attributedText appendAttributedString:content];
           NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
           CGFloat lineHeight = 16;
           paragraphStyle.minimumLineHeight = lineHeight;
           paragraphStyle.maximumLineHeight = lineHeight;
           paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
           [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
       }
    return attributedText;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    [self.contentView addSubview:self.containerView];
    [self initConstraints];
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

@implementation FHFloorPanCorePropertyCellItemModel

@end

@implementation FHFloorPanCorePropertyCellModel

@end
