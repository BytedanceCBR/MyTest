//
//  TTVideoPasterADService.h
//  Article
//
//  Created by lijun.thinker on 2017/3/22.
//
//

#import <Foundation/Foundation.h>

typedef void(^fetchPasterADInfoCompletion)(id response,NSError *error);

@class TTVideoPasterADURLRequestInfo;
@interface TTVideoPasterADService : NSObject

- (void)fetchPasterADInfoWithRequestInfo:(TTVideoPasterADURLRequestInfo *)requestInfo completion:(fetchPasterADInfoCompletion)completion;

@end

@interface TTVideoPasterADURLRequestInfo : NSObject

@property (nonatomic, copy) NSString *adFrom; // feed or textlink
@property (nonatomic, copy) NSString *groupID; // group_id
@property (nonatomic, copy) NSString *itemID; // item_id
@property (nonatomic, copy) NSString *category; // 频道

@end
