//
//  LiveVideo.h
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import <Foundation/Foundation.h>
#import "TTEntityBase.h"

@class Live;

NS_ASSUME_NONNULL_BEGIN

@interface LiveVideo : TTEntityBase

@property (nullable, nonatomic, retain) NSString *covers;
@property (nonatomic) int64_t videoId;

@end

NS_ASSUME_NONNULL_END
