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

@interface FHHouseTitleAndTagViewModel()
@property (nonatomic, strong) FHSearchHouseItemModel *model;
@end

@implementation FHHouseTitleAndTagViewModel
@synthesize attributedTitle = _attributedTitle;

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model {
    self = [super init];
    if (self) {
        {
//            NSMutableArray *tags = [NSMutableArray array];
//            {
//                FHSearchHouseItemTitleTagModel *tagModel = [[FHSearchHouseItemTitleTagModel alloc] init];
//                tagModel.isGradient = YES;
//                tagModel.text = @"小区测评";
//                tagModel.textColor = @"#ffffff";
//                tagModel.topBackgroundColor = @"#eeca99";
//                tagModel.bottomBackgroundColor = @"#dd9c43";
//                [tags addObject:tagModel];
//            }
//            
//            {
//                FHSearchHouseItemTitleTagModel *tagModel = [[FHSearchHouseItemTitleTagModel alloc] init];
//                tagModel.isGradient = YES;
//                tagModel.text = @"热";
//                tagModel.textColor = @"#ffffff";
//                tagModel.topBackgroundColor = @"#eeca99";
//                tagModel.bottomBackgroundColor = @"#dd9c43";
//                [tags addObject:tagModel];
//            }
//
//            model.titleTags = tags;
            
//            model.displayTitle = @"阿三开吉德津科撒的空间撒娇看到撒娇肯德基卡是贷记卡手机壳贷记卡圣诞节卡上就看到";
            
            
//            @property (nonatomic, assign) BOOL isGradient;
//            @property (nonatomic, copy , nullable) NSString *text;
//            @property (nonatomic, copy , nullable) NSString *textColor;
//            @property (nonatomic, copy , nullable) NSString *backgroundColor;
//            @property (nonatomic, copy , nullable) NSString *topBackgroundColor;
//            @property (nonatomic, copy , nullable) NSString *bottomBackgroundColor;
            
        }
        
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
    for (FHHouseTagViewModel *tagModel in self.tags) {
        tagModel.maxWidth = maxWidth;
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
    CGFloat indent = [self titleIndent];
    CGFloat lineHeight = self.titleFont.lineHeight;
    NSString *title = self.model.displayTitle;
    if (title == nil) title = @"";
    NSMutableParagraphStyle *style = [[self paragraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize size = [title boundingRectWithSize:CGSizeMake(self.maxWidth - indent, lineHeight * 2 + 1) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
        NSFontAttributeName:self.titleFont,
        NSParagraphStyleAttributeName:style,
    } context:nil].size;
    
    return MIN(ceil(size.height), lineHeight * 2 + 1);
}

@end
