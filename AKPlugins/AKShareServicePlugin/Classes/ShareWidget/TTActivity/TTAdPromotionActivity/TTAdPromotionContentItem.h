//
//  TTAdPromotionContentItem.h
//  Article
//
//  Created by 王霖 on 2017/4/27.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeAdPromotion;

@interface TTAdPromotionContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, copy) TTCustomAction customAction;
@property (nonatomic, copy, readonly) NSString *iconURL;

- (instancetype)initWithTitle:(NSString *)title iconURL:(NSString *)url;

@end
