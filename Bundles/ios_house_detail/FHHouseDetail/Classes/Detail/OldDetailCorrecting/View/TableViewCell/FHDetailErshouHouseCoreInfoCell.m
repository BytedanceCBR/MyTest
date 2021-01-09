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
        __block CGFloat leftOffset = 9;
        CGFloat itemWidth = (SCREEN_WIDTH - 2 * leftOffset) / count;
        [model.coreInfo enumerateObjectsUsingBlock:^(FHDetailOldDataCoreInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // 设置数据
            FHDetailHouseCoreInfoItemView *itemView = [[FHDetailHouseCoreInfoItemView alloc] init];
            itemView.keyLabel.text = obj.value;
            itemView.valueLabel.text = obj.attr;
            itemView.lineView.hidden = (idx == count - 1);
            if(idx == 0) {
                itemView.leftPadding = 12;
            }
            [_itemArr addObject:itemView];
            [self.contentView addSubview:itemView];
                        
            // 设置布局
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView).offset(10);
                make.bottom.mas_equalTo(self.contentView).offset(-5);
                make.width.mas_equalTo(itemWidth);
                make.height.mas_equalTo(46);
                make.left.mas_equalTo(self.contentView).offset(leftOffset);
            }];
            
            leftOffset += itemWidth;
        }];
    }
    [self layoutIfNeeded];
}

- (CGSize)getStringRect:(NSAttributedString *)aString size:(CGSize )sizes {
    CGRect strSize = [aString boundingRectWithSize:CGSizeMake(sizes.width, sizes.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return  CGSizeMake(strSize.size.width, strSize.size.height);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
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
        make.edges.equalTo(self.contentView);
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
        self.leftPadding = 16;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:24];
    _keyLabel.textColor = [UIColor colorWithHexStr:@"#FE5500"];
    _keyLabel.font = [UIFont themeFontMedium:24];
    [self addSubview:_keyLabel];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _valueLabel.textColor = [UIColor colorWithHexStr:@"#999999"];
    _valueLabel.font = [UIFont themeFontRegular:14];
    [self addSubview:_valueLabel];
    
    _lineView = [[UIView alloc]init];
    _lineView.backgroundColor = [UIColor colorWithHexStr:@"#E7E7E7"];
    [self addSubview:_lineView];
    // 布局
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftPadding);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(26);
        make.right.mas_equalTo(self).offset(-10);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftPadding);
        make.top.mas_equalTo(self.keyLabel.mas_bottom).offset(6);
        make.height.mas_equalTo(14);
        make.right.mas_equalTo(self).offset(-10);
        make.bottom.mas_equalTo(self).offset(0);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.keyLabel);
        make.bottom.equalTo(self.valueLabel);
        make.right.equalTo(self.mas_right);
        make.width.mas_offset(.5);
    }];
}

- (void)updateConstraints {
    
    [self.keyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(self.leftPadding);
    }];
    
    [self.valueLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftPadding);
    }];
    
    [super updateConstraints];
}
@end

// FHDetailErshouHouseCoreInfoModel
@implementation FHDetailErshouHouseCoreInfoModel


@end
