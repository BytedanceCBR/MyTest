//
//  FHDetailNeighborhoodPropertyInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailNeighborhoodPropertyInfoCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHExtendHotAreaButton.h"
#import "FHDetailFoldViewButton.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"
#import "FHDetailHeaderViewNoMargin.h"

#define kFHPropertyItemInfoHeight 35.0

@interface FHDetailNeighborhoodPropertyInfoCell ()

@property (nonatomic, strong)   FHDetailHeaderViewNoMargin       *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong)   FHDetailFoldViewButton       *foldButton;
@property (nonatomic, strong)   NSArray       *singleItems;
@property (nonatomic, strong)   UIView       *opView;// 半透明视图
@property (nonatomic, assign)   NSInteger       foldCount;// 折叠展开计数，默认是7

@end

@implementation FHDetailNeighborhoodPropertyInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodPropertyInfoModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNeighborhoodPropertyInfoModel *model = (FHDetailNeighborhoodPropertyInfoModel *)data;
    self.shadowImage.image = model.shadowImage;
    if (model.baseInfoFoldCount && model.baseInfoFoldCount.length > 0) {
        NSInteger value = [model.baseInfoFoldCount integerValue];
        if (value > 0) {
            self.foldCount = value;
        }
    }
    __block UIView *lastView = nil; // 最后一个视图
    __block NSInteger doubleCount = 0;// 两列计数
    NSMutableArray *singles = [NSMutableArray new];
    CGFloat vHeight = kFHPropertyItemInfoHeight;
    if (model.baseInfo.count > 0) {
        CGFloat viewWidth = (UIScreen.mainScreen.bounds.size.width - 40) / 2;
        [model.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isSingle = YES;
            if (obj.isSingle) {
                // 非空字段
                if (obj.value.length > 0 && ![obj.value isEqualToString:@"-"]) {
                     [singles addObject:obj];
                }
            } else {
                // 两列
                if (doubleCount % 2 == 0) {
                    FHDetailNeighborhoodPropertyItemView *itemView = [[FHDetailNeighborhoodPropertyItemView alloc] init];
                    [self.containerView addSubview:itemView];
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo((doubleCount/2) * vHeight);
                        make.left.mas_equalTo(self.containerView);
                        make.width.mas_equalTo(viewWidth);
                        make.height.mas_equalTo(vHeight);
                    }];
                    itemView.keyLabel.text = obj.attr;
                    itemView.valueLabel.text = obj.value;
                    lastView = itemView;
                }else {
                    FHDetailNeighborhoodPropertyItemView *itemView = [[FHDetailNeighborhoodPropertyItemView alloc] init];
                    [self.containerView addSubview:itemView];
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo((doubleCount/2) * vHeight);
                        make.left.equalTo(self.containerView).offset(viewWidth);
                        make.width.mas_equalTo(viewWidth);
                        make.height.mas_equalTo(vHeight);
                    }];
                    itemView.keyLabel.text = obj.attr;
                    itemView.valueLabel.text = obj.value;
                    lastView = itemView;
                }
                doubleCount += 1;
            }
        }];
    }
    self.singleItems = singles;
    if (singles.count > 0) {
        // 先布局items
        [singles enumerateObjectsUsingBlock:^(FHHouseCoreInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHDetailNeighborhoodPropertyItemView *itemView = [[FHDetailNeighborhoodPropertyItemView alloc] init];
            [self.containerView addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo((idx+(doubleCount/2)+doubleCount % 2)* vHeight);
                make.left.right.mas_equalTo(self.containerView);
                make.height.mas_equalTo(vHeight);
            }];
            itemView.keyLabel.text = obj.attr;
            itemView.valueLabel.text = obj.value;
            lastView = itemView;
        }];
        // > 7 添加折叠展开
        if (singles.count > self.foldCount) {
            if (_foldButton) {
                [_foldButton removeFromSuperview];
                _foldButton = nil;
            }
            if (_opView) {
                [_opView removeFromSuperview];
            }
            _opView = [[UIView alloc] initWithFrame:CGRectZero];
            // 渐变色layer
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, 53);
            gradientLayer.colors = @[(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor,
                                     (__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:1.0].CGColor];
            gradientLayer.startPoint = CGPointMake(0.5, 0.0);
            gradientLayer.endPoint = CGPointMake(0.5, 1.0);
            [_opView.layer addSublayer:gradientLayer];
            [self.contentView addSubview:_opView];
            [_opView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(53);
                make.left.right.mas_equalTo(self.containerView);
                make.top.mas_equalTo(self.containerView.mas_bottom).offset(-30);
            }];
            
            _foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部信息" upText:@"收起" isFold:YES];
            _foldButton.openImage = [UIImage imageNamed:@"message_more_arrow"];
            _foldButton.foldImage = [UIImage imageNamed:@"message_flod_arrow"];
            _foldButton.keyLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
            _foldButton.keyLabel.font = [UIFont themeFontRegular:14];
            [self.contentView addSubview:_foldButton];
            [_foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.containerView.mas_bottom);
                make.height.mas_equalTo(58);
                make.left.right.mas_equalTo(self.contentView);
            }];
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.shadowImage).offset(-93);
            }];
            [self.foldButton addTarget:self action:@selector(foldButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(((doubleCount/2 + doubleCount % 2)+singles.count) * vHeight);
            }];
        }
    }
    [self updateItems:NO];
}


- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
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

- (void)setupUI {
    _foldCount = 7;
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadowImage).offset(12);
        make.bottom.equalTo(self.shadowImage).offset(-42);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
}

- (void)updateItems:(BOOL)animated {
    FHDetailNeighborhoodPropertyInfoModel *model = (FHDetailNeighborhoodPropertyInfoModel *)self.currentData;
    if (self.singleItems.count > self.foldCount) {
        if (animated) {
            [model.tableView beginUpdates];
        }
        if (model.isFold) {
            CGFloat showHeight = kFHPropertyItemInfoHeight * self.foldCount;
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(showHeight);
            }];
        } else {
           CGFloat showHeight = kFHPropertyItemInfoHeight * self.singleItems.count;
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(showHeight);
            }];
        }
        [self setNeedsUpdateConstraints];
        if (animated) {
            [model.tableView endUpdates];
        }
    } else if (self.singleItems.count > 0) {
        CGFloat showHeight = kFHPropertyItemInfoHeight * self.singleItems.count;
         [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.height.mas_equalTo(showHeight);
         }];
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)foldButtonClick:(UIButton *)button {
    FHDetailNeighborhoodPropertyInfoModel *model = (FHDetailNeighborhoodPropertyInfoModel *)self.currentData;
    model.isFold = !model.isFold;
    self.foldButton.isFold = model.isFold;
    if (model.isFold) {
        self.opView.hidden = NO;
    } else {
        self.opView.hidden = YES;
    }
    [self updateItems:YES];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_info";
}

@end


// FHDetailNeighborhoodPropertyInfoModel
@implementation FHDetailNeighborhoodPropertyInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFold = YES;
    }
    return self;
}

@end


@implementation FHDetailNeighborhoodPropertyItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _keyLabel.textColor = [UIColor themeGray3];
    [self addSubview:_keyLabel];
    [_keyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_keyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _valueLabel.textColor = [UIColor themeGray1];
    _valueLabel.font = [UIFont themeFontMedium:14];
    [self addSubview:_valueLabel];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    // 布局
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.width.mas_offset(56);
        make.bottom.mas_equalTo(self).offset(-5);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.keyLabel.mas_right).offset(10);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(-5);
        make.bottom.mas_equalTo(self.keyLabel);
    }];
}


@end
