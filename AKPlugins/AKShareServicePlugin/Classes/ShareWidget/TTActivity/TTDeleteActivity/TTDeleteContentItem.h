//
//  TTDeleteContentItem.h
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeDelete;

@interface TTDeleteContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, assign) BOOL canDelete;
@property (nonatomic, copy) TTCustomAction customAction;

@end
