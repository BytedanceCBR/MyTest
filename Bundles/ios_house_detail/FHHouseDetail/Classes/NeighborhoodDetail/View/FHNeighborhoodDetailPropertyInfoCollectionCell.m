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
@property (nonatomic, strong) UIButton *allButton;

@end

@implementation FHNeighborhoodDetailPropertyInfoCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (![data isKindOfClass:[FHNeighborhoodDetailPropertyInfoModel class]]) {
        return CGSizeZero;
    }
    FHNeighborhoodDetailPropertyInfoModel *model = (FHNeighborhoodDetailPropertyInfoModel *)data;
    CGFloat height = 0;
    NSInteger foldCount = 3;
    foldCount = MIN(foldCount, model.baseInfo.count);
    height = foldCount * kFHPropertyItemInfoHeight;
    height += 60;
//    NSInteger foldCount = 0;
//    if (model.baseInfoFoldCount && model.baseInfoFoldCount.length > 0) {
//        NSInteger value = [model.baseInfoFoldCount integerValue];
//        if (value > 0) {
//            foldCount = value;
//        }
//    }
//    foldCount = MIN(foldCount, model.baseInfo.count);
//    NSInteger baseInfoCount = model.isFold ? foldCount : model.baseInfo.count;
//    height = baseInfoCount * kFHPropertyItemInfoHeight;
//
//    if (model.baseInfo.count > foldCount) {
//        height += 58;
//    } else {
//        height += 20;
//    }
    
    return CGSizeMake(width, height);
}

- (NSString *)elementType {
    return @"neighborhood_info";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.stackView = [[UIStackView alloc] init];
        self.stackView.axis = UILayoutConstraintAxisVertical;
        [self addSubview:self.stackView];
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(12);
            make.right.mas_offset(-12);
            make.top.mas_equalTo(self);
            make.height.mas_equalTo(kFHPropertyItemInfoHeight * 3);
        }];
        
        __weak typeof(self) weakSelf = self;
        self.allButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.allButton.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
        self.allButton.titleLabel.font = [UIFont themeFontRegular:16];
        [self.allButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        self.allButton.layer.masksToBounds = YES;
        self.allButton.layer.cornerRadius = 4.0;
        [self.allButton setTitle:@"查看全部信息" forState:UIControlStateNormal];
        [self.allButton setImage:[UIImage imageNamed:@"neighbor_detail_arrow_right"] forState:UIControlStateNormal];
        [self.allButton btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.allButtonActionBlock) {
                weakSelf.allButtonActionBlock();
            }
        }];
        [self addSubview:self.allButton];
        [self.allButton sizeToFit];
        self.allButton.titleEdgeInsets = UIEdgeInsetsMake(0, -self.allButton.imageView.bounds.size.width, 0, self.allButton.imageView.bounds.size.width);
        self.allButton.imageEdgeInsets = UIEdgeInsetsMake(0, self.allButton.titleLabel.bounds.size.width + 4, 0, -self.allButton.titleLabel.bounds.size.width);
        [self.allButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.stackView.mas_bottom).mas_offset(8);
            make.height.mas_equalTo(40);
            make.left.mas_equalTo(12);
            make.right.mas_equalTo(-12);
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
    NSInteger foldCount = 3;
    foldCount = MIN(foldCount, model.baseInfo.count);
//    NSInteger baseInfoCount = model.isFold ? foldCount : model.baseInfo.count;
    for (NSInteger i = 0; i < foldCount; i++) {
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
    [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(stackViewHeight);
    }];
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
//        _isFold = YES;
    }
    return self;
}
- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

//- (instancetype)transformFoldStatus {
//    FHNeighborhoodDetailPropertyInfoModel *newInfoModel = [[FHNeighborhoodDetailPropertyInfoModel alloc] init];
//    newInfoModel.baseInfo = self.baseInfo;
//    newInfoModel.baseInfoFoldCount = self.baseInfoFoldCount;
//    newInfoModel.isFold = !self.isFold;
//    return newInfoModel;
//}

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
    _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _keyLabel.textColor = [UIColor themeGray3];
    [self addSubview:_keyLabel];
    [_keyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_keyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _valueLabel.textColor = [UIColor themeGray1];
    [self addSubview:_valueLabel];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    // 布局
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(22);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(-5);
    }];
}

@end
