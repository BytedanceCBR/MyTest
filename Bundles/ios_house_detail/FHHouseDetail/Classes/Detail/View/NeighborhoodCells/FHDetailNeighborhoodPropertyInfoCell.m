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

@interface FHDetailNeighborhoodPropertyInfoCell ()

@property (nonatomic, strong)   FHDetailHeaderViewNoMargin       *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong)   FHDetailFoldViewButton       *foldButton;

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
    __block UIView *lastView = nil; // 最后一个视图
    __block NSInteger doubleCount = 0;// 两列计数
    NSMutableArray *singles = [NSMutableArray new];
    CGFloat vHeight = 35.0;
    if (model.baseInfo.count > 0) {
        CGFloat viewWidth = (UIScreen.mainScreen.bounds.size.width - 40) / 2;
        [model.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSingle) {
                      [singles addObject:obj];
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
    if (singles.count > 0) {
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
       }
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(((doubleCount/2 + doubleCount % 2)+singles.count) * vHeight);
        }];
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

    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadowImage).offset(22);
        make.bottom.equalTo(self.shadowImage).offset(-42);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
//    _headerView = [[FHDetailHeaderViewNoMargin alloc] init];
//    _headerView.label.text = @"小区概况";
//    [self.containerView addSubview:_headerView];
//    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.containerView);
//        make.top.equalTo(self.containerView);
//        make.right.equalTo(self.containerView).offset(-15);
//        make.height.mas_offset(26);
//    }];
}

- (void)updateItems:(BOOL)animated {
    FHDetailNeighborhoodPropertyInfoModel *model = (FHDetailNeighborhoodPropertyInfoModel *)self.currentData;
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(35 * model.baseInfo.count);
        }];
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
    _valueLabel.textColor = [UIColor themeGray2];
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
