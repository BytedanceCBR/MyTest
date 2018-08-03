//
//  TTGroupModel.h
//  Article
//
//  Created by SunJiangting on 15/6/29.
//
//

#import <Foundation/Foundation.h>

@interface TTGroupModel : NSObject <NSCoding>

@property(nonatomic, readonly, copy) NSString *itemID;
@property(nonatomic, readonly, copy) NSString *groupID;
@property(nonatomic, readonly, copy) NSString *impressionID;
@property(nonatomic, readonly, assign) NSInteger aggrType;

- (instancetype)initWithGroupID:(NSString *)groupID;

- (instancetype)initWithGroupID:(NSString *)groupID itemID:(NSString *)itemID impressionID:(NSString *)impressionID aggrType:(NSInteger)aggrType;

- (NSString *)impressionDescription;

//评论回复详情页
- (NSString *)replyImpressionDescription;

@end
