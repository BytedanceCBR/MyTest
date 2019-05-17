//
//  TTBuryContentItem.h
//  Article
//
//  Created by lishuangyang on 2017/8/24.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeBury;

@interface TTBuryContentItem : NSObject<TTActivityContentItemSelectedDigProtocol>

@property (nonatomic, copy) TTCustomAction customAction;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL banDig;
@property (nonatomic, assign) int64_t count;

@end
