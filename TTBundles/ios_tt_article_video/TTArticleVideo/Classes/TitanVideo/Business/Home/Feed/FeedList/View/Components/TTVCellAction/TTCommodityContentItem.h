//
//  TTCommodityContentItem.h
//  Article
//
//  Created by lishuangyang on 2017/9/14.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeCommodity;

@interface TTCommodityContentItem : NSObject<TTActivityContentItemProtocol>

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *contentTitle;
@property (nonatomic, copy) NSString *activityImageName;

@property (nonatomic, copy) TTCustomAction customAction;

- (instancetype)initWithDesc:(NSString *)desc;

@end
