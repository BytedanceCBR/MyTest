//
//  ExploreImageSubjectModel.m
//  Article
//
//  Created by SunJiangting on 15/7/27.
//
//

#import "ExploreImageSubjectModel.h"

@implementation ExploreImageSubjectModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self =  [super init];
    if (self) {
        self.title = [dictionary tt_stringValueForKey:@"sub_title"];
        self.abstract = [dictionary tt_stringValueForKey:@"sub_abstract"];
        NSDictionary *imageInfo = [dictionary tt_dictionaryValueForKey:@"sub_image"];
        self.imageModel = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
    }
    return self;
}

@end
