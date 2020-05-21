//
//  FHDetailTagBackgroundView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/5/21.
//

#import "FHDetailTagBackgroundView.h"
#import "Masonry.h"
#import "FHHouseTagsModel.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"

#define kTagMargin 4;
@interface FHDetailTagBackgroundView ()
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong)   NSArray      *tags;
@property (nonatomic, assign)   NSUInteger   maxNum;
@property (nonatomic, assign)   NSUInteger   nowNum;
@property (nonatomic, assign)   CGFloat   left;
@property (nonatomic, assign)   CGFloat   maxLen;

@end



@implementation FHDetailTagBackgroundView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxNum = 0;
        _nowNum = 0;
        _left = 0.0;
        _maxLen = 0.0;
        _containerView = [UIView new];
        [self addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self);
        }];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)removeAllTag{
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    _maxNum = 0;
    _nowNum = 0;
    _left = 0.0;
    _maxLen = 0.0;
}

- (void)refreshWithTags:(NSArray *)tags withNum:(NSUInteger)num withmaxLen:(CGFloat)maxLen{
    _tags = tags;
    _maxNum = num;
    _maxLen = maxLen;
    _nowNum = 0;
    _left = 0.0;
    for (FHHouseTagsModel *tag in tags) {
        if (_nowNum >= _maxNum) {
            break;
        }
        UILabel *tagLabel = [self createLabelWithText:tag.content bacColor:tag.backgroundColor textColor:tag.textColor];
        CGFloat width = [self getLabelWidth:tagLabel withHeight:16.0];
        if (_left + width > maxLen) {
            continue;
        }
        [self.containerView addSubview:tagLabel];
        [tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.left);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(16.0);
            make.top.mas_equalTo(0);
        }];
        
        _left += width + kTagMargin;
        _nowNum ++;
    }
    [self layoutIfNeeded];
}

- (UILabel *)createLabelWithText:(NSString *)text bacColor:(NSString *)bacStr textColor:(NSString *)textStr {
    UIColor *tagBacColor = [UIColor colorWithHexString:bacStr];
    UIColor *tagTextColor = [UIColor colorWithHexString:textStr];
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = tagBacColor;
    label.textColor = tagTextColor;
    label.layer.cornerRadius = 2;
    label.layer.masksToBounds = YES;
    label.text = text;
    label.font = [UIFont themeFontMedium:10];
    return label;
}

- (CGFloat)getLabelWidth:(UILabel *)label withHeight:(CGFloat)height {
    [label sizeToFit];
    CGSize itemSize = [label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, height)];
    return itemSize.width + 2 * kTagMargin;
}


@end
