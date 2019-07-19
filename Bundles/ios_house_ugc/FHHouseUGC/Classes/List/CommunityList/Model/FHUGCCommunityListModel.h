//
// Created by zhulijun on 2019-07-18.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHUGCScialGroupModel.h"

@interface FHUGCCommunityListDataModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHUGCScialGroupDataModel> *socialGroupList;
@end

@interface FHUGCCommunityListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCCommunityListDataModel *data ;
@end
