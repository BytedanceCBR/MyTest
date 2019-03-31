//
//  FHPriceValuationHistoryCell.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/22.
//

#import "FHPriceValuationHistoryCell.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "UIImageView+BDWebImage.h"

@interface FHPriceValuationHistoryCell()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIView *sepLine;
@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation FHPriceValuationHistoryCell

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
    self.contentView.backgroundColor = [UIColor themeGray7];
    
    self.containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [_containerView addSubview:_titleLabel];
    
    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    [_containerView addSubview:_subTitleLabel];
    
    self.priceLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray1]];
    [_containerView addSubview:_priceLabel];
    
    self.sepLine = [[UIView alloc] init];
    _sepLine.backgroundColor = [UIColor themeGray6];
    [self.containerView addSubview:_sepLine];
    
    self.statusImageView = [[UIImageView alloc] init];
    _statusImageView.backgroundColor = [UIColor themeGray7];
    [_containerView addSubview:_statusImageView];
    
    self.statusLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    [_containerView addSubview:_statusLabel];
}

- (void)initConstraints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).offset(15);
        make.top.mas_equalTo(self.containerView).offset(15);
        make.height.mas_equalTo(22);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
        make.height.mas_equalTo(20);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.containerView).offset(-15);
        make.top.mas_equalTo(self.containerView).offset(29);
        make.height.mas_equalTo(24);
    }];
    
    [self.sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).offset(15);
        make.right.mas_equalTo(self.containerView).offset(-15);
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.statusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).offset(15);
        make.top.mas_equalTo(self.sepLine.mas_bottom).offset(12);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.statusImageView.mas_right).offset(4);
        make.centerY.mas_equalTo(self.statusImageView);
        make.height.mas_equalTo(20);
    }];
    
    [self layoutIfNeeded];
    [self addShadowToView:self.containerView withOpacity:0.1 shadowRadius:8 andCornerRadius:4];
}

- (void)updateCell:(FHPriceValuationHistoryDataHistoryHouseListModel *)model {
    self.titleLabel.text = model.houseInfo.neiborhoodNameStr;
    self.subTitleLabel.text = model.houseInfo.houseInfoStr;
    self.statusLabel.text = model.houseInfo.stateDescStr;
    NSString *priceStr = [NSString stringWithFormat:@"%.0f",round([model.houseInfo.estimatePriceInt longLongValue]/1000000)];
    self.priceLabel.attributedText = [self getPriceStr:priceStr];
    self.statusLabel.textColor = [UIColor colorWithHexString:model.houseInfo.imageInfo.textColor];
    NSInteger state = [model.houseInfo.stateInt integerValue];
    [self setState:state model:model];
    
}

- (void)setState:(NSInteger)state model:(FHPriceValuationHistoryDataHistoryHouseListModel *)model {
    //持平
    if(state == 2){
        self.statusImageView.image = nil;
        self.statusImageView.backgroundColor = [UIColor themeGray7];
        
        [self.statusImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        
        [self.statusLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.statusImageView.mas_right).offset(0);
        }];
    }else{
        [self.statusImageView bd_setImageWithURL:[NSURL URLWithString:model.houseInfo.imageInfo.icon.url]];
        self.statusImageView.backgroundColor = [UIColor clearColor];
        
        [self.statusImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(20);
        }];
        
        [self.statusLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.statusImageView.mas_right).offset(4);
        }];
    }
    
}
-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius {
    //////// shadow /////////
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.frame = view.layer.frame;
    
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    shadowLayer.shadowOffset = CGSizeMake(2, 6);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    shadowLayer.shadowOpacity = shadowOpacity;//0.8;//阴影透明度，默认0
    shadowLayer.shadowRadius = shadowRadius;//8;//阴影半径，默认3
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = shadowLayer.bounds.size.width;
    float height = shadowLayer.bounds.size.height;
    float x = shadowLayer.bounds.origin.x;
    float y = shadowLayer.bounds.origin.y;
    
    CGPoint topLeft      = shadowLayer.bounds.origin;
    CGPoint topRight     = CGPointMake(x + width, y);
    CGPoint bottomRight  = CGPointMake(x + width, y + height);
    CGPoint bottomLeft   = CGPointMake(x, y + height);
    
    CGFloat offset = -1.f;
    [path moveToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    [path addArcWithCenter:CGPointMake(topLeft.x + cornerRadius, topLeft.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(topRight.x - cornerRadius, topRight.y - offset)];
    [path addArcWithCenter:CGPointMake(topRight.x - cornerRadius, topRight.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 * 3 endAngle:M_PI * 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomRight.x + offset, bottomRight.y - cornerRadius)];
    [path addArcWithCenter:CGPointMake(bottomRight.x - cornerRadius, bottomRight.y - cornerRadius) radius:(cornerRadius + offset) startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y + offset)];
    [path addArcWithCenter:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y - cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    
    //设置阴影路径
    shadowLayer.shadowPath = path.CGPath;
    
    //////// cornerRadius /////////
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [view.superview.layer insertSublayer:shadowLayer below:view.layer];
}

- (NSAttributedString *)getPriceStr:(NSString *)price {
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] init];
    if(price){
        NSAttributedString *priceAstr = [[NSAttributedString alloc] initWithString:price attributes:@{NSFontAttributeName:[UIFont themeFontDINAlternateBold:20]}];
        [aStr appendAttributedString:priceAstr];
        NSAttributedString *unitAstr = [[NSAttributedString alloc] initWithString:@"万" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:12]}];
        [aStr appendAttributedString:unitAstr];
    }
    return aStr;
}

@end
