//
// Created by zhulijun on 2019-07-17.
//

#import "FHUGCCommunityDistrictTabCell.h"

@interface FHUGCCommunityDistrictTabCell ()

@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation FHUGCCommunityDistrictTabModel
@end

@implementation FHUGCCommunityDistrictTabCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstraints];
    }
    return self;
}

- (void)initView {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;

    [self.contentView addSubview:self.titleLabel];
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(64 + 1);
        make.center.mas_equalTo(self.contentView);
        make.height.mas_greaterThanOrEqualTo(22);
    }];
}

- (void)setTitle:(BOOL)isSelected title:(NSString *)title {
    if (isEmptyString(title)) {
        return;
    }
    CGFloat labelWidth = isSelected ? 80.0 : 64.0;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth);
    }];
    self.titleLabel.text = title;
    self.titleLabel.font = isSelected ? [UIFont themeFontSemibold:20.0f] : [UIFont themeFontRegular:16.0f];
    self.titleLabel.textColor = isSelected ? [UIColor themeOrange1] : [UIColor themeGray1];
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHUGCCommunityDistrictTabModel class]]) {
        return;
    }
    self.currentData = data;
    FHUGCCommunityDistrictTabModel *itemModel = (FHUGCCommunityDistrictTabModel *) data;
    [self setTitle:[itemModel isSelected] title:itemModel.title];
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    CGRect cellFrame = layoutAttributes.frame;
    cellFrame.size.height = 54.0f;
    layoutAttributes.frame = cellFrame;
    return layoutAttributes;
}

@end
