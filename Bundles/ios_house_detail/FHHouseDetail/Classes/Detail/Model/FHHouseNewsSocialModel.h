//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHUGCScialGroupModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseNewsSocialSocialActiveInfoModel<NSObject>
@end

@interface FHHouseNewsSocialSocialActiveInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *title;
@end

@interface FHHouseNewsSocialAssociateActiveInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *associateLinkShowType;
@property (nonatomic, strong , nullable) NSArray<FHHouseNewsSocialSocialActiveInfoModel> *activeInfo;
@property (nonatomic, copy , nullable) NSString *associateLinkTitle;
@end

@interface FHHouseNewsSocialModel : JSONModel 

@property (nonatomic, strong , nullable) FHHouseNewsSocialAssociateActiveInfoModel *associateActiveInfo ;  
@property (nonatomic, strong , nullable) FHUGCScialGroupDataModel *socialGroupInfo ;  
@property (nonatomic, copy , nullable) NSString *groupChatLinkTitle;
@property (nonatomic, strong , nullable) NSArray<FHHouseNewsSocialSocialActiveInfoModel> *socialActiveInfo;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
