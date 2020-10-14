//
//  FHNeighborhoodDetailQuickEntryCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHNeighborhoodDetailQuickEntryCollectionCell.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "ByteDanceKit/ByteDanceKit.h"

static CGFloat const FHNeighborhoodDetailQuickEntrySpaceing = 9.0f;

static NSInteger const FHNeighborhoodDetailQuickEntryCount = 5;

@interface FHNeighborhoodDetailQuickEntryCollectionCell ()

@property (nonatomic, strong) UIView *containerView;

@end

@implementation FHNeighborhoodDetailQuickEntryCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && ![data isKindOfClass:[FHNeighborhoodDetailQuickEntryModel class]]) {
        return CGSizeZero;
    }
    CGFloat height = 0;
    height += 15; //bottom
    NSInteger number = FHNeighborhoodDetailQuickEntryCount;
    
    CGFloat width2 = width;
    width2 -= 15 * 2; //左右间距
    
    width2 -= (number - 1) * FHNeighborhoodDetailQuickEntrySpaceing;
    width2 /= number;
    
    height += width2;
    
    return CGSizeMake(width, height);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *containerView = [[UIView alloc] init];
        [self.contentView addSubview:containerView];
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(15);
                    make.right.mas_equalTo(-15);
                    make.top.mas_equalTo(self.contentView);
                    make.bottom.mas_equalTo(-15);
        }];
        self.containerView = containerView;
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailQuickEntryModel class]]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.currentData = data;
    FHNeighborhoodDetailQuickEntryModel *model = (FHNeighborhoodDetailQuickEntryModel *)data;
    
    [self.containerView btd_removeAllSubviews];
    
    NSInteger number = FHNeighborhoodDetailQuickEntryCount;
    CGFloat width = self.contentView.frame.size.width;
    width -= 15 * 2; //左右间距
    
    width -= (number - 1) * FHNeighborhoodDetailQuickEntrySpaceing;
    width /= number;
    
    CGFloat left = 0;
    
    for (NSString *quickEntryName in model.quickEntryNames) {
        FHNeighborhoodDetailQuickEntryView *quickEntryView = [[FHNeighborhoodDetailQuickEntryView alloc] initWithFrame:CGRectMake(left, 0, width, width)];
        [quickEntryView updateWithQuickEntryName:quickEntryName];
        
        [quickEntryView btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.quickEntryClickBlock) {
                weakSelf.quickEntryClickBlock(quickEntryName);
            }
        }];
        [self.containerView addSubview:quickEntryView];
        left += width + FHNeighborhoodDetailQuickEntrySpaceing;
    }
}


@end

@implementation FHNeighborhoodDetailQuickEntryModel

- (void)clearUpQuickEntryNames {
    self.quickEntryNames = [NSArray array];
    if (self.gaodeLat.length > 0 && self.gaodeLng.length > 0 && self.baiduPanoramaUrl.length > 0) {
        self.quickEntryNames = @[@"地图",@"街景",@"教育",@"交通",@"生活"];
    } else if (self.gaodeLat.length > 0 && self.gaodeLng.length > 0){
        self.quickEntryNames = @[@"地图",@"教育",@"交通",@"生活",@"医疗"];
    } else
        if (self.baiduPanoramaUrl.length > 0 ){
        self.quickEntryNames = @[@"街景"];
    }
}

@end

@interface FHNeighborhoodDetailQuickEntryView ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation FHNeighborhoodDetailQuickEntryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexStr:@"#fafafa"];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        self.iconView = [[UIImageView alloc] init];
        [self addSubview:self.iconView];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(8);
                    make.left.mas_equalTo(16);
                    make.right.mas_equalTo(-16);
                    make.bottom.mas_equalTo(-24);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        
        self.nameLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont themeFontRegular:12];
        
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.iconView.mas_bottom).offset(2);
                    make.left.mas_equalTo(16);
                    make.right.mas_equalTo(-16);
                    make.bottom.mas_equalTo(-5);
        }];
        
    }
    return self;
}

- (void)updateWithQuickEntryName:(NSString *)quickEntryName {
    self.nameLabel.text = quickEntryName;
    self.iconView.image = [UIImage imageNamed:[self iconNameFromQucikEntryName:quickEntryName]];
}

- (NSString *)iconNameFromQucikEntryName:(NSString *)quickEntryName {
    if ([quickEntryName isEqualToString:@"地图"]) {
        return @"house_detail_quick_entry_map";
    }
    if ([quickEntryName isEqualToString:@"街景"]) {
        return @"house_detail_quick_entry_panorama";
    }
    if ([quickEntryName isEqualToString:@"教育"]) {
        return @"house_detail_quick_entry_education";
    }
    if ([quickEntryName isEqualToString:@"交通"]) {
        return @"house_detail_quick_entry_traffic";
    }
    if ([quickEntryName isEqualToString:@"生活"]) {
        return @"house_detail_quick_entry_life";
    }
    if ([quickEntryName isEqualToString:@"医疗"]) {
        return @"house_detail_quick_entry_hospital";
    }
    return @"house_detail_quick_entry_map";
}


@end
