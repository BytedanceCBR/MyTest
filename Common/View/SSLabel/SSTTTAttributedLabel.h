//
//  SSTTTAttributedLabel.h
//  Article
//
//  Created by Chen Hong on 15/4/7.
//
//

#import "TTTAttributedLabel.h"

@class SSTTTAttributedModel;
@class SSTTTAttributedLink;

@interface SSTTTAttributedLabel : TTTAttributedLabel

@property (nonatomic, copy) UIColor *backgroundHighlightColor;

+ (CGSize)sizeThatFitsString:(NSString *)string
             withConstraints:(CGSize)size
                  attributes:(NSDictionary *)attributes
      limitedToNumberOfLines:(NSUInteger)numberOfLines;

/**
 *  add long press gesture
 */
- (void)attachLongPressHandler;


/**
 *  替换字符串中的网页链接地址为特定字符串
 *
 *  @param content 要处理的字符串
 *  @param label   链接地址替换为‘label’
 *
 *  @return SSTTTAttributedModel
 */
+ (SSTTTAttributedModel *)attributeModelByReplaceLinkInString:(NSString *)content withLabel:(NSString *)label;

+ (SSTTTAttributedModel *)attributeModelByReplaceLinkInString:(NSString *)content;

- (void)addAttributedLink:(SSTTTAttributedLink *)link;

@end

/**
 *  字符串中link属性
 */
@interface SSTTTAttributedLink : NSObject

@property(nonatomic, strong)NSURL *url;
@property(nonatomic, assign)NSRange range;

@end


/**
 *  处理后的字符串和链接数组
 */
@interface SSTTTAttributedModel : NSObject

@property(nonatomic, copy)NSString *content;
@property(nonatomic, strong)NSArray *linkArray;

@end

