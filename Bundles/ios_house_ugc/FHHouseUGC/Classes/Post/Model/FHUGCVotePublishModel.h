//
//  FHUGCVotePublishModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VoteType) {
    VoteType_SingleSelect,
    VoteType_MultipleSelect,
};

@interface FHUGCVotePublishCityInfo: NSObject
@property (nonatomic, copy) NSString *socialGroupId;
@property (nonatomic, copy) NSString *socialGroupName;
@end

@interface FHUGCVotePublishModel : NSObject
@property (nonatomic, strong) FHUGCVotePublishCityInfo *cityInfo;
@property (nonatomic, copy) NSString *voteTitle;
@property (nonatomic, copy) NSString *voteDescription;
@property (nonatomic, strong) NSMutableArray<NSString *> *options;
@property (nonatomic, assign) VoteType type;
@property (nonatomic, strong) NSDate *deadline;
@end

NS_ASSUME_NONNULL_END
