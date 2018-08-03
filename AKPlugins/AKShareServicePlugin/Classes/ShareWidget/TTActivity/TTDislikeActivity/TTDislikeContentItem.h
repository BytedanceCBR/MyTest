//
//  TTDislikeContentItem.h
//  Pods
//
//  Created by 王双华 on 2017/8/24.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeDislike;

@interface TTDislikeContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, copy) TTCustomAction customAction;

@end
