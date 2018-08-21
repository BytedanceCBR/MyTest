//
//  FRTipsEntity.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/30.
//
//

#import <Foundation/Foundation.h>
@class FRTipsStructModel;
@interface FRTipsEntity : NSObject

@property (strong, nonatomic) NSString *display_info;
@property (assign, nonatomic) int64_t display_duration;
@property (strong, nonatomic) NSString *click_url;

- (instancetype)initWithFromFRTipsStructModel:(FRTipsStructModel *)model;

@end
