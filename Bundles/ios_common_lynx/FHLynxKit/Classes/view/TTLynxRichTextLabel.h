//
//  TTLynxRichTextLabel.h
//  TTLynxAdapter
//
//  Created by ranny_90 on 2020/4/27.
//

#import "LynxUI.h"
#import <Foundation/Foundation.h>
#import <Lynx/LynxShadowNode.h>
#import "TTUGCAttributedLabel.h"
#import "TTRichSpanText.h"
#import "TTLynxAttributedLabel.h"


NS_ASSUME_NONNULL_BEGIN

static NSString *const kTTUGCLynxRichLabelImageLinkString = @"www.bytedance.lynxRichLabelImageLinkString";

typedef NS_ENUM(NSUInteger, TTLynxRichTextAutoClickType){
    TTLynxRichTextAutoClickTypeNone = 0,
    TTLynxRichTextAutoClickTypeBefore = 1,
    TTLynxRichTextAutoClickTypeAfter = 2,
};

/*
 富文本功能点击有问题暂时不可用
 */

@interface TTLynxRichLabelRouteModel : NSObject

@property (nonatomic, copy) NSString *schema;

@property (nonatomic, copy) NSDictionary *routeParams;

@end

@interface TTLynxRichLabelClickLinkModel : NSObject

@property (nonatomic, strong) TTUGCAttributedLabel *label;

@property (nonatomic, strong) TTUGCAttributedLabelLink *labelLink;

@property (nonatomic, strong) TTRichSpanLink *richSpanLink;

@property (nonatomic, strong) TTRichSpanText *richText;

@property (nonatomic, assign) TTLynxRichTextAutoClickType clickType;

@property (nonatomic, strong) NSURL *clickURL;

@end

@interface TTLynxRichLabelClickURLModel : NSObject

@property (nonatomic, strong) TTUGCAttributedLabel *label;

@property (nonatomic, strong) NSURL *clickURL;

@end

@protocol TTLynxRichTextLabelProtocol <NSObject>

- (NSNumber *)isNeedManualActionToClick;

- (void)manualClickWithClickModel:(TTLynxRichLabelClickLinkModel *)clickModel;

- (TTLynxRichLabelRouteModel *)autoClickWithClickModel:(TTLynxRichLabelClickLinkModel *)clickModel;

- (void)attributedLabelClikURLModel:(TTLynxRichLabelClickURLModel *)urlModel;

@end


@interface TTLynxRichTextLabel : LynxUI<TTLynxAttributedLabel *>


@end

NS_ASSUME_NONNULL_END
