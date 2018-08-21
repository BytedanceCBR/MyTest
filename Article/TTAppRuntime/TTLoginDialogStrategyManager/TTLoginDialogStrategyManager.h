//
//  TTLoginDialogStrategyManager.h
//  Article
//
//  Created by wangdi on 2017/6/16.
//
//

#import <Foundation/Foundation.h>
#import "JsonModel.h"

@interface TTLoginDialogModel : JSONModel

@property (nonatomic, strong) NSArray *action_tick;
@property (nonatomic, strong) NSNumber *action_type;
@property (nonatomic, strong) NSNumber *action_total;

@end

@interface TTLoginDialogStrategyManager : NSObject

+ (instancetype)sharedInstance;
- (void)setBootDataWithDictionary:(NSDictionary *)dict;
- (void)setDislikeDataWithDictionary:(NSDictionary *)dict;
- (void)setMyFavorDataWithDictionary:(NSDictionary *)dict;
- (void)setPushHistoryDataWithDictionary:(NSDictionary *)dict;
- (void)setLoginDialogData:(NSDictionary *)loginDialogStrategyDict;

- (void)setMyFavorEnable:(NSNumber *)enable;
- (BOOL)myFavorEnable;
- (void)setPushHistoryEnable:(NSNumber *)enable;
- (BOOL)pushHistoryEnable;

- (void)setMyFavorEnterTime:(NSInteger)time;
- (NSInteger)myFavorEnterTime;
- (void)setPushHistoryEnterTime:(NSInteger)time;
- (NSInteger)pushHistoryEnterTime;

- (void)setBootTime:(NSInteger)time;
- (NSInteger)bootTime;
- (void)setDislikeTime:(NSInteger)time;
- (NSInteger)dislikeTime;

- (void)setBootTotalTime:(NSInteger)bootTotalTime;
- (NSInteger)bootTotalTime;
- (void)setDislikeTotalTime:(NSInteger)dislikeTotalTime;
- (NSInteger)dislikeTotalTime;
- (void)setMyFavorTotalTime:(NSInteger)myFavorTotalTime;
- (NSInteger)myFavorTotalTime;
- (void)setPushHistoryTotalTime:(NSInteger)pushHistoryTotalTime;
- (NSInteger)pushHistoryTotalTime;


- (TTLoginDialogModel *)bootModel;
- (TTLoginDialogModel *)disLikeModel;
- (TTLoginDialogModel *)myFavorModel;
- (TTLoginDialogModel *)pushHistoryModel;

- (void)setFeedDislikeTime;

- (BOOL)myFavorShouldShowDialogIfNeeded;
- (BOOL)pushHistoryShouldShowDialogIfNeeded;

@end
