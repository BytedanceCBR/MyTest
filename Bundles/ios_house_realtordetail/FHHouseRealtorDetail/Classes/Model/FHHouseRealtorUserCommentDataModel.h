//
//  FHHouseRealtorUserCommentDataModel.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface FHHouseRealtorUserCommentModel : JSONModel
@property (nonatomic, assign ) NSInteger offset;
@property (nonatomic, assign ) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray *commentInfo;
@end

@interface FHHouseRealtorUserCommentDataModel : JSONModel
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseRealtorUserCommentModel *data ;
@end

NS_ASSUME_NONNULL_END
