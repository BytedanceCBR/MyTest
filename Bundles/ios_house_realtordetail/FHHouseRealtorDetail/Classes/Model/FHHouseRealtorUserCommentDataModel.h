//
//  FHHouseRealtorUserCommentDataModel.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "JSONModel.h"
@class FHHouseUserCommentsCell;
NS_ASSUME_NONNULL_BEGIN
@protocol FHHouseRealtorUserCommentItemModel <NSObject>

@end
@interface FHHouseRealtorUserCommentItemModel : JSONModel
@property (assign, nonatomic) CGFloat cellHeight;
@property (copy, nonatomic, nullable) NSString *id;
@property (copy, nonatomic, nullable) NSString *avatar_url;
@property (strong, nonatomic, nullable) NSDictionary *tags;
@property (copy, nonatomic, nullable) NSString *score;
@property (assign, nonatomic) NSInteger star_count;
@property (copy, nonatomic, nullable) NSString *time;
@property (copy, nonatomic, nullable) NSString *content;
@property (copy, nonatomic, nullable) NSString *layout_style;
@end

@interface FHHouseRealtorUserCommentModel : JSONModel
@property (nonatomic, assign ) NSInteger offset;
@property (nonatomic, assign ) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray <FHHouseRealtorUserCommentItemModel>*commentInfo;
@end

@interface FHHouseRealtorUserCommentDataModel : JSONModel
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseRealtorUserCommentModel *data ;
@end

NS_ASSUME_NONNULL_END
