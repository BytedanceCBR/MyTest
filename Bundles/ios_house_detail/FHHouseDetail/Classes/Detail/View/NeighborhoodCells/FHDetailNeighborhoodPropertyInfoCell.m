//
//  FHDetailNeighborhoodPropertyInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailNeighborhoodPropertyInfoCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "FHDetailFoldViewButton.h"
#import "UILabel+House.h"

@interface FHDetailNeighborhoodPropertyInfoCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
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
    //
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailNeighborhoodPropertyInfoModel *model = (FHDetailNeighborhoodPropertyInfoModel *)data;
    if (model.baseInfo.count > 0) {
        __block NSInteger itemsCount = 0;
        CGFloat vHeight = 30.0;
        [model.baseInfo enumerateObjectsUsingBlock:^(FHDetailNeighborhoodDataBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHDetailNeighborhoodPropertyItemView *itemView = [[FHDetailNeighborhoodPropertyItemView alloc] init];
            [self.containerView addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(itemsCount * vHeight);
                make.left.right.mas_equalTo(self.containerView);
                make.height.mas_equalTo(vHeight);
            }];
            itemView.keyLabel.text = obj.attr;
            itemView.valueLabel.text = obj.value;
            itemsCount += 1;
        }];
        
    }
    // > 4 添加折叠展开
    if (model.baseInfo.count > 4) {
        if (_foldButton) {
            [_foldButton removeFromSuperview];
            _foldButton = nil;
        }
        _foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部信息" upText:@"收起" isFold:YES];
        [self.contentView addSubview:_foldButton];
        [_foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView.mas_bottom);
            make.height.mas_equalTo(58);
            make.left.right.mas_equalTo(self.contentView);
        }];
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView).offset(-58);
        }];
        [self.foldButton addTarget:self action:@selector(foldButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView).offset(-20);
        }];
    }
    [self updateItems:NO];
}

- (void)foldButtonClick:(UIButton *)button {
    FHDetailNeighborhoodPropertyInfoModel *model = (FHDetailNeighborhoodPropertyInfoModel *)self.currentData;
    model.isFold = !model.isFold;
    self.foldButton.isFold = model.isFold;
    [self updateItems:YES];
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
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"小区概况";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

- (void)updateItems:(BOOL)animated {
    FHDetailNeighborhoodPropertyInfoModel *model = (FHDetailNeighborhoodPropertyInfoModel *)self.currentData;
    if (model.baseInfo.count > 4) {
        if (animated) {
            [model.tableView beginUpdates];
        }
        if (model.isFold) {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(30 * 4);
            }];
        } else {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(30 * model.baseInfo.count);
            }];
        }
        [self setNeedsUpdateConstraints];
        if (animated) {
            [model.tableView endUpdates];
        }
    } else if (model.baseInfo.count > 0) {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30 * model.baseInfo.count);
        }];
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
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
    self.backgroundColor = UIColor.whiteColor;
    _keyLabel = [UILabel createLabel:@"" textColor:@"#8a9299" fontSize:14];
    [self addSubview:_keyLabel];
    [_keyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_keyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"#081f33" fontSize:14];
    [self addSubview:_valueLabel];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    
    // 布局
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(96);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.keyLabel);
    }];
}


@end
