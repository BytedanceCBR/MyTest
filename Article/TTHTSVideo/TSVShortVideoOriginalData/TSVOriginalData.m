//
//  TSVOriginalData.m
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import "TSVOriginalData.h"

@implementation TSVOriginalData

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
    
    self.model = [[[self modelClass] alloc] initWithDictionary:dictionary error:nil];
}

- (id)model
{
    if (!_model) {
        _model = [[[self modelClass] alloc] initWithDictionary:self.originalDict error:nil];
    }
    return _model;
}

- (Class)modelClass
{
    return nil;
}

@end
