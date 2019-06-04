//
// Created by zhulijun on 2019-06-04.
//

#import <Foundation/Foundation.h>
#import "FHBaseModelProtocol.h"
#import "JSONModel.h"

@interface FHTopicListResponseItemModel : JSONModel

@property(nonatomic, copy, nullable) NSString *communityId;
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *subtitle;
@property(nonatomic, copy, nullable) NSString *des;

@end


@interface FHTopicListResponseDataModel : JSONModel

@property(nonatomic, strong, nullable) NSArray<FHTopicListResponseItemModel *> *items;

@end


@interface FHTopicListResponseModel : JSONModel <FHBaseModelProtocol>

@property(nonatomic, copy, nullable) NSString *status;
@property(nonatomic, copy, nullable) NSString *message;
@property(nonatomic, strong, nullable) FHTopicListResponseDataModel *data;

@end



