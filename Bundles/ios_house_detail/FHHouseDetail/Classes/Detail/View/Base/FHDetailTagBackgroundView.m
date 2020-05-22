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

@interface FHDetailTagBackgroundView ()
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong)   NSArray      *tags;
@property (nonatomic, assign)   NSUInteger   maxNum,nowNum;
@property (nonatomic, assign)   CGFloat      left,maxLen;

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
        _tagMargin = 4.0;
        _insideMargin = 4.0;
        _labelHeight = 16.0;
        _cornerRadius = 2.0;
        _textFont = [UIFont themeFontMedium:10];
        _containerView = [UIView new];
        [self addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self);
        }];
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)initWithLabelHeight:(CGFloat)labelHeight withCornerRadius:(CGFloat)cornerRadius {
    
    self = [self init];
    if (self) {
        self.labelHeight = labelHeight;
        self.cornerRadius = cornerRadius;
    }
    return self;
}

- (void)setMarginWithTagMargin:(CGFloat)tagMargin withInsideMargin:(CGFloat)insideMargin {
    self.tagMargin = tagMargin;
    self.insideMargin = insideMargin;
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
        CGFloat width = [self getLabelWidth:tagLabel];
        if (_left + width > maxLen) {
            continue;
        }
        [self.containerView addSubview:tagLabel];
        [tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.left);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(self.labelHeight);
            make.top.mas_equalTo(0);
        }];
        
        _left += width + _tagMargin;
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
    label.layer.cornerRadius = _cornerRadius;
    label.layer.masksToBounds = YES;
    label.text = text;
    label.font = _textFont;
    return label;
}

- (CGFloat)getLabelWidth:(UILabel *)label {
    [label sizeToFit];
    CGSize itemSize = [label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, _textFont.lineHeight)];
    return itemSize.width + 2 * _insideMargin;
}


@end
