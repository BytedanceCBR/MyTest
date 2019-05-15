//
//  LiveTeam.h
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import <Foundation/Foundation.h>
#import "TTEntityBase.h"

@class LiveMatch;

NS_ASSUME_NONNULL_BEGIN

@interface LiveTeam : TTEntityBase

@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic) int64_t teamId;
@property (nullable, nonatomic, retain) NSString *url;

@end

NS_ASSUME_NONNULL_END
