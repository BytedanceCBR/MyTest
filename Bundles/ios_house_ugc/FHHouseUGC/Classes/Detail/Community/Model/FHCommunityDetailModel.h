//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

@interface FHCommunityDetailDataModel : JSONModel
@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic) BOOL followed;
@property(nonatomic, copy) NSString *avatar;
@property(nonatomic, copy) NSString *publications;
@end

@interface FHCommunityDetailModel : JSONModel <FHBaseModelProtocol>

@property(nonatomic, copy, nullable) NSString *status;
@property(nonatomic, copy, nullable) NSString *message;
@property(nonatomic, strong, nullable) FHCommunityDetailDataModel *data;

@end