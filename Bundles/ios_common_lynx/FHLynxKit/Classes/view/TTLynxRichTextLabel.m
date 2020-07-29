//
//  TTLynxRichTextLabel.m
//  TTLynxAdapter
//
//  Created by ranny_90 on 2020/4/27.
//

#import "TTLynxRichTextLabel.h"
#import "TTLynxRichTextStyle.h"
#import "UIResponder+TTLynxExtention.h"
#import <Lynx/LynxComponentRegistry.h>
#import <Lynx/LynxPropsProcessor.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTThemed/UIColor+TTThemeExtension.h>
#import "FHUGCCellHelper.h"
#import <TTThemed/TTThemeConst.h>
#import "TTUGCEmojiParser.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTKitchen/TTKitchen.h>
#import <ByteDanceKit/NSURL+BTDAdditions.h>
#import <TTRoute/TTRoute.h>
#import "TTLynxRichTextShadowNode.h"

@implementation TTLynxRichLabelRouteModel

@end

@implementation TTLynxRichLabelClickLinkModel

@end

@implementation TTLynxRichLabelClickURLModel

@end


@interface TTLynxRichTextLabel()<TTUGCAttributedLabelDelegate>

@property(nonatomic , strong) TTLynxRichTextStyle *textStyle;

@end

@implementation TTLynxRichTextLabel

LYNX_REGISTER_UI("f-pre-layout-text")

- (UIView *)createView {
    TTLynxAttributedLabel *label = [[TTLynxAttributedLabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.extendsLinkTouchArea = NO;
    label.delegate = self;
    return label;
}

- (void)onReceiveUIOperation:(id)value {
    if (value && [value isKindOfClass:[TTLynxRichTextStyle class]]) {
        self.textStyle = value;
        self.view.attributedTruncationToken = _textStyle.truncationToken;
        self.view.text = _textStyle.attributeString;
        [self configureRichSpanLinksWithTextStlye:_textStyle];
        self.view.numberOfLines = _textStyle.numberOfLines;
        [self.view setNeedsLayout];
    }
}


- (void)configureRichSpanLinksWithTextStlye:(TTLynxRichTextStyle *)textStyle {
    if (!textStyle || !textStyle.richSpanText || isEmptyString([textStyle.attributeString string])) {
        return;
    }
    NSArray<TTRichSpanLink *> *richSpanLinks = [textStyle.richSpanText richSpanLinksOfAttributedString];
    if (SSIsEmptyArray(richSpanLinks)) {
        return;
    }
    NSMutableArray <TTRichSpanLink *> *contentRichSpanLinks = [[NSMutableArray alloc] init];
    NSMutableArray *links = [NSMutableArray arrayWithCapacity:richSpanLinks.count];
    for (TTRichSpanLink *current in richSpanLinks) {
        NSRange linkRange = NSMakeRange(current.start, current.length);
        if (linkRange.location + linkRange.length <= textStyle.attributeString.length) {
            UIColor *linkColor = [UIColor tt_themedColorForKey:kColorText5];
            UIColor *activeLinkColor = [UIColor tt_themedColorForKey:kColorText5];
            NSTextCheckingResult *checkingResult = [NSTextCheckingResult transitInformationCheckingResultWithRange:linkRange components:@{}];
            TTUGCAttributedLabelLink *link = [[TTUGCAttributedLabelLink alloc] initWithAttributes:linkColor ? @{NSForegroundColorAttributeName : linkColor} : nil
                                                                          activeAttributes:activeLinkColor ? @{NSForegroundColorAttributeName : activeLinkColor} : nil
                                                                        inactiveAttributes:activeLinkColor ? @{NSForegroundColorAttributeName : activeLinkColor} : nil
                                                                        textCheckingResult:checkingResult];
            if (current.type == TTRichSpanLinkTypeImage) {
                link.linkURL = [NSURL URLWithString:kTTUGCLynxRichLabelImageLinkString];
            } else {
                link.linkURL = [NSURL URLWithString:current.link];
            }
            [links addObject:link];
            [contentRichSpanLinks addObject:current];
        }
    }

    if (!SSIsEmptyArray(links)) {
        for (NSInteger i = 0; i < links.count; i++) {
            TTUGCAttributedLabelLink *link = [links objectAtIndex:i];
            TTRichSpanLink *richSpanLink = nil;
            if (i < links.count) {
                richSpanLink = [links objectAtIndex:i];
            }
            WeakSelf;
            link.linkTapBlock = ^(TTUGCAttributedLabel *curLabel, TTUGCAttributedLabelLink *curLink) {
                StrongSelf;
                NSNumber *isManualClick = [self.view lynx_getResultWithSel:@selector(isNeedManualActionToClick) param:nil completeBlock:nil];
                TTLynxRichLabelClickLinkModel *clickModel = [[TTLynxRichLabelClickLinkModel alloc] init];
                clickModel.label = curLabel;
                clickModel.labelLink = curLink;
                clickModel.richSpanLink = richSpanLink;
                clickModel.richText = textStyle.richSpanText;

                if (isManualClick.boolValue) {
                    clickModel.clickType = TTLynxRichTextAutoClickTypeNone;
                    [self.view lynx_getResultWithSel:@selector(manualClickWithClickModel:) param:clickModel completeBlock:nil];
                } else {
                    clickModel.clickType = TTLynxRichTextAutoClickTypeBefore;
                    TTLynxRichLabelRouteModel *routeModel = [self.view lynx_getResultWithSel:@selector(autoClickWithClickModel:) param:clickModel completeBlock:nil];

                    NSRange attributeLinkRange = curLink.result.range;
                    CGRect attributeLinkRect = [self.view boundingRectForCharacterRange:attributeLinkRange];
                    CGRect rect = [self.view convertRect:attributeLinkRect toView:nil];
                    [self onClickRichSpanLink:richSpanLink atRichText:textStyle.richSpanText routeModel:routeModel rect:rect inFragmetView:nil];

                    clickModel.clickType = TTLynxRichTextAutoClickTypeAfter;
                    [self.view lynx_getResultWithSel:@selector(autoClickWithClickModel:) param:clickModel completeBlock:nil];
                }
            };
            [self.view addLink:link];
        }
    }
}

- (void)onClickRichSpanLink:(TTRichSpanLink *)richSpanLink atRichText:(TTRichSpanText *)richText routeModel:(TTLynxRichLabelRouteModel *)routeModel rect:(CGRect)rect inFragmetView:(UIView *)fragmentView {

    if (richSpanLink.type != TTRichSpanLinkTypeImage && isEmptyString(richSpanLink.link) && isEmptyString(routeModel.schema)) {
        return;
    }

    NSString *schemaString = routeModel.schema;
    if (isEmptyString(schemaString)) {
        schemaString = richSpanLink.link;
    }
    NSURL *schema = [NSURL btd_URLWithString:schemaString];
    NSDictionary *routeParams = routeModel.routeParams;

    if (richSpanLink.type != TTRichSpanLinkTypeImage) {
        if ([[TTRoute sharedRoute] canOpenURL:schema]) {
            [[TTRoute sharedRoute] openURLByPushViewController:schema userInfo:TTRouteUserInfoWithDict([routeParams copy])];
        }
    }
}

- (void)attributedLabel:(TTUGCAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    //点击...全文
    if([url.absoluteString isEqualToString:kTTUGCLynxRichLabelTruncationLinkString] && self.textStyle.truncationTokenUrl.length > 0){
        NSURL *schema = [NSURL btd_URLWithString:self.textStyle.truncationTokenUrl];
        if ([[TTRoute sharedRoute] canOpenURL:schema]) {
            [[TTRoute sharedRoute] openURLByPushViewController:schema userInfo:nil];
        }
        return;
    }
    
    TTLynxRichLabelClickURLModel *clickModel = [[TTLynxRichLabelClickURLModel alloc] init];
    clickModel.label = label;
    clickModel.clickURL = url;

    [self.view lynx_actionWithSel:@selector(attributedLabelClikURLModel:) param:clickModel completeBlock:nil];
}

@end
