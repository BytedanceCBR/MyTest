//
//  SSTTTAttributedLabel.m
//  Article
//
//  Created by Chen Hong on 15/4/7.
//
//

#import "SSTTTAttributedLabel.h"
 


@implementation SSTTTAttributedLink
@end

@implementation SSTTTAttributedModel
@end


@implementation SSTTTAttributedLabel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}

+ (CGSize)sizeThatFitsString:(NSString *)string
             withConstraints:(CGSize)size
                  attributes:(NSDictionary *)attributes
      limitedToNumberOfLines:(NSUInteger)numberOfLines {
    NSAttributedString * attributedStr = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    return [self sizeThatFitsAttributedString:attributedStr withConstraints:size limitedToNumberOfLines:numberOfLines];
}

- (void)attachLongPressHandler {
    [self setUserInteractionEnabled:YES];
    UIGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)handleLongPress:(UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil) action:@selector(customCopy:)];
        if (copyItem) {
            menu.menuItems = @[copyItem];
        }
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
        if (_backgroundHighlightColor) {
            self.backgroundColor = _backgroundHighlightColor;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
}

- (void)willHideMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    self.backgroundColor = [UIColor clearColor];
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(__unused id)sender
{
    return (action == @selector(customCopy:));
}

- (void)customCopy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:[self orginalText]];
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

+ (SSTTTAttributedModel *)attributeModelByReplaceLinkInString:(NSString *)content withLabel:(NSString *)label {
    SSTTTAttributedModel *attributedModel = [[SSTTTAttributedModel alloc] init];
    attributedModel.content = content;

    if (!isEmptyString(content)) {
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        
        NSArray *matches = [linkDetector matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        
        if (matches.count > 0) {
            NSInteger offset = 0;
            NSString *replacementString = label;
            NSMutableArray *linkArray = [NSMutableArray array];
            NSMutableString *mutableString = [content mutableCopy];
            
            for (NSTextCheckingResult *result in matches) {
                NSRange resultRange = [result range];
                resultRange.location += offset;
                
                SSTTTAttributedLink *link = [[SSTTTAttributedLink alloc] init];
                link.url = result.URL;
                if ([result.URL.absoluteString rangeOfString:@"mailto:"].location != NSNotFound) {
                    //email
                    link.range = resultRange;
                    [linkArray addObject:link];
                }else {
                    //normal link
                    link.range = NSMakeRange(resultRange.location, replacementString.length);
                    [linkArray addObject:link];
                    [mutableString replaceCharactersInRange:resultRange withString:replacementString];
                    offset += replacementString.length - resultRange.length;
                }
            }
            
            attributedModel.linkArray = linkArray;
            attributedModel.content = [mutableString copy];
        }
    }
    
    return attributedModel;
}

+ (SSTTTAttributedModel *)attributeModelByReplaceLinkInString:(NSString *)content {
    return [self attributeModelByReplaceLinkInString:content withLabel:@"网页链接"];
}

- (void)addAttributedLink:(SSTTTAttributedLink *)link {
    if (link.url) {
        [self addLinkToURL:link.url withRange:link.range];
    }
}

- (NSString *)orginalText {
    NSArray *links = self.links;
    if (links.count == 0) {
        return self.text;
    }
    
    NSMutableString *str = [NSMutableString stringWithString:self.text];
    
    NSEnumerator *enumerator = [links reverseObjectEnumerator];
    NSTextCheckingResult *link = nil;
    while ((link = [enumerator nextObject])) {
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSString *content = [NSString stringWithFormat:@"%@",link.URL.absoluteString];
        NSArray *matches = [linkDetector matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        if ([matches count] > 0) {
            [str replaceCharactersInRange:link.range withString:link.URL.absoluteString];
        }
    }

    return [str copy];
}

@end
