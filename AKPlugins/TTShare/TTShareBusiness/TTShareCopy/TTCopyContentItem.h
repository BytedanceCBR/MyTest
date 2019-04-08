//
//  TTCopyContentItem.h
//  Pods
//
//  Created by 延晋 张 on 16/6/7.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeCopy;

@interface TTCopyContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *contentTitle;
@property (nonatomic, copy) NSString *activityImageName;

- (instancetype)initWithDesc:(NSString *)desc;

@end
