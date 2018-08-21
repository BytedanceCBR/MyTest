//
//  TTVMoreAction.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import <Foundation/Foundation.h>
#import "TTActivity.h"

@class TTVFeedItem;
@interface TTVMoreActionEntity : NSObject
@property (nonatomic, strong) TTVFeedItem *cellEntity;
@end

@interface TTVMoreAction : NSObject
@property (nonatomic ,assign)TTActivityType type;
@property (nonatomic ,strong)TTVMoreActionEntity *entity;
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity;
- (void)execute:(TTActivityType)type;
@end
