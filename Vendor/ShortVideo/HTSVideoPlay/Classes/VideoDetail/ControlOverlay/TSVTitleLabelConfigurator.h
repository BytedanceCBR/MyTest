//
//  TSVTitleLabelConfigurator.h
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 22/12/2017.
//

#import <Foundation/Foundation.h>

@class TTUGCAttributedLabel, TTUGCAttributedLabelLink, TTRichSpanText;

@interface TSVTitleLabelConfigurator : NSObject

+ (void)updateAttributeTitleForLabel:(TTUGCAttributedLabel *)label
                        trimHashTags:(BOOL)trimHashTags
                                text:(NSString *)text
                 richTextStyleConfig:(NSString *)styleConfig
                         allBoldFont:(BOOL)allBoldFont
                            fontSize:(CGFloat)fontSize
                        activityName:(NSString *)activityName
                     prependUserName:(BOOL)prependUserName
                            userName:(NSString *)userName
                        linkTapBlock:(void (^)(TTRichSpanText *richSpanText, TTUGCAttributedLabelLink *curLink))linkTapBlock
                    userNameTapBlock:(void (^)(void))userNameTapBlock;

@end
