//
//  TSVRecUserCardOriginalData.m
//  Article
//
//  Created by 王双华 on 2017/9/25.
//

#import "TSVRecUserCardOriginalData.h"

@implementation TSVRecUserCardOriginalData

+ (NSString *)dbName
{
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties
{
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"originalDict",
                       ];
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    [super updateWithDictionary:dictionary];
    
    self.originalDict = dictionary;
    self.cardModel = [[TSVRecUserCardModel alloc] initWithDictionary:self.originalDict error:nil];
}

- (TSVRecUserCardModel *)cardModel
{
    if (!_cardModel) {
        _cardModel = [[TSVRecUserCardModel alloc] initWithDictionary:self.originalDict error:nil];
    }
    return _cardModel;
}

@end
