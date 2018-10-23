//
//  TTEditContentItem.h
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeEdit;

@interface TTEditContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, copy) TTCustomAction customAction;
@property (nonatomic, assign) BOOL canEdit;

@end
