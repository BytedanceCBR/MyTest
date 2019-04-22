//
//  TTImageInfosModel+Extention.m
//  Article
//
//  Created by panxiang on 2017/3/8.
//
//

#import "TTImageInfosModel+Extention.h"

@implementation TTImageInfosModel (Extention)

+ (NSDictionary *)dictionaryWithImageUrlList:(TTVImageUrlList *)urlList
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:3];
    [urlList.URLListArray enumerateObjectsUsingBlock:^(TTVAUrl  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTVAUrl class]]) {
            if (obj.URL) {
                [urls addObject:[NSDictionary dictionaryWithObject:obj.URL forKey:@"url"]];
            }
        }
    }];
    
    [dic setValue:urls forKey:@"url_list"];
    [dic setValue:urlList.uri forKey:@"uri"];
    [dic setValue:urlList.URL forKey:@"url"];
    [dic setValue:@(urlList.width) forKey:@"width"];
    [dic setValue:@(urlList.height) forKey:@"height"];
    return [dic copy];
}

- (instancetype)initWithImageUrlList:(TTVImageUrlList *)urlList
{
    NSDictionary *dic = [[self class] dictionaryWithImageUrlList:urlList];
    self = [self initWithDictionary:dic];
    if (self) {
    }
    return self;
}

@end
