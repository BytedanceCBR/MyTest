//
//  FHDetailErshouHouseCoreInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailErshouHouseCoreInfoCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "UILabel+House.h"

@interface FHDetailErshouHouseCoreInfoCell()
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong) NSMutableArray *itemArr;
@end
@implementation FHDetailErshouHouseCoreInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailErshouHouseCoreInfoModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.itemArr) {
        [v removeFromSuperview];
    }
    FHDetailErshouHouseCoreInfoModel *model = (FHDetailErshouHouseCoreInfoModel *)data;
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    NSInteger count = model.coreInfo.count;
    if (count > 0) {
//        CGFloat width = (UIScreen.mainScreen.bounds.size.width - 30)  / count;
        __block CGFloat leftOffset = 15;
        [model.coreInfo enumerateObjectsUsingBlock:^(FHDetailOldDataCoreInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHDetailHouseCoreInfoItemView *itemView = [[FHDetailHouseCoreInfoItemView alloc] init];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:obj.value attributes:@{NSFontAttributeName: [UIFont themeFontDINAlternateBold:22]}];
            CGSize textSize =[self getStringRect:text size:CGSizeMake(CGFLOAT_MAX, 14)];

            [self.contentView addSubview:itemView];
            if (idx == count - 1) {
                itemView.lineView.hidden = YES;
            }
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.shadowImage).offset(12);
                make.bottom.mas_equalTo(self.shadowImage).offset(-12);
                make.width.mas_equalTo(textSize.width+40);
                make.left.mas_equalTo(self.contentView).offset(leftOffset);
            }];
            leftOffset += textSize.width+40;
            // 设置数据
            itemView.keyLabel.text = obj.value;
            itemView.valueLabel.text = obj.attr;
            [_itemArr addObject:itemView];
        }];
    }
    [self layoutIfNeeded];
}

- (CGSize)getStringRect:(NSAttributedString *)aString size:(CGSize )sizes
{
    CGRect strSize = [aString boundingRectWithSize:CGSizeMake(sizes.width, sizes.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return  CGSizeMake(strSize.size.width, strSize.size.height);
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        _itemArr = [[NSMutableArray alloc]init];
        [self initBacIma];
    }
    return self;
}

- (void)initBacIma {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        shadowImage.image = [[UIImage imageNamed:@""] resizableImageWithCapInsets:UIEdgeInsetsMake(20,0,20,0) resizingMode:UIImageResizingModeStretch];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}
@end

// FHDetailHouseCoreInfoItemView

@interface FHDetailHouseCoreInfoItemView ()

@end

@implementation FHDetailHouseCoreInfoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:22];
    _keyLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
//    _keyLabel.font = [UIFont themeFontMedium:22];
    _keyLabel.font = [UIFont themeFontDINAlternateBold:22];
    [self addSubview:_keyLabel];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _valueLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
    [self addSubview:_valueLabel];
    
    _lineView = [[UIView alloc]init];
    _lineView.backgroundColor = [UIColor colorWithHexStr:@"#e7e7e7"];
    [self addSubview:_lineView];
    // 布局
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(25);
        make.right.mas_equalTo(self).offset(-10);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(self.keyLabel.mas_bottom).offset(3);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(self).offset(-10);
        make.bottom.mas_equalTo(self).offset(-12);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.keyLabel);
        make.bottom.equalTo(self.valueLabel);
        make.right.equalTo(self.mas_right);
        make.width.mas_offset(.5);
    }];
}
@end

// FHDetailErshouHouseCoreInfoModel
@implementation FHDetailErshouHouseCoreInfoModel


@end
