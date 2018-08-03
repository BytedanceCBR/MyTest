//
//  WDListQuestionHeaderCollectionTagCell.m
//  Article
//
//  Created by 延晋 张 on 16/8/23.
//
//

#import "WDListQuestionHeaderCollectionTagCell.h"
#import "WDQuestionEntity.h"
#import "WDQuestionTagEntity.h"
#import "WDListViewModel.h"
#import "SSThemed.h"

@interface WDListQuestionHeaderCollectionTagCell ()

@property (nonatomic, strong) SSThemedLabel *tagLabel;

@property (nonatomic, strong) WDQuestionTagEntity *tagEntity;

@end

@implementation WDListQuestionHeaderCollectionTagCell

- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.tagLabel];
    }
    return self;
}

#pragma mark - Public Methods

- (void)refreshCellWithTagEntity:(WDQuestionTagEntity *)tagEntity
{
    self.tagEntity = tagEntity;
    self.tagLabel.text = tagEntity.name;
    [self.tagLabel sizeToFit];
    self.tagLabel.frame = [self frameForConcernLabel];
}

+ (CGFloat)collectionCellWidthWithName:(NSString *)name {
    CGSize size = [name sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]}];
    return ceilf(size.width) + 2 * 10;
}

#pragma mark - frame

- (CGRect)frameForConcernLabel
{
    return CGRectMake(0, 0.0f, SSWidth(self.tagLabel) + 2 * 10, SSHeight(self));
}

#pragma mark - getter

- (SSThemedLabel *)tagLabel
{
    if (!_tagLabel) {
        _tagLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _tagLabel.font = [UIFont systemFontOfSize:12.0f];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.clipsToBounds = YES;
        _tagLabel.layer.cornerRadius = 4.0f;
        _tagLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _tagLabel.borderColorThemeKey = kColorLine1;
        _tagLabel.textColorThemeKey = kColorText1;
        _tagLabel.backgroundColorThemeKey = kColorBackground3;
    }
    return _tagLabel;
}

@end
