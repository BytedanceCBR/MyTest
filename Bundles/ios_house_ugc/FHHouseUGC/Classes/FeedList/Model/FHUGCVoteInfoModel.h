//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHUGCVoteInfoVoteInfoItemsModel<NSObject>
@end

@interface FHUGCVoteInfoVoteInfoItemsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *voteCount;
@property (nonatomic, assign) BOOL selected;
@end

@interface FHUGCVoteInfoVoteInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *voteId;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *richContent;
@property (nonatomic, strong , nullable) NSArray<FHUGCVoteInfoVoteInfoItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *voteType;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy , nullable) NSString *userCount;
@property (nonatomic, copy , nullable) NSString *deadline;
@property (nonatomic, copy , nullable) NSString *displayCount;
@property (nonatomic, copy , nullable) NSString *desc;

@property (nonatomic, copy , nullable) NSString *contentAStr;
@property (nonatomic, assign) CGFloat contentHeight;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
