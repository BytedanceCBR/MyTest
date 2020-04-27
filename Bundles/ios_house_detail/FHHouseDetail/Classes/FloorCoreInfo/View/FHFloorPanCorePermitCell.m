//
//  FHFloorPanCorePermitCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/4/23.
//

#import "FHFloorPanCorePermitCell.h"
#import "TTBaseMacro.h"

@interface FHFloorPanCorePermitCell()

@property (nonatomic , strong) UIView *containerView;

@end

@implementation FHFloorPanCorePermitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHFloorPanCorePermitCellModel class]]) {
        FHFloorPanCorePermitCellModel *model = (FHFloorPanCorePermitCellModel *)data;
        UIView *previouseView = nil;
        for (NSInteger i = 0; i < [model.list count]; i++) {
            UIView *itemContenView = [UIView new];
            itemContenView.backgroundColor = [UIColor clearColor];
            FHFloorPanCorePermitCellItemModel *itemModel = model.list[i];
            UILabel *nameLabel = [UILabel new];
            nameLabel.numberOfLines = 0;
            nameLabel.attributedText = [self contentAttributeString:itemModel.permitName textFont:[UIFont themeFontRegular:14] textColor:RGB(0xae, 0xad, 0xad)];
            [itemContenView addSubview:nameLabel];
            
            [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(31);
                make.width.mas_equalTo(70);
                make.top.mas_equalTo(0);
            }];
            
            UILabel *valueLabel = [UILabel new];
            valueLabel.numberOfLines = 0;
            valueLabel.attributedText = [self contentAttributeString:itemModel.permitValue textFont:[UIFont themeFontMedium:14] textColor:[UIColor themeGray2]];
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
                    if (i % 3 == 0 && i >= 3) {
                        make.top.equalTo(previouseView.mas_bottom).offset(20);
                    }
                    else {
                        make.top.equalTo(previouseView.mas_bottom).offset(18);
                    }
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
            if (i % 3 == 2 && i != [model.list count] - 1) {
                UIView *grayline = [[UIView alloc] init];
                grayline.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
                [self.contentView addSubview:grayline];
                [grayline mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(34);
                    make.right.mas_equalTo(-34);
                    make.height.mas_equalTo(0.5);
                    make.top.equalTo(previouseView.mas_bottom).offset(20);
                }];
                previouseView = grayline;
            }
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

@end

@implementation FHFloorPanCorePermitCellItemModel

@end

@implementation FHFloorPanCorePermitCellModel

@end
