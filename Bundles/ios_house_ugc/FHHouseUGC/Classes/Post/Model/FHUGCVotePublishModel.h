//
//  FHUGCVotePublishModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define OPTION_LENGTH_LIMIT      15
#define TITLE_LENGTH_LIMIT       40
#define DESCRIPTION_LENGTH_LIMIT 100
#define OPTION_COUNT_MAX         10
#define OPTION_COUNT_MIN         2


typedef NS_ENUM(NSInteger, VoteType) {
    VoteType_Unknown = 0,
    VoteType_SingleSelect = 1,
    VoteType_MultipleSelect = 2,
};

typedef NS_ENUM(NSInteger, VisibleType) {
    VisibleType_Unknown = 0,
    VisibleType_Group = 1,
    VisibleType_All = 2,
};

@interface FHUGCVotePublishCityInfo: NSObject
@property (nonatomic, copy) NSString *socialGroupId;
@property (nonatomic, copy) NSString *socialGroupName;
@end

@interface FHUGCVotePublishOption: NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL isValid;

+ (instancetype)defaultOption;
@end

@interface FHUGCVotePublishModel : NSObject
@property (nonatomic, assign) BOOL isAllSelected;
@property (nonatomic, assign) BOOL isPartialSelected;
@property (nonatomic, assign) VisibleType visibleType;
@property (nonatomic, strong) NSArray<FHUGCVotePublishCityInfo *> *cityInfos;
@property (nonatomic, copy) NSString *voteTitle;
@property (nonatomic, copy) NSString *voteDescription;
@property (nonatomic, strong) NSMutableArray<FHUGCVotePublishOption *> *options;
@property (nonatomic, assign) VoteType type;
@property (nonatomic, strong) NSDate *deadline;
@end

NS_ASSUME_NONNULL_END
