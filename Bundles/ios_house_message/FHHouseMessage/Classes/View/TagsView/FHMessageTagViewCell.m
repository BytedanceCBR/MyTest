//
//  FHMessageTagViewCell.m
//  FHHouseMessage
//
//  Created by wangzhizhou on 2020/12/21.
//

#import "FHMessageTagViewCell.h"
#import <Masonry.h>
#import <ByteDanceKit.h>

#define CONTENT_PADDING_LEFT_RIGHT  4
#define CONTENT_PADDING_TOP_BOTTOM  1

@interface FHMessageTagViewCell()
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation FHMessageTagViewCell
+ (NSString *)reuseIdentifier {
    return NSStringFromClass(FHMessageTagViewCell.class);
}
- (void)updateWithTag:(FHMessageCellTagModel *)tag {
    self.nameLabel.text = tag.name;
    self.nameLabel.font = tag.font;
    self.nameLabel.textColor = tag.textColor;
    self.contentView.backgroundColor = tag.backgroundColor;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    
    // 计算tag标签尺寸
    CGSize labelSize = [self.nameLabel.text btd_sizeWithFont:self.nameLabel.font width:CGFLOAT_MAX maxLine:1];
    labelSize.width += 2 * CONTENT_PADDING_LEFT_RIGHT;
    labelSize.height+= 2 * CONTENT_PADDING_TOP_BOTTOM;
    
    // 设置圆角
    CGFloat cornerRadius = labelSize.height / 2.0f;
    self.contentView.layer.cornerRadius = cornerRadius;
    self.contentView.layer.masksToBounds = (cornerRadius > CGFLOAT_MIN);
    
    // 修改布局属性
    CGRect frame = attributes.frame;
    frame.size = labelSize;
    attributes.frame = frame;
    return attributes;
}

#pragma mark - 懒加载成员
- (UILabel *)nameLabel {
    if(!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}
@end
