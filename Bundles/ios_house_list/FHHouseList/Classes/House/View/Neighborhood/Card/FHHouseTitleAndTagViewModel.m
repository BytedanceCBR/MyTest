//
//  FHHouseTitleAndTagViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/11/11.
//

#import "FHHouseTitleAndTagViewModel.h"
#import "FHSearchHouseModel.h"
#import "FHHouseTagViewModel.h"
#import "NSString+BTDAdditions.h"
#import "UIFont+House.h"
#import "FHHouseTagView.h"
#import "FHCommonDefines.h"

@interface FHHouseTitleAndTagViewModel()
@property (nonatomic, strong) FHSearchHouseItemModel *model;
@end

@implementation FHHouseTitleAndTagViewModel
@synthesize attributedTitle = _attributedTitle;

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model {
    self = [super init];
    if (self) {
        _model = model;
        
        NSMutableArray *tags = [NSMutableArray array];
        for (FHSearchHouseItemTitleTagModel *tagModel in model.titleTags) {
            FHHouseTagViewModel *tagViewModel = [[FHHouseTagViewModel alloc] initWithModel:tagModel];
            [tags addObject:tagViewModel];
        }
        
        _tags = tags;
    }
    return self;
}

- (void)setMaxWidth:(CGFloat)maxWidth {
    _maxWidth = maxWidth;
    CGFloat width = 0;
    CGFloat index = 0;
    for (FHHouseTagViewModel *tagModel in self.tags) {
        CGFloat tagWidth = [tagModel tagWidth];
        CGFloat margin = (index == self.tags.count - 1) ? 4 : 2;
        if (width + tagWidth + margin > maxWidth) {
            tagModel.tagWidth = maxWidth - width - 4;
            break;
        }
        
        index++;
        width += (tagWidth + margin);
    }
    
    if (index < self.tags.count) {
        _tags = [self.tags subarrayWithRange:NSMakeRange(0, index)];
    }
}

- (UIFont *)titleFont {
    return [UIFont themeFontSemibold:16];
}

- (CGFloat)getTagTotalWidth {
    CGFloat left = 0;
    for (NSInteger index = 0; index < [self.tags count]; index++) {
        FHHouseTagViewModel *tagViewModel = self.tags[index];
        if (index > 0) {
            left += 2;
        }
        left += tagViewModel.tagWidth;
    }
    
    return left;
}

- (CGFloat)titleIndent {
    CGFloat indent = self.tags.count > 0 ? [self getTagTotalWidth] + 4 : 0;
    if (indent > self.maxWidth) indent = self.maxWidth;
    return indent;
}

- (NSParagraphStyle *)paragraphStyle {
    CGFloat indent = [self titleIndent];
    CGFloat lineHeight = self.titleFont.lineHeight;
    CGFloat lineHeightMultiple = lineHeight / self.titleFont.lineHeight;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.alignment = NSTextAlignmentLeft;
    style.lineHeightMultiple = lineHeightMultiple;
    style.minimumLineHeight = self.titleFont.lineHeight * lineHeightMultiple;
    style.maximumLineHeight = self.titleFont.lineHeight * lineHeightMultiple;
    style.firstLineHeadIndent = indent;
    return style;
}


- (NSAttributedString *)attributedTitle {
    if (!_attributedTitle) {
        NSString *title = self.model.displayTitle;
        if (title == nil) title = @"";
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:title];
        [attrStr addAttributes:@{NSFontAttributeName:self.titleFont, NSParagraphStyleAttributeName:[self paragraphStyle]} range:NSMakeRange(0, title.length)];
        _attributedTitle = attrStr;
    }
    
    return _attributedTitle;
}

- (CGFloat)showHeight {
    CGFloat lineHeight = self.titleFont.lineHeight;
    CGFloat indent = [self titleIndent];
    NSString *title = self.model.displayTitle;
    if (title == nil) title = @"";
    CGFloat titleWidth = [title btd_widthWithFont:[self titleFont] height:lineHeight];
    if (indent + titleWidth > self.maxWidth) {
        return lineHeight * 2 + 1;
    }
    
    return lineHeight;
}

@end
