//
//  FRGroupEntity.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/28.
//
//

#import <Foundation/Foundation.h>
#import "FRApiModel.h"

@interface FRGroupEntity : NSObject

@property (assign, nonatomic) int64_t group_id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *thumb_url;
@property (assign, nonatomic) FRGroupMediaType media_type;
@property (nonatomic, strong) NSString * open_url;

+ (FRGroupEntity *)genFromStruct:(FRGroupStructModel *)model;

@end
