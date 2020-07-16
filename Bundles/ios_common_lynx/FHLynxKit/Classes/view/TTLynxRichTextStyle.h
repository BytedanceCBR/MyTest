//
//  TTLynxRichTextStyle.h
//  TTLynxAdapter
//
//  Created by ranny_90 on 2020/5/6.
//

#import <Foundation/Foundation.h>
#import <Lynx/LynxShadowNode.h>
#import "TTUGCAttributedLabel.h"
#import "TTRichSpanText.h"


NS_ASSUME_NONNULL_BEGIN

@interface TTLynxRichTextStyle : NSObject

@property (nonatomic, assign) NSInteger numberOfLines;

@property (nonatomic, strong) TTRichSpans *richSpans;

@property (nonatomic, strong) TTRichSpanText *richSpanText;

@property (nonatomic, strong) NSAttributedString *truncationToken;

@property (nonatomic, strong) NSAttributedString *attributeString;

@property (nonatomic, copy) NSString *truncationTokenUrl;

@end

NS_ASSUME_NONNULL_END
