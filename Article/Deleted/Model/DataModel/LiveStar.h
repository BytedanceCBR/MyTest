//
//  LiveStar.h
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import <Foundation/Foundation.h>
#import "TTEntityBase.h"

//@class Live;

NS_ASSUME_NONNULL_BEGIN

@interface LiveStar : TTEntityBase

@property (nullable, nonatomic, retain) NSString *covers;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic) int64_t starId;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *url;
//@property (nullable, nonatomic, retain) NSSet<Live *> *live;

@end

NS_ASSUME_NONNULL_END
