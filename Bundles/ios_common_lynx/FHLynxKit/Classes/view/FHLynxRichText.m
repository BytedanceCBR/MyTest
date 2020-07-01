//
//  FHLynxRichText.m
//  Pods
//
//  Created by fupeidong on 2020/6/29.
//

#import "FHLynxRichText.h"
#import <Lynx/LynxComponentRegistry.h>
#import <Lynx/LynxPropsProcessor.h>
#import "FRichSpanModel.h"
#import "FHMainApi.h"
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "TTRoute.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"

@interface FHLynxRichText()

@property(nonatomic, strong) NSMutableAttributedString * attrStr;
@property(nonatomic, strong) UIColor *spanColor;
@property(nonatomic, strong) UIColor *tvColor;
@property(nonatomic, strong) FRichSpanModel *spanModel;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, assign) NSTextAlignment alignment;

@end

@implementation FHLynxRichText

LYNX_REGISTER_UI("f-rich-text")

- (UIView *)createView
{
    YYLabel *textView = [[YYLabel alloc] init];
    [textView setNumberOfLines:0];
    textView.userInteractionEnabled = YES;
    _spanColor = [UIColor themeOrange1];
    [[self view] setBackgroundColor:[UIColor themeRed2]];
    return textView;
}

LYNX_PROP_SETTER("richData", setRichData, NSString*)
{
    NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
    Class cls = [FRichSpanModel class];
    __block NSError *backError = nil;
    _spanModel = [FHMainApi generateModel:jsonData class:cls error:&backError];
}

LYNX_PROP_SETTER("spanColor", setSpanColor, UIColor*)
{
    _spanColor = value;
}

LYNX_PROP_SETTER("color", setTvColor, UIColor*)
{
    _tvColor = value;
}

LYNX_PROP_SETTER("text-align", setTextAlign, NSString*)
{
    if ([@"auto" isEqualToString:value]) {
        _alignment = NSTextAlignmentLeft;
    } else if ([@"left" isEqualToString:value]) {
        _alignment = NSTextAlignmentLeft;
    } else if ([@"right" isEqualToString:value]) {
        _alignment = NSTextAlignmentRight;
    } else if ([@"center" isEqualToString:value]) {
        _alignment = NSTextAlignmentCenter;
    }
}

LYNX_PROP_SETTER("font-size", setFontSize, CGFloat)
{
    _font = [UIFont systemFontOfSize:value];
}

- (void)propsDidUpdate
{
    if (_spanModel != nil) {
        if (!IS_EMPTY_STRING(_spanModel.text)) {
            _attrStr = [[NSMutableAttributedString alloc] initWithString:_spanModel.text];
            _attrStr.yy_color = _tvColor;
            //设置高亮
            [_spanModel.richText enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[FRichSpanRichTextModel class]]) {
                    FRichSpanRichTextModel *span = (FRichSpanRichTextModel *)obj;
                    if (span.highlightRange.count == 2) {
                        NSNumber* start = (NSNumber *)span.highlightRange.firstObject;
                        NSNumber* end = (NSNumber *)span.highlightRange.lastObject;
                        NSUInteger length = end.intValue - start.intValue;
                        NSRange range = NSMakeRange(start.intValue, length);
//                        [_attrStr addAttribute:NSForegroundColorAttributeName value:_spanColor range:range];
                        [_attrStr yy_setTextHighlightRange:range color:_spanColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                            NSURL *URL = [NSURL URLWithString:span.linkUrl];
                            if ([[TTRoute sharedRoute] canOpenURL:URL]) {
                                [[TTRoute sharedRoute] openURLByPushViewController:URL userInfo:nil];
                            }
                        }];
                    }
                }
            }];
            _attrStr.yy_font = _font;
        }
    
        [self view].attributedText = _attrStr;
        [self view].textAlignment = _alignment;
    }
}

- (void)updateFrame:(CGRect)frame withPadding:(UIEdgeInsets)padding border:(UIEdgeInsets)border withLayoutAnimation:(BOOL)with
{
    [super updateFrame:frame withPadding:padding border:border withLayoutAnimation:with];
    [self view].textContainerInset = padding;
}

@end
