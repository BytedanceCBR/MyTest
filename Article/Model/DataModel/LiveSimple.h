//
//  LiveSimple.h
//  Article
//
//  Created by 王双华 on 16/9/19.
//
//

#import <Foundation/Foundation.h>
#import "TTEntityBase.h"

@class Live;

NS_ASSUME_NONNULL_BEGIN

@interface LiveSimple : TTEntityBase

@property (nullable, nonatomic, copy) NSString *covers;
@property (nonatomic) int64_t simpleId;
//@property (nullable, nonatomic, retain) Live *live;

@end

NS_ASSUME_NONNULL_END

