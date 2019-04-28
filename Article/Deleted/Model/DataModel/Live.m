//
//  Live.m
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import "Live.h"
#import "LiveMatch.h"
#import "LiveStar.h"
#import "LiveVideo.h"
#import "LiveSimple.h"
#import "NSDictionary+TTAdditions.h"

@implementation Live

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                       @"liveId",
                       @"participated",
                       @"participatedSuffix",
                       @"status",
                       @"statusDisplay",
                       @"title",
                       @"type",
                       @"url",
                       @"followed",
                       @"showFollowed",
                       @"adId",
                       @"logExtra",
                       @"source",
                       @"sourceAvatar",
                       @"sourceOpenUrl",
                       @"adCover",
                       @"filterWords",
                       ]];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"adCover":@"ad_cover",
                                         @"adId":@"ad_id",
                                         @"type":@"background_type",
                                         @"liveId":@"live_id",
                                         @"logExtra":@"log_extra",
                                         @"participatedSuffix":@"participated_suffix",
                                         @"showFollowed":@"show_followed",
                                         @"sourceAvatar":@"source_avatar",
                                         @"sourceOpenUrl":@"source_open_url",
                                         @"statusDisplay":@"status_display",
                                         }];
        properties = [dict copy];
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    [super updateWithDictionary:dataDict];
    NSDictionary *background = [dataDict tt_dictionaryValueForKey:@"background"];
    TTLiveType type = [[self type] integerValue];
    
    if (background) {
        switch (type) {
            case TTLiveTypeStar:
            {
                NSDictionary *data = [background tt_dictionaryValueForKey:@"star"];
                if (data) {
                    NSMutableDictionary *starData = [[NSMutableDictionary alloc] initWithDictionary:data];
                    [starData setValue:self.liveId forKey:@"id"];
                    self.star = [LiveStar objectWithDictionary:starData];
                    [self.star save];
                }
            }
                break;
            case TTLiveTypeMatch:
            {
                NSDictionary *data = [background tt_dictionaryValueForKey:@"match"];
                if (data) {
                    NSMutableDictionary *matchData = [[NSMutableDictionary alloc] initWithDictionary:data];
                    [matchData setValue:self.liveId forKey:@"id"];
                    self.match = [LiveMatch objectWithDictionary:matchData];
                    [self.match save];
                }
            }
                break;
            case TTLiveTypeVideo:
            {
                NSDictionary *data = [background tt_dictionaryValueForKey:@"video"];
                if (data) {
                    NSMutableDictionary *videoData = [[NSMutableDictionary alloc] initWithDictionary:data];
                    [videoData setValue:self.liveId forKey:@"id"];
                    self.video = [LiveVideo objectWithDictionary:videoData];
                    [self.video save];
                }
            }
                break;
            case TTLiveTypeSimple:
            {
                NSDictionary *data = [background tt_dictionaryValueForKey:@"simple"];
                if (data) {
                    NSMutableDictionary *simpleData = [[NSMutableDictionary alloc] initWithDictionary:data];
                    [simpleData setValue:self.liveId forKey:@"id"];
                    self.simple = [LiveSimple objectWithDictionary:simpleData];
                    [self.simple save];
                }
            }
            default:
                break;
        }
    }
    NSArray *filterWords = [dataDict objectForKey:@"filter_words"];
    if ([filterWords isKindOfClass:[NSArray class]])
    {
        self.filterWords = filterWords;
    }
}

- (LiveMatch *)match {
    if (!_match && self.liveId && [[self type] integerValue] == TTLiveTypeMatch) {
        _match = [LiveMatch objectForPrimaryKey:self.liveId];
    }
    return _match;
}

- (LiveStar *)star {
    if (!_star && self.liveId && [[self type] integerValue] == TTLiveTypeStar) {
        _star = [LiveStar objectForPrimaryKey:self.liveId];
    }
    return _star;
}

- (LiveVideo *)video {
    if (!_video && self.liveId && [[self type] integerValue] == TTLiveTypeVideo) {
        _video = [LiveVideo objectForPrimaryKey:self.liveId];
    }
    return _video;
}

- (LiveSimple *)simple {
    if (!_simple && self.liveId && [[self type] integerValue] == TTLiveTypeSimple) {
        _simple = [LiveSimple objectForPrimaryKey:self.liveId];
    }
    return _simple;
}

- (NSString *)picUrl {
    if (!isEmptyString(self.adCover)) {
        return self.adCover;
    }
    TTLiveType type = [[self type] integerValue];
    switch (type) {
        case TTLiveTypeStar:    return self.star.covers;
        case TTLiveTypeMatch:   return self.match.covers;
        case TTLiveTypeVideo:   return self.video.covers;
        case TTLiveTypeSimple:  return self.simple.covers;
        default:                return nil;
    }
    return nil;
}

- (void)updateWithDataContentObj:(NSDictionary *)dataDict {
    NSNumber *score1 = [NSNumber numberWithDouble:[dataDict tt_doubleValueForKey:@"score1"]];
    NSNumber *score2 = [NSNumber numberWithDouble:[dataDict tt_doubleValueForKey:@"score2"]];
    NSNumber *status = [NSNumber numberWithDouble:[dataDict tt_doubleValueForKey:@"status"]];
    NSNumber *liveId = [NSNumber numberWithDouble:[dataDict tt_doubleValueForKey:@"liveId"]];
    NSNumber *participated = [NSNumber numberWithDouble:[dataDict tt_doubleValueForKey:@"participated"]];
    NSString *statusDisplay = [dataDict tt_stringValueForKey:@"status_display"];
    NSString *title = [dataDict tt_stringValueForKey:@"title"];
    BOOL followed = [dataDict tt_boolValueForKey:@"followed"];
    if (liveId && self.liveId && [self.liveId isEqualToNumber:liveId]) {
        if (participated) {
            self.participated = participated;
        }
        if (status) {
            self.status = status;
        }
        if (statusDisplay) {
            self.statusDisplay = statusDisplay;
        }
        if (title) {
            self.title = title;
        }
        if (self.match && score1 && score2) {
            [self.match updateWithScore:score1 score2:score2];
        }
        self.followed = [NSNumber numberWithBool:followed];
    }
    
    self.needRefreshUI = YES;
    [self save];
}

+ (void)removeAllEntities {
    [super removeAllEntities];
    [LiveMatch removeAllEntities];
    [LiveStar removeAllEntities];
    [LiveVideo removeAllEntities];
    [LiveSimple removeAllEntities];
}

@end
