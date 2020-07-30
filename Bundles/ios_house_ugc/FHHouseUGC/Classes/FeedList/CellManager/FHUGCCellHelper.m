//
//  FHUGCCellHelper.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/6.
//

#import "FHUGCCellHelper.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTVFeedListItem.h"
#import "TTVFeedCellAction.h"
#import "TTRichSpanText+Comment.h"
#import "YYText.h"
#import "TTRichSpanText+Link.h"
#import "TTUGCEmojiParser.h"
#import "TTUGCTextRender.h"
#import <BDWebImage/UIImageView+BDWebImage.h>

@implementation FHUGCCellHelper

//...全文处理
+ (NSAttributedString *)truncationFont:(UIFont *)font contentColor:(UIColor *)contentColor color:(UIColor *)color {
    NSString * moreStr = NSLocalizedString(@"...全文", nil);
    NSMutableDictionary * attrDic = @{}.mutableCopy;
    if (font) {
        [attrDic setValue:font forKey:NSFontAttributeName];
    }
    if (color) {
        [attrDic setValue:color forKey:NSForegroundColorAttributeName];
    }
    NSMutableAttributedString * truncationString = [[NSMutableAttributedString alloc] initWithString:moreStr attributes:attrDic];
    // TODO 其实这里使用了错误的方式来修复点击无效的 bug，暂且如此
    [truncationString addAttribute:NSLinkAttributeName  // 修复点击问题的bug 强制加一个无用action
                             value:[NSURL URLWithString:defaultTruncationLinkURLString]
                             range:NSMakeRange(0, moreStr.length)];
    if (contentColor) {
        [truncationString addAttribute:NSForegroundColorAttributeName value:contentColor range:NSMakeRange(0, @"...".length)];
    }
    return truncationString.copy;
}

+ (void)setRichContent:(TTUGCAttributedLabel *)label model:(FHFeedUGCCellModel *)model numberOfLines:(NSInteger)numberOfLines {
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:model.contentRichSpan];
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:model.content richSpans:richSpans];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    if (!isEmptyString(model.title)) {
        [threadContent appendText:[NSString stringWithFormat:@"【%@】",model.title]];
    }
    if (!isEmptyString(model.content)) {
        [threadContent appendRichSpanText:richContent];
    }
    
    if (!isEmptyString(threadContent.text)) {
        NSInteger parseEmojiCount = -1;
        if (numberOfLines > 0) {
            parseEmojiCount = (100 * (numberOfLines + 1));// 只需解析这么多，其他解析无用~~
        }
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:threadContent.text fontSize:15 needParseCount:parseEmojiCount];
        if (attrStr) {
            CGFloat fontSize = 16.0f;
            UIFont *font = [UIFont themeFontRegular:fontSize];
            CGFloat lineHeight = ceil(fontSize * 1.4);
            
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
            paragraphStyle.minimumLineHeight = lineHeight;
            paragraphStyle.maximumLineHeight = lineHeight;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            //内容
            label.numberOfLines = numberOfLines;
            [label setText:mutableAttributedString];
            if(model.showLookMore){
                label.attributedTruncationToken = [FHUGCCellHelper truncationFont:[attributes objectForKey:NSFontAttributeName]
                                                                 contentColor:attributes[NSForegroundColorAttributeName]
                                                                        color:[UIColor themeRed3]];
            }
        }
    }
}

+ (void)setRichContent:(TTUGCAttributedLabel *)label content:(NSString *)content font:(UIFont *)font numberOfLines:(NSInteger)numberOfLines color:(UIColor *)color {
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:content richSpans:nil];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    if (!isEmptyString(content)) {
        [threadContent appendRichSpanText:richContent];
    }
    
    if (!isEmptyString(threadContent.text)) {
        NSInteger parseEmojiCount = -1;
        if (numberOfLines > 0) {
            parseEmojiCount = (100 * (numberOfLines + 1));// 只需解析这么多，其他解析无用~~
        }
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:threadContent.text fontSize:(font.pointSize - 2) needParseCount:parseEmojiCount];
        if (attrStr) {
            CGFloat lineHeight = ceil(font.pointSize * 1.4);
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:color forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            if(numberOfLines != 1){
                NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.minimumLineHeight = lineHeight;
                paragraphStyle.maximumLineHeight = lineHeight;
                paragraphStyle.lineSpacing = 2;
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            }
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            //内容
            label.numberOfLines = numberOfLines;
            [label setText:mutableAttributedString];
        }
    }
}


+ (void)setRichContentImageWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:model.contentRichSpan];
    TTRichSpanText *richContent = [[[TTRichSpanText alloc] initWithText:model.content richSpans:richSpans] replaceWhitelistLinks];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    model.richContent = richContent;
    
    if (!isEmptyString(model.title)) {
        [threadContent appendText:[NSString stringWithFormat:@"【%@】",model.title]];
    }
    if (!isEmptyString(model.content)) {
        [threadContent appendRichSpanText:richContent];
    }
    
    if (!isEmptyString(threadContent.text)) {
       __block NSAttributedString *att;
        if (model.user.avatarUrl) {
            [[BDWebImageManager sharedManager] requestImage:model.user.avatarUrl options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
                if (!error && image) {
                              NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
                              attachment.bounds = CGRectMake(0, -5, 20, 20);
                              attachment.image = [self circleImage:image];
                              att = [NSAttributedString attributedStringWithAttachment:attachment];
                }
                CGFloat lineHeight = ceil(16 * 1.4);
                NSMutableAttributedString *userAttrStr = [att mutableCopy];;
                if (model.user.name) {
                    NSAttributedString *as = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@说：",model.user.name]];
                    [userAttrStr appendAttributedString:as];
                    NSMutableDictionary *attributes = @{}.mutableCopy;
                    [attributes setValue:[UIColor themeGray2] forKey:NSForegroundColorAttributeName];
                    [attributes setValue:[UIFont themeFontSemibold:14] forKey:NSFontAttributeName];
                    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                    paragraphStyle.minimumLineHeight = lineHeight;
                    paragraphStyle.maximumLineHeight = lineHeight;
                    paragraphStyle.lineSpacing = 2;
                    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
                    [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
                    [userAttrStr addAttributes:attributes range:NSMakeRange(0, userAttrStr.length)];
                }
                
                NSAttributedString *attrStr = [TTUGCEmojiParser parseInTextKitContext:threadContent.text fontSize:16 topAdjust:1.5];
                if (attrStr) {
                    NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
                    NSMutableDictionary *attributes = @{}.mutableCopy;
                    [attributes setValue:[UIColor themeGray2] forKey:NSForegroundColorAttributeName];
                    [attributes setValue:[UIFont themeFontRegular:14]  forKey:NSFontAttributeName];

                    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                    
                    paragraphStyle.minimumLineHeight = lineHeight;
                    paragraphStyle.maximumLineHeight = lineHeight;
                    paragraphStyle.lineSpacing = 2;
                    
                    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
                    [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
                    
                    [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
                    
                    if (userAttrStr) {
                        [mutableAttributedString insertAttributedString:userAttrStr atIndex:0];
                    }
                    
                    model.contentAStr = mutableAttributedString;
                    
                    CGSize size = [self sizeThatFitsAsyncAttributedString:mutableAttributedString
                                                                      withConstraints:CGSizeMake(width, FLT_MAX)
                                                                     maxNumberOfLines:numberOfLines
                                                               limitedToNumberOfLines:&numberOfLines];
                    model.contentHeight = size.height;
                }
            }];
        }
    }else{
        model.contentHeight = 0;
    }
}

+ (void)setRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:model.contentRichSpan];
    TTRichSpanText *richContent = [[[TTRichSpanText alloc] initWithText:model.content richSpans:richSpans] replaceWhitelistLinks];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    model.richContent = richContent;
    
    if (!isEmptyString(model.title)) {
        [threadContent appendText:[NSString stringWithFormat:@"【%@】",model.title]];
    }
    if (!isEmptyString(model.content)) {
        [threadContent appendRichSpanText:richContent];
    }
    
    if (!isEmptyString(threadContent.text)) {
        
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInTextKitContext:threadContent.text fontSize:16 topAdjust:1.5];
        
        if (attrStr) {
            CGFloat fontSize = 16.0f;
            UIFont *font = [UIFont themeFontRegular:fontSize];
            CGFloat lineHeight = ceil(fontSize * 1.4);
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            paragraphStyle.minimumLineHeight = lineHeight;
            paragraphStyle.maximumLineHeight = lineHeight;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            model.contentAStr = mutableAttributedString;
            
            CGSize size = [self sizeThatFitsAsyncAttributedString:mutableAttributedString
                                                              withConstraints:CGSizeMake(width, FLT_MAX)
                                                             maxNumberOfLines:numberOfLines
                                                       limitedToNumberOfLines:&numberOfLines];
            model.contentHeight = size.height;
        }
    }else{
        model.contentHeight = 0;
    }
}

+ (void)setArticleRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width {
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:model.contentRichSpan];
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:model.title richSpans:richSpans];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    if (!isEmptyString(model.title)) {
        [threadContent appendRichSpanText:richContent];
    }
    
    if (!isEmptyString(threadContent.text)) {
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInTextKitContext:threadContent.text fontSize:16 topAdjust:1.5];
        
        if (attrStr) {
            CGFloat fontSize = 16.0f;
            UIFont *font = [UIFont themeFontRegular:fontSize];
            CGFloat lineHeight = ceil(fontSize * 1.4);

            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            paragraphStyle.minimumLineHeight = lineHeight;
            paragraphStyle.maximumLineHeight = lineHeight;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            model.contentAStr = mutableAttributedString;
            
            NSInteger numberOfLines = model.numberOfLines;
            
            CGSize size = [self sizeThatFitsAsyncAttributedString:mutableAttributedString
                                             withConstraints:CGSizeMake(width, FLT_MAX)
                                            maxNumberOfLines:numberOfLines
                                      limitedToNumberOfLines:&numberOfLines];
            model.contentHeight = size.height;
        }
    }else{
        model.contentHeight = 0;
    }
}

+ (void)setRichContent:(TTUGCAttributedLabel *)label model:(FHFeedUGCCellModel *)model {
    //内容
    [label setText:model.contentAStr];
    if(model.showLookMore){
        label.attributedTruncationToken = [FHUGCCellHelper truncationFont:[UIFont themeFontRegular:16]
                                                             contentColor:[UIColor themeGray1]
                                                                    color:[UIColor themeRed3]];
    }
    
    if(model.needLinkSpan && model.richContent){
        NSArray <TTRichSpanLink *> *richSpanLinks = [model.richContent richSpanLinksOfAttributedString];
        for (TTRichSpanLink *richSpanLink in richSpanLinks) {
            NSRange range = NSMakeRange(richSpanLink.start, richSpanLink.length);
            if (NSMaxRange(range) <= label.attributedText.length) {
                if(model.supportedLinkType){
                    if(model.supportedLinkType.count > 0 && [model.supportedLinkType containsObject:@(richSpanLink.type)]){
                        [label addLinkToURL:[NSURL URLWithString:richSpanLink.link] withRange:range];
                    }
                }else{
                    //不设置默认全部支持
                    [label addLinkToURL:[NSURL URLWithString:richSpanLink.link] withRange:range];
                }
            }
        }
    }
}

+ (void)setAsyncRichContent:(TTUGCAsyncLabel *)label model:(FHFeedUGCCellModel *)model {
    //内容
    TTUGCTextRender *textRender = [[TTUGCTextRender alloc] initWithAttributedText:model.contentAStr];
    textRender.maximumNumberOfLines = model.numberOfLines;
    textRender.font = [UIFont themeFontRegular:16];
    if(model.showLookMore){
        textRender.truncatedToken = [FHUGCCellHelper truncationFont:[UIFont themeFontRegular:16]
                                                       contentColor:[UIColor themeGray1]
                                                              color:[UIColor themeRed3]];
    }
    
    NSMutableArray *linkModels = [NSMutableArray array];
    if(model.needLinkSpan && model.richContent){
        NSArray <TTRichSpanLink *> *richSpanLinks = [model.richContent richSpanLinksOfAttributedString];
        for (TTRichSpanLink *richSpanLink in richSpanLinks) {
            NSRange range = NSMakeRange(richSpanLink.start, richSpanLink.length);
            UIColor *linkColor = [UIColor themeRed3];
            if (range.location + range.length <= model.contentAStr.length) {
                if(model.supportedLinkType){
                    if(model.supportedLinkType.count > 0 && [model.supportedLinkType containsObject:@(richSpanLink.type)]){
                        NSTextCheckingResult *checkingResult = [NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:richSpanLink.link]];
                        TTUGCAsyncLabelLink *link =
                        [[TTUGCAsyncLabelLink alloc] initWithAttributes:linkColor ? @{NSForegroundColorAttributeName : linkColor} : nil
                                                     textCheckingResult:checkingResult];
                        link.linkURL = [NSURL URLWithString:richSpanLink.link];//非图片的都可以这么用。
                        [linkModels addObject:link];
                    }
                }else{
                    //不设置默认全部支持
                    NSTextCheckingResult *checkingResult = [NSTextCheckingResult transitInformationCheckingResultWithRange:range components:@{}];
                    TTUGCAsyncLabelLink *link =
                    [[TTUGCAsyncLabelLink alloc] initWithAttributes:linkColor ? @{NSForegroundColorAttributeName : linkColor} : nil
                                                 textCheckingResult:checkingResult];
                    link.linkURL = [NSURL URLWithString:richSpanLink.link];//非图片的都可以这么用。
                    [linkModels addObject:link];
                }
            }
        }
    }
    
    [textRender addLinks:linkModels];
    label.textRender = textRender;
}

+ (void)setOriginRichContent:(TTUGCAsyncLabel *)label model:(FHFeedUGCCellModel *)model numberOfLines:(NSInteger)numberOfLines  {
    TTUGCTextRender *textRender = [[TTUGCTextRender alloc] initWithAttributedText:model.originItemModel.contentAStr];
    textRender.maximumNumberOfLines = numberOfLines;
    textRender.font = [UIFont themeFontRegular:16];
        
    NSMutableArray *linkModels = [NSMutableArray array];
    if(model.needLinkSpan && model.richContent){
        NSArray <TTRichSpanLink *> *richSpanLinks = [model.originItemModel.richContent richSpanLinksOfAttributedString];
        for (TTRichSpanLink *richSpanLink in richSpanLinks) {
            NSRange range = NSMakeRange(richSpanLink.start, richSpanLink.length);
            UIColor *linkColor = [UIColor themeRed3];
            if (range.location + range.length <= model.originItemModel.contentAStr.length) {
                if(model.supportedLinkType){
                    if(model.supportedLinkType.count > 0 && [model.supportedLinkType containsObject:@(richSpanLink.type)]){
                        NSTextCheckingResult *checkingResult = [NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:richSpanLink.link]];
                        TTUGCAsyncLabelLink *link =
                        [[TTUGCAsyncLabelLink alloc] initWithAttributes:linkColor ? @{NSForegroundColorAttributeName : linkColor} : nil
                                                     textCheckingResult:checkingResult];
                        link.linkURL = [NSURL URLWithString:richSpanLink.link];//非图片的都可以这么用。
                        [linkModels addObject:link];
                    }
                }else{
                    //不设置默认全部支持
                    NSTextCheckingResult *checkingResult = [NSTextCheckingResult transitInformationCheckingResultWithRange:range components:@{}];
                    TTUGCAsyncLabelLink *link =
                    [[TTUGCAsyncLabelLink alloc] initWithAttributes:linkColor ? @{NSForegroundColorAttributeName : linkColor} : nil
                                                 textCheckingResult:checkingResult];
                    link.linkURL = [NSURL URLWithString:richSpanLink.link];//非图片的都可以这么用。
                    [linkModels addObject:link];
                }
            }
        }
    }
    
    [textRender addLinks:linkModels];
    label.textRender = textRender;
}

+ (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attrStr
                       withConstraints:(CGSize)size
                      maxNumberOfLines:(NSUInteger)maxLine
                limitedToNumberOfLines:(NSUInteger*)numberOfLines {
    long lines = [TTUGCAttributedLabel numberOfLinesAttributedString:attrStr withConstraints:size.width];
    
    if (lines <= maxLine) { //用最大行数能显示全，就用最大行数显示
        *numberOfLines = maxLine;
    }
    
    return [TTUGCAttributedLabel sizeThatFitsAttributedString:attrStr
                                              withConstraints:CGSizeMake(size.width, FLT_MAX)
                                       limitedToNumberOfLines:*numberOfLines];
}

+ (CGSize)sizeThatFitsAsyncAttributedString:(NSAttributedString *)attrStr
                       withConstraints:(CGSize)size
                      maxNumberOfLines:(NSUInteger)maxLine
                limitedToNumberOfLines:(NSUInteger*)numberOfLines {
    long lines = [TTUGCTextRender numberOfLinesAttributedString:attrStr constraintsWidth:size.width];
    
    if (lines <= maxLine) { //用最大行数能显示全，就用最大行数显示
        *numberOfLines = maxLine;
    }

    return [TTUGCTextRender sizeThatFitsAttributedString:attrStr
                                         constraintsSize:CGSizeMake(size.width, CGFLOAT_MAX)
                                  limitedToNumberOfLines:*numberOfLines];;
}

//问答回答和文章优质评论
+ (void)setOriginContentAttributeString:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    NSString *type = model.originItemModel.type;
    //这里是为了将[类型]占的位置给加出来
    NSDictionary *richSpansDic = nil;
    NSError *error;
    if(!isEmptyString(model.originItemModel.contentRichSpan) && type.length > 0){
        NSData *data = [model.originItemModel.contentRichSpan dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            richSpansDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        }
    }
    
    NSMutableDictionary *richSpansDicM = [richSpansDic mutableCopy];
    NSMutableArray *links = [richSpansDicM[@"links"] mutableCopy];
    for (NSInteger i = 0; i < links.count; i++) {
        NSMutableDictionary *linkM = [links[i] mutableCopy];
        linkM[@"start"] = @([linkM[@"start"] integerValue] + type.length);
        links[i] = linkM;
    }
    richSpansDicM[@"links"] = links;
    
    NSMutableString *text = [NSMutableString string];
    if(!isEmptyString(type)){
        [text appendString:type];
    }
    
    if(!isEmptyString(model.originItemModel.content)){
        [text appendString:model.originItemModel.content];
    }
    
    TTRichSpans *richSpans = [TTRichSpans richSpansForDictionary:richSpansDicM];
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:text richSpans:richSpans];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    model.originItemModel.richContent = richContent;
    
    if (!isEmptyString(text)) {
        [threadContent appendRichSpanText:richContent];
        
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInTextKitContext:threadContent.text fontSize:16 topAdjust:1.5];
        if (attrStr) {
            CGFloat fontSize = 16.0f;
            UIFont *font = [UIFont themeFontRegular:fontSize];
            CGFloat lineHeight = ceil(fontSize * 1.4);
            
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];

            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray2] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            paragraphStyle.minimumLineHeight = lineHeight;
            paragraphStyle.maximumLineHeight = lineHeight;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            //类型
            NSMutableDictionary *typeAttributes = @{}.mutableCopy;
            [typeAttributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [typeAttributes setValue:[UIFont themeFontMedium:16] forKey:NSFontAttributeName];
            [typeAttributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            if(type.length > 0){
                [mutableAttributedString addAttributes:typeAttributes range:NSMakeRange(0, type.length)];
            }
            
            if(attrStr.length > type.length){
                [mutableAttributedString addAttributes:attributes range:NSMakeRange(type.length, attrStr.length - type.length)];
            }

            model.originItemModel.contentAStr = mutableAttributedString;
            
            CGSize size = [self sizeThatFitsAsyncAttributedString:mutableAttributedString
                                             withConstraints:CGSizeMake(width, FLT_MAX)
                                            maxNumberOfLines:numberOfLines
                                      limitedToNumberOfLines:&numberOfLines];
            model.originItemHeight = size.height + 30;
        }
    }else{
        model.originItemHeight = 0;
    }
}

+ (NSAttributedString *)typeAttr:(FHFeedUGCCellModel *)model {
    NSString *type = model.originItemModel.type;
    if (type.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:type];
    [attri addAttribute:NSForegroundColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, type.length)];
    [attri addAttribute:NSFontAttributeName value:[UIFont themeFontMedium:16] range:NSMakeRange(0, type.length)];
    return attri;
}

+ (NSAttributedString *)contentAttr:(FHFeedUGCCellModel *)model {
    NSString *content = model.originItemModel.content;
    if (content.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:content];
    [attri addAttribute:NSForegroundColorAttributeName value:[UIColor themeGray2] range:NSMakeRange(0, content.length)];
    [attri addAttribute:NSFontAttributeName value:[UIFont themeFontRegular:16] range:NSMakeRange(0, content.length)];
    return attri;
}

+ (void)setVoteContentString:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    if(!isEmptyString(model.vote.content)){
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = numberOfLines;
        label.font = [UIFont themeFontMedium:16];
        //设置字间距0.4
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:model.vote.content attributes:@{NSKernAttributeName:@(0.4)}];
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        [paragraphStyle setLineSpacing:0.4];
//        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [model.vote.content length])];
        label.attributedText = attributedString;
        
        CGSize size = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        model.vote.contentAStr = attributedString;
        model.vote.contentHeight = size.height;
    }else{
        model.vote.contentHeight = 0;
        model.vote.contentAStr = nil;
    }
}

+ (void)setUGCVoteContentString:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    if(!isEmptyString(model.voteInfo.title)){
        //设置字间距0.4
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:model.voteInfo.title attributes:@{NSForegroundColorAttributeName : [UIColor themeGray1],NSFontAttributeName : [UIFont themeFontRegular:16]}];
        
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(width, MAXFLOAT) text:attributedString];
        CGFloat height = layout.textBoundingSize.height;
        // 下面这种方法对系统表情计算高度兼容性不好，用YYTextLayout吧
        if (numberOfLines == 2) {
            if (height >= 45) {
                // 说明是两行
                height = 53;// 两行
            }
        }
        model.voteInfo.contentAStr = attributedString;
        model.voteInfo.contentHeight = height;
    }else{
        model.voteInfo.contentHeight = 0;
        model.voteInfo.contentAStr = nil;
    }
}

+ (TTVFeedListItem *)configureVideoItem:(FHFeedUGCCellModel *)cellModel {
    TTVFeedListItem *item = [[TTVFeedListItem alloc] init];
    item.originData = cellModel.videoFeedItem;
    item.categoryId = cellModel.categoryId;
    item.hideTitleAndWatchCount = YES;
    item.refer = 1;

    item.cellAction = [[TTVFeedCellVideoAction alloc] init];
    item.isFirstCached = NO;
    item.followedWhenInit = NO;

    NSInteger playTimes = [cellModel.videoDetailInfo.videoWatchCount integerValue];
    item.playTimes = [[TTBusinessManager formatPlayCount:playTimes] stringByAppendingString:@"次播放"];
    NSString *durationText = nil;
    int64_t duration = cellModel.videoDuration;
    if (duration > 0) {
        int minute = (int)duration / 60;
        int second = (int)duration % 60;
        durationText = [NSString stringWithFormat:@"%02i:%02i", minute, second];
    }
    item.durationTimeString = durationText;
    
    if([cellModel.imageList firstObject]){
        item.imageModel = [self convertTTImageInfosModel:[cellModel.imageList firstObject]];;
    }
    
    return item;
}

+ (TTImageInfosModel *)convertTTImageInfosModel:(FHFeedContentImageListModel *)imageModel {
    if(imageModel){
        NSDictionary *dict = [imageModel toDictionary];
        return [[TTImageInfosModel alloc] initWithDictionary:dict];
    }
    
    return nil;
}

+ (NSAttributedString *)convertRichContentWithModel:(AWECommentModel *)model {
    NSMutableAttributedString *mutableAttributedString = nil;
    
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:model.contentRichSpan];
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:model.text richSpans:richSpans];
    
    if(model.replyToComment){
        [richContent appendCommentQuotedUserName:model.replyToComment.userName userId:model.replyToComment.userId.stringValue];
        
        TTRichSpanText *quotedRichSpanText = [[TTRichSpanText alloc] initWithText:model.replyToComment.text
                                                              richSpansJSONString:model.replyToComment.contentRichSpan];
        [richContent appendRichSpanText:quotedRichSpanText];
    }
    
    if (!isEmptyString(richContent.text)) {
        NSInteger parseEmojiCount = -1;
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:richContent.text fontSize:15 needParseCount:parseEmojiCount];
        if (attrStr) {
            CGFloat fontSize = 16.0f;
            UIFont *font = [UIFont themeFontRegular:fontSize];
            CGFloat lineHeight = ceil(fontSize * 1.4);
            
            mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            paragraphStyle.minimumLineHeight = lineHeight;
            paragraphStyle.maximumLineHeight = lineHeight;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
        }
    }
    
    return [mutableAttributedString copy];
}

+ (void)setQuestionRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    if (!isEmptyString(model.questionStr)) {
        NSInteger parseEmojiCount = -1;
        if (numberOfLines > 0) {
            parseEmojiCount = (100 * (model.numberOfLines + 1));// 只需解析这么多，其他解析无用~~
        }
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:model.questionStr fontSize:15 needParseCount:parseEmojiCount];
        if (attrStr) {
            UIFont *font = [UIFont themeFontRegular:16];
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            paragraphStyle.minimumLineHeight = 22;
            paragraphStyle.maximumLineHeight = 22;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            model.questionAStr = mutableAttributedString;
            
            CGSize size = [self sizeThatFitsAttributedString:mutableAttributedString
                                             withConstraints:CGSizeMake(width, FLT_MAX)
                                            maxNumberOfLines:numberOfLines
                                      limitedToNumberOfLines:&numberOfLines];
            model.questionHeight = size.height;
        }
    }else{
        model.questionHeight = 22;
    }
}

+ (void)setAnswerRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    if (!isEmptyString(model.answerStr)) {
        NSInteger parseEmojiCount = -1;
        if (numberOfLines > 0) {
            parseEmojiCount = (100 * (model.numberOfLines + 1));// 只需解析这么多，其他解析无用~~
        }
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:model.answerStr fontSize:13 needParseCount:parseEmojiCount];
        if (attrStr) {
            UIFont *font = [UIFont themeFontRegular:14];
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray3] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            paragraphStyle.minimumLineHeight = 20;
            paragraphStyle.maximumLineHeight = 20;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            model.answerAStr = mutableAttributedString;
            
            CGSize size = [self sizeThatFitsAttributedString:mutableAttributedString
                                             withConstraints:CGSizeMake(width, FLT_MAX)
                                            maxNumberOfLines:numberOfLines
                                      limitedToNumberOfLines:&numberOfLines];
            model.answerHeight = size.height;
        }
    }else{
        model.answerHeight = 0;
    }
}

+ (UIImage *)circleImage:(UIImage *)ima
{
    
    //1.开启图片图形上下文:注意设置透明度为非透明
    UIGraphicsBeginImageContextWithOptions(ima.size, NO, 0.0);
    //2.开启图形上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    //3.绘制圆形区域(此处根据宽度来设置)
    CGRect rect = CGRectMake(0, 0, ima.size.width, ima.size.width);
    CGContextAddEllipseInRect(ref, rect);
    //4.裁剪绘图区域
    CGContextClip(ref);
    
    //5.绘制图片
    [ima drawInRect:rect];
    
    //6.获取图片
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    //7.关闭图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}

@end
