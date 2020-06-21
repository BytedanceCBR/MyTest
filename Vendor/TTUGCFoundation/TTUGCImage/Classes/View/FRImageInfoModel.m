//
//  FRImageInfoModel.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/27.
//
//

#import "FRImageInfoModel.h"
#import "TTImageInfosModel.h"
#import "NSDictionary+TTAdditions.h"
#import "TTBaseMacro.h"

#define kCommentImageSizeMaxRate 1.f/3.f
#define kCommentImageSizeMinRate 2.f/3.f

@implementation TTImageURLInfoModel

- (instancetype)initWithURL:(NSString *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.url = [dictionary objectForKey:@"url"];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"url"];
}

@end

@implementation FRImageInfoModel

+ (FRImageInfoModel *)genInfoModelFromStruct:(FRImageUrlStructModel *)model {
    if (!model) {
        return nil;
    }
    FRImageInfoModel * m = [[FRImageInfoModel alloc] init];
    m.height = model.height.longLongValue;
    m.width = model.width.longLongValue;
    m.uri = model.uri;
    m.url = model.url;
    m.type = model.type.integerValue;
    
    NSMutableArray<TTImageURLInfoModel> * realURLModels = (NSMutableArray <TTImageURLInfoModel> *)[NSMutableArray arrayWithCapacity:10];
    for (FRMagicUrlStructModel * urlM in model.url_list) {
        TTImageURLInfoModel * realURLModel = [[TTImageURLInfoModel alloc] init];
        realURLModel.url = urlM.url;
        [realURLModels addObject:realURLModel];
    }
    m.url_list = realURLModels;
    return m;
}

+ (NSArray<FRImageInfoModel> *)genInfoModelsForumStructs:(NSArray<FRImageUrlStructModel> *)structs
{
    NSMutableArray<FRImageInfoModel> * realModels = (NSMutableArray <FRImageInfoModel> *)[NSMutableArray arrayWithCapacity:10];
    for (FRImageUrlStructModel * stru in structs) {
        FRImageInfoModel * model = [self genInfoModelFromStruct:stru];
        if (model) {
            [realModels addObject:model];
        }
    }
    return realModels;
}

+ (FRImageUrlStructModel *)genUserIconStructModelFromInfoModel:(FRImageInfoModel *)infoModel {
    FRImageUrlStructModel * imageUrlStructModel = [[FRImageUrlStructModel alloc] init];
    imageUrlStructModel.height = @(infoModel.height);
    imageUrlStructModel.width = @(infoModel.width);
    imageUrlStructModel.uri = infoModel.uri;
    imageUrlStructModel.url = infoModel.url;
    imageUrlStructModel.type = @(infoModel.type);
    NSMutableArray <FRMagicUrlStructModel *> * magicUrlStructModels = [NSMutableArray arrayWithCapacity:3];
    [infoModel.url_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTImageURLInfoModel * imageUrlInfoModel = obj;
        if (!isEmptyString(imageUrlInfoModel.url)) {
            FRMagicUrlStructModel * magicUrlStructModel = [[FRMagicUrlStructModel alloc] init];
            magicUrlStructModel.url = imageUrlInfoModel.url;
            [magicUrlStructModels addObject:magicUrlStructModel];
        }
    }];
    if (magicUrlStructModels.count > 0) {
        imageUrlStructModel.url_list = magicUrlStructModels.copy;
    }
    
    return imageUrlStructModel;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.height = [dictionary tt_longlongValueForKey:@"height"];
        self.width = [dictionary tt_longlongValueForKey:@"width"];
        self.uri = [dictionary tt_stringValueForKey:@"uri"];
        self.url = [dictionary tt_stringValueForKey:@"url"];
        NSArray <NSDictionary *> *urlListDicArr = [dictionary tt_arrayValueForKey:@"url_list"];
        if ([urlListDicArr isKindOfClass:[NSArray class]] && urlListDicArr.count > 0) {
            NSMutableArray <TTImageURLInfoModel *> *urlLists = [NSMutableArray arrayWithCapacity:10];
            [urlListDicArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!SSIsEmptyDictionary(obj)) {
                    TTImageURLInfoModel *urlInfo = [[TTImageURLInfoModel alloc] initWithDictionary:obj];
                    [urlLists addObject:urlInfo];
                }
            }];
            self.url_list = [urlLists copy];
        }
        if (self.url_list.count == 0) {
            NSMutableArray <TTImageURLInfoModel *> *urlLists = [NSMutableArray arrayWithCapacity:1];
            TTImageURLInfoModel *urlInfo = [[TTImageURLInfoModel alloc] initWithURL:self.url];
            [urlLists addObject:urlInfo];
            self.url_list = [urlLists copy];
        }
        self.type = [[dictionary objectForKey:@"type"] integerValue];
    }
    return self;
}

- (instancetype)initWithTTImageInfosModel:(TTImageInfosModel *)TTImageInfosModel {
    self = [super init];
    if (self) {
        self.height = TTImageInfosModel.height;
        self.width = TTImageInfosModel.width;
        self.uri = TTImageInfosModel.URI;
        NSMutableArray<TTImageURLInfoModel *> *urlArrays = [[NSMutableArray alloc] init];
        [[TTImageInfosModel urlWithHeader] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)obj;
                NSString *URL = [dic tt_stringValueForKey:TTImageInfosModelURL];
                if (!isEmptyString(URL)) {
                    TTImageURLInfoModel *urlInfoModel = [[TTImageURLInfoModel alloc] initWithURL:URL];
                    if (urlInfoModel) {
                        [urlArrays addObject:urlInfoModel];
                    }
                }
            }
        }];
        if ([urlArrays count] > 0) {
            TTImageURLInfoModel *urlModel = [urlArrays firstObject];
            self.url = urlModel.url;
            self.url_list = [urlArrays copy];
        }
        else {
            self.url = TTImageInfosModel.URI;
        }
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)url {
    self = [super init];
    if (self) {
        if (!isEmptyString(url)) {
            self.height = 0;
            self.width = 0;
            self.uri = nil;
            self.url = url;
            NSMutableArray <TTImageURLInfoModel *> *urlLists = [NSMutableArray arrayWithCapacity:1];
            TTImageURLInfoModel *urlInfo = [[TTImageURLInfoModel alloc] initWithURL:url];
            [urlLists addObject:urlInfo];
            self.url_list = [urlLists copy];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.height = [[aDecoder decodeObjectForKey:@"height"] longLongValue];
        self.width = [[aDecoder decodeObjectForKey:@"width"] longLongValue];
        self.uri = [aDecoder decodeObjectForKey:@"uri"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.url_list = [aDecoder decodeObjectForKey:@"url_list"];
        self.type = [[aDecoder decodeObjectForKey:@"type"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_height) forKey:@"height"];
    [aCoder encodeObject:@(_width) forKey:@"width"];
    [aCoder encodeObject:_uri forKey:@"uri"];
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_url_list forKey:@"url_list"];
    [aCoder encodeObject:@(_type) forKey:@"type"];
}

- (NSURL *)_cacheKey
{
    NSURL * url = [NSURL URLWithString:self.url];
    if (!url) {
        url = [NSURL URLWithString:self.uri];
    }
    return url;
}

- (NSString *)urlStringAtIndex:(NSUInteger)index {
    if (index >= [_url_list count]) {
        return nil;
    }
    return [[_url_list objectAtIndex:index] valueForKey:@"url"];
}

+ (NSDictionary *)dictionaryForImageInfoModel:(FRImageInfoModel *)imageInfoModel {
    if (!imageInfoModel) {
        return nil;
    }
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
    [imageDict setValue:imageInfoModel.uri forKey:@"uri"];
    [imageDict setValue:imageInfoModel.url forKey:@"url"];
    [imageDict setValue:@(imageInfoModel.width) forKey:@"width"];
    [imageDict setValue:@(imageInfoModel.height) forKey:@"height"];

    NSMutableArray *urlListArray = [[NSMutableArray alloc] init];
    for (TTImageURLInfoModel *urlInfoModel in imageInfoModel.url_list) {
        if (!isEmptyString(urlInfoModel.url)) {
            NSMutableDictionary *urlDict = [[NSMutableDictionary alloc] init];
            [urlDict setValue:urlInfoModel.url forKey:@"url"];

            if (!SSIsEmptyDictionary(urlDict)) {
                [urlListArray addObject:urlDict];
            }
        }
    }
    if (!SSIsEmptyArray(urlListArray)) {
        [imageDict setValue:urlListArray forKey:@"url_list"];
    }

    if (!SSIsEmptyDictionary(imageDict)) {
        return imageDict;
    }
    return nil;
}

+ (CGSize)commentImageFilterSize:(CGSize)originSize {

    if (originSize.height <= 0 || originSize.width <= 0) {
        return CGSizeZero;
    }

    CGSize filterSize = CGSizeZero;
    CGFloat filterWidth = 0;
    CGFloat filterHeight = 0;

    CGFloat commentImageStandardSize = ([[UIScreen mainScreen] bounds].size.width - 60) / 2.f;

//    CGFloat originWidth = originSize.width / 2.f;
//    CGFloat originHeight = originSize.height / 2.f;

    CGFloat originWidth = originSize.width;
    CGFloat originHeight = originSize.height;

    if (originHeight < commentImageStandardSize && originWidth < commentImageStandardSize) {
        filterWidth = originWidth;
        filterHeight = originHeight;
    } else if (originHeight >= originWidth) {

        if (originHeight * kCommentImageSizeMaxRate > originWidth) {

            filterWidth = (commentImageStandardSize * 2.f) / 3.f;
            filterHeight = commentImageStandardSize + (commentImageStandardSize * 1.f)/ 3.f;

        } else {

            filterHeight = commentImageStandardSize;
            filterWidth = (CGFloat) (commentImageStandardSize * originWidth / originHeight);
        }

    } else {
        if (originWidth * kCommentImageSizeMaxRate > originHeight) {

            filterHeight = (commentImageStandardSize * 2.f) / 3.f;
            filterWidth = commentImageStandardSize + (commentImageStandardSize * 1.f)/ 3.f;

        }  else {

            filterWidth = commentImageStandardSize;
            filterHeight = (CGFloat) (commentImageStandardSize * originHeight / originWidth);
        }
    }

    filterSize = CGSizeMake(filterWidth, filterHeight);

    return filterSize;
}

- (NSUInteger)hash
{
    return [[self _cacheKey].absoluteString hash];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[FRImageInfoModel class]]) {
        return NO;
    }
    if (object == self) {
        return YES;
    }
    FRImageInfoModel *toObject = (FRImageInfoModel *)object;
    if (toObject.height == self.height &&
        toObject.width == self.width &&
        [toObject.url isEqualToString:self.url] &&
        [toObject.uri isEqualToString:self.uri] ) {
        //这么写其实是不对的。
        return YES;
    }
    return NO;
}

@end

@implementation TTRichTextImageInfoModel (FRImageInfoModel)

- (FRImageInfoModel *)toImageInfoModel {
    return [[FRImageInfoModel alloc] initWithDictionary:[self toDictionary]];
}

+ (NSArray<FRImageInfoModel *> *)convertImageInfoModels:(NSArray<TTRichTextImageInfoModel *> *)richImageInfoModels {
    if (richImageInfoModels.count == 0) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:richImageInfoModels.count];
    for (TTRichTextImageInfoModel *model in richImageInfoModels) {
        if ([model isKindOfClass:[TTRichTextImageInfoModel class]]) {
            [result addObject:[[FRImageInfoModel alloc] initWithDictionary:[model toDictionary]]];
        }
    }
    return [result copy];
}

@end
