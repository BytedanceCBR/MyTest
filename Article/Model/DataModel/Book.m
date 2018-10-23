//
//  Book+CoreDataClass.m
//  Article
//
//  Created by 王双华 on 16/9/19.
//
//

#import "Book.h"
#import "NSDictionary+TTAdditions.h"
#import "ExploreCollectionBookCellModel.h"

@implementation Book

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                                                                                   @"bookList",
                                                                                   @"serialStyle",
                                                                                   @"moreInfo",
                                                                                   ]];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"bookList":@"book_list",
                       @"moreInfo":@"more_info",
                       @"serialStyle":@"serial_style",
                       };
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    [super updateWithDictionary:dataDict];
    
    self.bookList = [dataDict tt_arrayValueForKey:@"book_list"];
    
    self.serialStyle = @([dataDict tt_intValueForKey:@"serial_style"]);
    
    self.moreInfo = [dataDict tt_dictionaryValueForKey:@"more_info"];

}

- (NSArray *)bookListModels
{
    if (![self.bookList isKindOfClass:[NSArray class]] || [self.bookList count] == 0) {
        return nil;
    }
    NSMutableArray * ary = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary * dict in self.bookList) {
        if (!SSIsEmptyDictionary(dict)) {
            ExploreCollectionBookCellModel * model = [[ExploreCollectionBookCellModel alloc] initWithDictionary:dict];
            if (model) {
                [ary addObject:model];
            }
        }
    }
    return ary;
}

- (ExploreCollectionBookCellModel *)moreInfoModel
{
    if (SSIsEmptyDictionary(self.moreInfo)) {
        return nil;
    }
    ExploreCollectionBookCellModel * model = [[ExploreCollectionBookCellModel alloc] initWithDictionary:self.moreInfo];
    return model;
}


@end
