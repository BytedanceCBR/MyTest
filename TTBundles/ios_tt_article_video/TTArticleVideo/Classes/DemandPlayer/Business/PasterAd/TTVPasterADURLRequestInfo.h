//
//  TTVPasterADURLRequestInfo.h
//  Article
//
//  Created by panxiang on 2017/6/12.
//
//

#import <Foundation/Foundation.h>

@interface TTVPasterADURLRequestInfo : NSObject

@property (nonatomic, copy) NSString *adFrom; // feed or textlink
@property (nonatomic, copy) NSString *groupID; // group_id
@property (nonatomic, copy) NSString *itemID; // item_id
@property (nonatomic, copy) NSString *category; // 频道

@end

