//
//  LiveMatch.m
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import "LiveMatch.h"
#import "Live.h"
#import "LiveTeam.h"

@implementation LiveMatch

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"matchId";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"covers",
                       @"matchId",
                       @"score1",
                       @"score2",
                       @"time",
                       @"title",
                       @"teamId1",
                       @"teamId2",
                       @"videoFlag",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"matchId":@"id",
                       @"videoFlag":@"video_flag",
                       };
    }
    return properties;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    LiveMatch *other = (LiveMatch *)object;
    
    if (self.matchId != other.matchId) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return (NSUInteger)(self.matchId % NSUIntegerMax);
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    [super updateWithDictionary:dataDict];
//    if ((SSModelManager *)self.managedObjectContext) {
//        SSModelManager *manager = (SSModelManager *)self.managedObjectContext;
    NSDictionary *liveTeam1 = [dataDict tt_dictionaryValueForKey:@"team1"];
    NSDictionary *liveTeam2 = [dataDict tt_dictionaryValueForKey:@"team2"];
        if (liveTeam1) {
            self.score1 = [NSNumber numberWithDouble:[liveTeam1 tt_doubleValueForKey:@"score"]];
            self.team1 = [LiveTeam objectWithDictionary:liveTeam1];
            self.teamId1 = self.team1.teamId;
            [self.team1 save];
        }
        if (liveTeam2) {
            self.score2 = [NSNumber numberWithDouble:[liveTeam2 tt_doubleValueForKey:@"score"]];
            self.team2 = [LiveTeam objectWithDictionary:liveTeam2];
            self.teamId2 = self.team2.teamId;
            [self.team2 save];
        }
//    }
}

- (void)updateWithScore:(NSNumber *)score1 score2:(NSNumber *)score2 {
    self.score1 = score1;
    self.score2 = score2;
}

- (LiveTeam *)team1 {
    if (!_team1 && _teamId1 > 0) {
        _team1 = [LiveTeam objectForPrimaryKey:@(_teamId1)];
    }
    return _team1;
}

- (LiveTeam *)team2 {
    if (!_team2 && _teamId2 > 0) {
        _team2 = [LiveTeam objectForPrimaryKey:@(_teamId2)];
    }
    return _team2;
}

+ (void)removeAllEntities {
    [super removeAllEntities];
    [LiveTeam removeAllEntities];
}

@end
