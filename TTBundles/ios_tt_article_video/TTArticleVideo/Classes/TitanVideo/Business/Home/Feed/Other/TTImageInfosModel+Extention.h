//
//  TTImageInfosModel+Extention.h
//  Article
//
//  Created by panxiang on 2017/3/8.
//
//

#import "TTImageInfosModel.h"
#import "PBModelHeader.h"

@interface TTImageInfosModel (Extention)
+ (NSDictionary *)dictionaryWithImageUrlList:(TTVImageUrlList *)urlList;
- (id)initWithImageUrlList:(TTVImageUrlList *)urlList;
@end
