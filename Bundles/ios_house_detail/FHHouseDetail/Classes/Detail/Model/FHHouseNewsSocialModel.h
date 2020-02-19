//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
#import "FHUGCScialGroupModel.h"
#import "FHDetailBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseNewsSocialAssociateActiveInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *associateLinkShowType;
@property (nonatomic, strong , nullable) NSArray<FHDetailCommunityEntryActiveInfoModel> *activeInfo;
@property (nonatomic, copy , nullable) NSString *associateLinkTitle;
@property (nonatomic, copy , nullable) NSString *associateContentTitle;
@end

@interface FHHouseNewsSocialModel : JSONModel 

@property (nonatomic, strong , nullable) FHHouseNewsSocialAssociateActiveInfoModel *associateActiveInfo ;  
@property (nonatomic, strong , nullable) FHUGCScialGroupDataModel *socialGroupInfo ;  
@property (nonatomic, copy , nullable) NSString *groupChatLinkTitle;
@property (nonatomic, strong , nullable) NSArray<FHDetailCommunityEntryActiveInfoModel> *socialActiveInfo;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
