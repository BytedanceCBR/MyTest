//
//  TTAdPromotionActivity.h
//  Article
//
//  Created by 王霖 on 2017/4/27.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTActivityPanelDefine.h"
#import "TTAdPromotionContentItem.h"

extern NSString * const TTActivityTypeAdPromotion;

@interface TTAdPromotionActivity : NSObject <TTActivityProtocol, TTActivityPanelActivityProtocol>

@property (nonatomic, strong) TTAdPromotionContentItem * contentItem;

@end
