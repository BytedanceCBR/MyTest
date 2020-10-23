//
//  FHNeighborhoodDetailPropertyInfoCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/12.
//

#import "FHNeighborhoodDetailPropertyInfoCollectionCell.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"
#import "FHDetailFoldViewButton.h"
#import <ByteDanceKit/ByteDanceKit.h>

static CGFloat const kFHPropertyItemInfoHeight = 30.0f;

@interface FHNeighborhoodDetailPropertyInfoCollectionCell ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong)   FHDetailFoldViewButton       *foldButton;
@property (nonatomic, strong)   UIView       *opView;// 半透明视图

@end

@implementation FHNeighborhoodDetailPropertyInfoCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (![data isKindOfClass:[FHNeighborhoodDetailPropertyInfoModel class]]) {
        return CGSizeZero;
    }
    FHNeighborhoodDetailPropertyInfoModel *model = (FHNeighborhoodDetailPropertyInfoModel *)data;
    CGFloat height = 0;
    NSInteger foldCount = 0;
    if (model.baseInfoFoldCount && model.baseInfoFoldCount.length > 0) {
        NSInteger value = [model.baseInfoFoldCount integerValue];
        if (value > 0) {
            foldCount = value;
        }
    }
    foldCount = MIN(foldCount, model.baseInfo.count);
    NSInteger baseInfoCount = model.isFold ? foldCount : model.baseInfo.count;
    height = baseInfoCount * kFHPropertyItemInfoHeight;
    
    if (model.baseInfo.count > foldCount) {
        height += 58;
    } else {
        height += 20;
    }
    
    return CGSizeMake(width, height);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.stackView = [[UIStackView alloc] init];
        self.stackView.axis = UILayoutConstraintAxisVertical;
        [self addSubview:self.stackView];
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.right.mas_offset(-15);
            make.top.mas_equalTo(self);
            make.bottom.mas_equalTo(-20);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    FHNeighborhoodDetailPropertyInfoModel *model = (FHNeighborhoodDetailPropertyInfoModel *)data;
    
    if (![data isKindOfClass:[FHNeighborhoodDetailPropertyInfoModel class]]) {
        return;
    }
    self.currentData = data;
    [self.stackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat stackViewHeight = 0;
    NSInteger foldCount = 0;
    if (model.baseInfoFoldCount && model.baseInfoFoldCount.length > 0) {
        NSInteger value = [model.baseInfoFoldCount integerValue];
        if (value > 0) {
            foldCount = value;
        }
    }
    foldCount = MIN(foldCount, model.baseInfo.count);
    NSInteger baseInfoCount = model.isFold ? foldCount : model.baseInfo.count;
    for (NSInteger i = 0; i < baseInfoCount; i++) {
        FHNeighborhoodDetailPropertyItemView *itemView = [[FHNeighborhoodDetailPropertyItemView alloc] init];
        [self.stackView addArrangedSubview:itemView];
        FHHouseBaseInfoModel *baseInfoModel = model.baseInfo[i];
        [itemView updateWithBaseInfoModel:baseInfoModel];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.stackView);
            make.height.mas_equalTo(kFHPropertyItemInfoHeight);
        }];
        stackViewHeight += kFHPropertyItemInfoHeight;
    }
    
    if (model.baseInfo.count > foldCount) {
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
        [self addSubview:_opView];
        [_opView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(53);
            make.left.right.mas_equalTo(self);
            make.top.mas_equalTo(self.stackView.mas_bottom).offset(-30);
        }];
        
        _foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部信息" upText:@"收起" isFold:YES];
        _foldButton.openImage = [UIImage imageNamed:@"message_more_arrow"];
        _foldButton.foldImage = [UIImage imageNamed:@"message_flod_arrow"];
        _foldButton.keyLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
        _foldButton.keyLabel.font = [UIFont themeFontRegular:14];
        [self addSubview:_foldButton];
        [_foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.stackView.mas_bottom);
            make.height.mas_equalTo(58);
            make.left.right.mas_equalTo(self);
        }];
        [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).offset(-58);
        }];
        __weak typeof(self) weakSelf = self;
        [self.foldButton btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.foldButtonActionBlock) {
                weakSelf.foldButtonActionBlock();
            }
        }];
        
    }
    
    [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(stackViewHeight);
    }];
    self.foldButton.isFold = model.isFold;
    if (model.isFold) {
        self.opView.hidden = NO;
    } else {
        self.opView.hidden = YES;
    }
}

- (void)bindViewModel:(id)viewModel {
    [self refreshWithData:viewModel];
}

@end

@implementation FHNeighborhoodDetailPropertyInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFold = YES;
    }
    return self;
}
- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

- (instancetype)transformFoldStatus {
    FHNeighborhoodDetailPropertyInfoModel *newInfoModel = [[FHNeighborhoodDetailPropertyInfoModel alloc] init];
    newInfoModel.baseInfo = self.baseInfo;
    newInfoModel.baseInfoFoldCount = self.baseInfoFoldCount;
    newInfoModel.isFold = !self.isFold;
    return newInfoModel;
}

@end

@implementation FHNeighborhoodDetailPropertyItemView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)updateWithBaseInfoModel:(FHHouseBaseInfoModel *)infoModel {
    self.keyLabel.text = infoModel.attr;
    self.valueLabel.text = infoModel.value;
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
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(5);
        make.height.mas_equalTo(20);
        make.width.mas_offset(56);
        make.bottom.mas_equalTo(self).offset(-5);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.keyLabel.mas_right).offset(12);
        make.top.mas_equalTo(5);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(-5);
        make.bottom.mas_equalTo(self.keyLabel);
    }];
}

@end
