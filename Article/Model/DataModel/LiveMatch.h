//
//  LiveMatch.h
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import <Foundation/Foundation.h>
#import "TTEntityBase.h"

@class Live, LiveTeam;

NS_ASSUME_NONNULL_BEGIN

@interface LiveMatch : TTEntityBase

@property (nullable, nonatomic, retain) NSString *covers;
@property (nonatomic) int64_t matchId;
@property (nullable, nonatomic, retain) NSNumber *score1;
@property (nullable, nonatomic, retain) NSNumber *score2;
@property (nullable, nonatomic, retain) NSNumber *videoFlag;
@property (nullable, nonatomic, retain) NSString *time;
@property (nullable, nonatomic, retain) NSString *title;
@property (nonatomic) int64_t teamId1;
@property (nonatomic) int64_t teamId2;
//@property (nullable, nonatomic, retain) Live *live;
@property (nullable, nonatomic, retain) LiveTeam *team1;
@property (nullable, nonatomic, retain) LiveTeam *team2;

- (void)updateWithScore:(NSNumber *)score1 score2:(NSNumber *)score2;

@end

NS_ASSUME_NONNULL_END

