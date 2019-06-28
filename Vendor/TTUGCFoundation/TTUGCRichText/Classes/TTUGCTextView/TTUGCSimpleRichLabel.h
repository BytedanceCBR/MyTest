//
//  TTUGCSimpleRichLabel.h
//  TTUGCFoundation
//
//  Created by SongChai on 2018/1/12.
//

#import "TTRichSpanText.h"
#import "TTUGCAttributedLabel.h"

@class TTUGCSimpleRichLabel;

@protocol TTUGCSimpleRichLabelDelegate <NSObject>

- (void)ugcDefaultRichLabel:(TTUGCSimpleRichLabel *)label didClickURL:(NSURL *)URL;

@end

@interface TTUGCSimpleRichLabel : TTUGCAttributedLabel

@property (nonatomic, copy) NSArray *textColors; //第一个日间，第二个夜间, must be colors
@property (nonatomic, copy) NSArray *linkColors;
@property (nonatomic, copy) NSString *textColorThemeKey;
@property (nonatomic, copy) NSString *linkColorThemeKey;
@property (nonatomic, assign) BOOL autoDetectLinks;
@property (nonatomic, weak) id<TTUGCSimpleRichLabelDelegate> clickDelegate; //不设置默认响应点击

- (void)setRichSpanText:(TTRichSpanText *)richSpanText;
- (void)setText:(NSString *)text textRichSpans:(NSString *)textRichSpans;

+ (CGSize)heightWithWidth:(CGFloat)width
             richSpanText:(TTRichSpanText *)richSpanText
                     font:(UIFont *)font
            numberOfLines:(int)numberOfLines;
@end
