//
//  ArticleMomentMomoModel.h
//  Article
//
//  Created by SunJiangting on 15/6/15.
//
//

#import "SSBaseModel.h"

@interface ArticleMomentMomoModel : SSBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property(nonatomic, assign)NSTimeInterval cursor;

@end
