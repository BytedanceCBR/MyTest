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

@interface FHLynxRichText()<UITextViewDelegate>

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
    UITextView *textView = [[UITextView alloc] init];
//    [textView setNumberOfLines:0];
    textView.userInteractionEnabled = YES;
    _spanColor = [UIColor themeOrange1];
    [[self view] setBackgroundColor:[UIColor redColor]];
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
//                        [_attrStr addAttributes:NSLinkAttributeName range:range];
                         [_attrStr addAttribute:NSLinkAttributeName
                                                         value:span.linkUrl
                                                  range:range];
                       
                        [_attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
//                        [_attrStr yy_setTextHighlightRange:range color:_spanColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//                            NSURL *URL = [NSURL URLWithString:span.linkUrl];
//                            if ([[TTRoute sharedRoute] canOpenURL:URL]) {
//                                [[TTRoute sharedRoute] openURLByPushViewController:URL userInfo:nil];
//                            }
//                        }];
                    }
                }
            }];
            _attrStr.yy_font = _font;
        }
        if (_font) {
            [_attrStr addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, _attrStr.length)];
        }
        [self view].attributedText = _attrStr;
        [self view].delegate = self;
        [self view].editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
        [self view].scrollEnabled = NO;
        [self view].userInteractionEnabled = YES;
        [[self view] setBackgroundColor:[UIColor clearColor]];


//        [self.view setTextTapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//
//        }];
        if (_spanColor) {
            [self view].linkTextAttributes = @{NSForegroundColorAttributeName:_spanColor};
        }
        [self view].textAlignment = _alignment;
    }
}

- (void)longBangClick
{
    
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    if (URL) {
        [[TTRoute sharedRoute] openURLByViewController:URL userInfo:nil];
    }
//    NSRange range = [@"1.您可能很久未更新最新数据导致图表有误，请及时刷新;\n以上分析根据公积金官网数据统计分析所得，可能存在有误。" rangeOfString:@"刷新"];
//    if (NSEqualRanges(characterRange, range)) {
//        NSLog(@"设置您的自定义事件");
////        if (self.refreshAccountBlock) {
////            self.refreshAccountBlock();
////        }
//    }
    return NO;
}


- (void)updateFrame:(CGRect)frame withPadding:(UIEdgeInsets)padding border:(UIEdgeInsets)border withLayoutAnimation:(BOOL)with
{
    [super updateFrame:frame withPadding:padding border:border withLayoutAnimation:with];
    [self view].textContainerInset = padding;
}

@end
