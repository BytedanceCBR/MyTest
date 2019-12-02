//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHUGCVoteInfoVoteInfoItemsModel<NSObject>
@end

@interface FHUGCVoteInfoVoteInfoItemsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *index;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *voteCount;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign)   double percent;// 百分比
@end

typedef enum : NSUInteger {
    FHUGCVoteStateNone,// 未投票
    FHUGCVoteStateVoting, // 投票中
    FHUGCVoteStateComplete, // 完成投票
    FHUGCVoteStateExpired,// 投票过期
} FHUGCVoteState;

@interface FHUGCVoteInfoVoteInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *voteId;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *richContent;
@property (nonatomic, strong , nullable) NSArray<FHUGCVoteInfoVoteInfoItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *voteType;// 单选:1 多选：2
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy , nullable) NSString *userCount;
@property (nonatomic, copy , nullable) NSString *deadline;
@property (nonatomic, copy , nullable) NSString *displayCount;
@property (nonatomic, copy , nullable) NSString *desc;

@property (nonatomic, copy , nullable) NSString *contentAStr;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat descHeight;
@property (nonatomic, assign) CGFloat voteHeight;// 投票height

@property (nonatomic, assign)   BOOL       needAnimateShow;
@property (nonatomic, assign)   BOOL       needFold;// 需要折叠展开，默认NO
@property (nonatomic, assign)   BOOL       isFold;// 当前折叠展开 状态 默认 NO（展开）
@property (nonatomic, assign)   FHUGCVoteState       voteState;// 投票状态
@property (nonatomic, assign)   BOOL       hasReloadForVoteExpired;
@property (nonatomic, copy)     NSString       *deadLineContent;// 还有X天结束

@end


NS_ASSUME_NONNULL_END
//END OF HEADER
