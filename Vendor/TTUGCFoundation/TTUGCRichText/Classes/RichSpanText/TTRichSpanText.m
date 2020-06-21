//
//  TTRichSpanText.m
//  Article
//
//  Created by 徐霜晴 on 17/3/13.
//
//

#import "TTRichSpanText.h"
#import "TTBaseMacro.h"
#import <objc/runtime.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "Base64.h"

@implementation TTRichTextImageURLInfoModel

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

@end

@implementation TTRichTextImageInfoModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.height = [dictionary tt_longlongValueForKey:@"height"];
        self.width = [dictionary tt_longlongValueForKey:@"width"];
        self.uri = [dictionary tt_stringValueForKey:@"uri"];
        self.url = [dictionary tt_stringValueForKey:@"url"];
        NSArray <NSDictionary *> *urlListDicArr = [dictionary tt_arrayValueForKey:@"url_list"];
        if ([urlListDicArr isKindOfClass:[NSArray class]] && urlListDicArr.count > 0) {
            NSMutableArray <TTRichTextImageURLInfoModel *> *urlLists = [NSMutableArray arrayWithCapacity:10];
            [urlListDicArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!SSIsEmptyDictionary(obj)) {
                    TTRichTextImageURLInfoModel *urlInfo = [[TTRichTextImageURLInfoModel alloc] initWithDictionary:obj];
                    [urlLists addObject:urlInfo];
                }
            }];
            self.url_list = [urlLists copy];
        }
        if (self.url_list.count == 0) {
            NSMutableArray <TTRichTextImageURLInfoModel *> *urlLists = [NSMutableArray arrayWithCapacity:1];
            TTRichTextImageURLInfoModel *urlInfo = [[TTRichTextImageURLInfoModel alloc] initWithURL:self.url];
            [urlLists addObject:urlInfo];
            self.url_list = [urlLists copy];
        }
        self.type = [[dictionary objectForKey:@"type"] intValue];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
    [imageDict setValue:self.uri forKey:@"uri"];
    [imageDict setValue:self.url forKey:@"url"];
    [imageDict setValue:@(self.width) forKey:@"width"];
    [imageDict setValue:@(self.height) forKey:@"height"];
    
    NSMutableArray *urlListArray = [[NSMutableArray alloc] init];
    for (TTRichTextImageURLInfoModel *urlInfoModel in self.url_list) {
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

@end

@interface TTRichSpanImage ()

@property (nonatomic, strong) NSDictionary *originDictionary;

@end

@implementation TTRichSpanImage

- (instancetype) initWithDictionary:(NSDictionary *)imageDictionary {
    self = [super init];
    if (self) {
        self.originDictionary = imageDictionary;
        self.uri = [imageDictionary tt_stringValueForKey:@"u"];
        self.height = [imageDictionary tt_floatValueForKey:@"h"];
        self.width = [imageDictionary tt_floatValueForKey:@"w"];
        self.format = [imageDictionary tt_stringValueForKey:@"f"];
    }
    return self;
}

- (NSDictionary *)imageInfoDictionary {
    if (!SSIsEmptyDictionary(self.originDictionary)) {
        return self.originDictionary;
    }
    
    NSMutableDictionary *imageDictionary = [[NSMutableDictionary alloc] init];
    [imageDictionary setValue:self.uri forKey:@"u"];
    [imageDictionary setValue:@(self.height) forKey:@"h"];
    [imageDictionary setValue:@(self.width) forKey:@"w"];
    [imageDictionary setValue:self.format forKey:@"f"];
    
    return [imageDictionary copy];
}

@end

@interface TTRichSpanLink ()

@property (nonatomic, assign) NSUInteger start;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSArray<TTRichSpanImage*> *imageInfoModels;
@property (nonatomic, assign) TTRichSpanLinkFlagType flagType;
@property (nonatomic, strong) NSDictionary *originDictionary;

@property (nonatomic, assign) TTRichSpanLinkType type;
@end

@implementation TTRichSpanLink

- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link {
    return [self initWithStart:start length:length link:link text:nil imageInfoModels:nil type:TTRichSpanLinkTypeUnknown flagType:TTRichSpanLinkFlagTypeDefault];
}

- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link text:(NSString *)text type:(TTRichSpanLinkType)type {
    return [self initWithStart:start length:length link:link text:text imageInfoModels:nil type:type flagType:TTRichSpanLinkFlagTypeDefault];
}

- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link text:(NSString *)text imageInfoDicts:(NSArray<NSDictionary *> *)imageInfoDicts type:(TTRichSpanLinkType)type flagType:(TTRichSpanLinkFlagType)flagType {
    
    NSMutableArray *imageInfoMutableArray = [[NSMutableArray alloc] init];
    if (!SSIsEmptyArray(imageInfoDicts)) {
        for (NSDictionary *imageInfoDict in imageInfoDicts) {
            if (!SSIsEmptyDictionary(imageInfoDict)) {
                TTRichSpanImage *imageInfoModel = [[TTRichSpanImage alloc] initWithDictionary:imageInfoDict];
                if (imageInfoDict) {
                    [imageInfoMutableArray addObject:imageInfoModel];
                }
            }
        }
    }
    NSArray *imageInfoArray = nil;
    if (!SSIsEmptyArray(imageInfoMutableArray)) {
        imageInfoArray = [imageInfoMutableArray copy];
    }
    return [self initWithStart:start length:length link:link text:text imageInfoModels:imageInfoArray type:type flagType:flagType];
}

- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link text:(NSString *)text imageInfoModels:(NSArray<TTRichSpanImage*> *)imageInfoModels type:(TTRichSpanLinkType)type flagType:(TTRichSpanLinkFlagType)flagType {
    self = [super init];
    if (self) {
        _start = start;
        _length = length;
        _link = [link copy];
        _text = [text copy];
        _type = type;
        _flagType = flagType;
        if (_type == TTRichSpanLinkTypeImage) {
            if (isEmptyString(_text)) {
                _text = @"查看图片";
            }
        }
        //对于type == TTRichSpanLinkTypeImage 但是 imageInfoModel为空的情况，需要特殊处理么？？？？？？？？？？
        _imageInfoModels = imageInfoModels;
    }
    return self;
}

+ (NSDictionary *)dictionaryForRichSpanLink:(TTRichSpanLink *)link {
    NSMutableDictionary *richSpanLinkDict = nil;
    if (!SSIsEmptyDictionary(link.originDictionary)) {
        richSpanLinkDict = [link.originDictionary mutableCopy];
    }
    if (richSpanLinkDict == nil) {
        richSpanLinkDict = [NSMutableDictionary dictionary];
    }
    
    {
        NSMutableDictionary *dict = richSpanLinkDict;
        [dict setValue:@(link.start) forKey:@"start"];
        [dict setValue:@(link.length) forKey:@"length"];
        if (link.link) {
            [dict setValue:link.link forKey:@"link"];
        }
        if (link.text) {
            [dict setValue:link.text forKey:@"text"];
        }
        if (!SSIsEmptyArray(link.imageInfoModels)) {
            NSMutableArray *imageInfoDictArray = [[NSMutableArray alloc] init];
            for (TTRichSpanImage *imageInfoModel in link.imageInfoModels) {
                NSDictionary *imageInfoDict = [imageInfoModel imageInfoDictionary];
                if (!SSIsEmptyDictionary(imageInfoDict)) {
                    [imageInfoDictArray addObject:imageInfoDict];
                }
            }
            if (!SSIsEmptyArray(imageInfoDictArray)) {
                [dict setValue:imageInfoDictArray forKey:@"image"];
            }
        }
        
        
        
        [dict setValue:@(link.flagType) forKey:@"flag"];
        
        if (link.type != TTRichSpanLinkTypeUnknown && link.type != TTRichSpanLinkTypeQuotedCommentUser && link.type != TTRichSpanLinkTypeAutoDetectLink) {
            [dict setValue:@(link.type) forKey:@"type"];
        }

        if (!SSIsEmptyDictionary(link.userInfo)) {
            [dict setValue:link.userInfo forKey:@"user_info"];
        }
        
        if(link.idStr) {
            [dict setValue:link.idStr forKey:@"id_str"];
        }
    }
    
    return [richSpanLinkDict copy];
}

+ (NSArray<NSDictionary *> *)arrayForRichSpanLinks:(NSArray<TTRichSpanLink *> *)links {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = [self dictionaryForRichSpanLink:obj];
        [array addObject:dic];
    }];
    return [array copy];
}

+ (NSString *)JSONStringForRichSpanLinks:(NSArray<TTRichSpanLink *> *)links {
    NSArray *spanDicArray = [self arrayForRichSpanLinks:links];
    if (!spanDicArray) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:spanDicArray options:0 error:&error];
    if (!jsonData) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (TTRichSpanLink *)richSpanLinkForDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (![dictionary objectForKey:@"start"] || ![dictionary objectForKey:@"length"]) {
        return nil;
    }
    
    NSMutableDictionary *richSpanDict = [[NSMutableDictionary alloc] init];
    [richSpanDict addEntriesFromDictionary:dictionary];
    
    if ([richSpanDict tt_integerValueForKey:@"type"] == TTRichSpanLinkTypeQuotedCommentUser) {
        [richSpanDict setValue:@(TTRichSpanLinkTypeUnknown) forKey:@"type"];
    }
    
    TTRichSpanLink *richSpanLink = [[TTRichSpanLink alloc] initWithStart:[richSpanDict tt_integerValueForKey:@"start"]
                                                                  length:[richSpanDict tt_integerValueForKey:@"length"]
                                                                    link:[richSpanDict tt_stringValueForKey:@"link"]
                                                                    text:[richSpanDict tt_stringValueForKey:@"text"]
                                                          imageInfoDicts:[richSpanDict tt_arrayValueForKey:@"image"]
                                                                    type:[richSpanDict tt_integerValueForKey:@"type"]
                                                                flagType:[richSpanDict tt_integerValueForKey:@"flag"]];
    richSpanLink.userInfo = [richSpanDict tt_dictionaryValueForKey:@"user_info"];
    richSpanLink.idStr = [richSpanDict tt_stringValueForKey:@"id_str"];
    richSpanLink.originDictionary = [richSpanDict copy];
    
    return richSpanLink;
}

+ (NSArray<TTRichSpanLink *> *)richSpanLinksForDictionaries:(NSArray<NSDictionary *>*)linkDictionaries {
    if (!linkDictionaries || ![linkDictionaries isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray<TTRichSpanLink *> *richSpanLinks = [[NSMutableArray alloc] initWithCapacity:[linkDictionaries count]];
    [linkDictionaries enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTRichSpanLink *richSpanLink = [self richSpanLinkForDictionary:obj];
        if (richSpanLink) {
            [richSpanLinks addObject:richSpanLink];
        }
    }];
    return [richSpanLinks copy];
}

+ (NSArray<TTRichSpanLink *> *)richSpanLinksForJSONString:(NSString *)linksJSONString {
    if (!isEmptyString(linksJSONString)) {
        return nil;
    }
    NSData *data = [linksJSONString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    NSError *error;
    NSArray *richSpansArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!richSpansArray) {
        return nil;
    }
    return [self richSpanLinksForDictionaries:richSpansArray];
}

@end

static NSString * const TTRichSpansKeyLinks = @"links";
static NSString * const TTRichSpansKeyImageList = @"image_list";

@interface TTRichSpans ()

@property (nonatomic, strong, readwrite) NSMutableArray<TTRichSpanLink *> *innerLinks;

@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, TTRichTextImageInfoModel *> *innerImageInfoModesDict;

@property (nonatomic, strong) NSDictionary *originDictionary;

@end

@implementation TTRichSpans

- (instancetype)initWithRichSpanLinks:(NSArray<TTRichSpanLink *> *)links imageInfoModelsDict:(NSDictionary<NSString *, TTRichTextImageInfoModel *> *)imageInfoModeDict {
    self = [super init];
    if (self) {
        self.innerLinks = [[NSMutableArray alloc] init];
        if (!SSIsEmptyArray(links)) {
            [self.innerLinks addObjectsFromArray:links];
        }
        self.innerImageInfoModesDict = [[NSMutableDictionary alloc] init];
        if (!SSIsEmptyDictionary(imageInfoModeDict)) {
            [self.innerImageInfoModesDict addEntriesFromDictionary:imageInfoModeDict];
        }
    }
    return self;
}

- (NSArray<TTRichSpanLink *> *)links {
    return [self.innerLinks copy];
}

- (NSDictionary<NSString *, TTRichTextImageInfoModel *> *)imageInfoModesDict {
    return [self.innerImageInfoModesDict copy];
}

- (NSArray<TTRichTextImageInfoModel *> *)imageInfoModelArray {
    NSMutableArray *imageInfoMutableArray = [[NSMutableArray alloc] init];
    [self.imageInfoModesDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TTRichTextImageInfoModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[TTRichTextImageInfoModel class]]) {
            [imageInfoMutableArray addObject:obj];
        }
    }];
    NSArray *imageInfoArray = nil;
    if (!SSIsEmptyArray(imageInfoMutableArray)) {
        imageInfoArray = [imageInfoMutableArray copy];
    }
    return imageInfoArray;
}

- (TTRichTextImageInfoModel *)imageInfoModelWithURI:(NSString *)imageUri {
    if (isEmptyString(imageUri)) {
        return nil;
    }
    
    TTRichTextImageInfoModel *imageInfoMode = [self.imageInfoModesDict tt_objectForKey:imageUri];
    if (imageInfoMode && [imageInfoMode isKindOfClass:[TTRichTextImageInfoModel class]]) {
        return imageInfoMode;
    }
    return nil;
}

- (NSArray<TTRichTextImageInfoModel *> *)imageInfoModelArrayWithRichSpanLink:(TTRichSpanLink *)richSpanLink {
    if (!richSpanLink) {
        return nil;
    }
    
    NSMutableArray *imageInfoModels = [[NSMutableArray alloc] init];
    
    NSArray<TTRichSpanImage*> *richImageInfos = richSpanLink.imageInfoModels;
    
    [richImageInfos enumerateObjectsUsingBlock:^(TTRichSpanImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[TTRichSpanImage class]] && !isEmptyString(obj.uri)) {
            TTRichTextImageInfoModel *imageInfoModel = [self.innerImageInfoModesDict tt_objectForKey:obj.uri];
            if (imageInfoModel) {
                [imageInfoModels addObject:imageInfoModel];
            }
        }
    }];
    
    if (!SSIsEmptyArray(imageInfoModels)) {
        return [imageInfoModels copy];
    }
    
    return nil;
}

+ (NSDictionary *)dictionaryForRichSpans:(TTRichSpans *)richSpans {
    
    NSMutableDictionary *richSpanDictionary = nil;
    
    //首先使用原始的dictionary
    if (!SSIsEmptyDictionary(richSpans.originDictionary)) {
        richSpanDictionary = [richSpans.originDictionary mutableCopy];
    }
    if (richSpanDictionary == nil) {
        richSpanDictionary = [NSMutableDictionary dictionary];
    }
    // 然后更新覆盖
    {
        
        NSMutableDictionary *richSpansMutableDic = richSpanDictionary;
        NSArray<NSDictionary *> *links = [TTRichSpanLink arrayForRichSpanLinks:richSpans.links];
        if (!SSIsEmptyArray(links)) {
            [richSpansMutableDic setValue:links forKey:TTRichSpansKeyLinks];
        }
        
        NSMutableDictionary *dictForImageInfoDict = [[NSMutableDictionary alloc] init];
        [richSpans.imageInfoModesDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TTRichTextImageInfoModel * _Nonnull obj, BOOL * _Nonnull stop) {
            if([key isKindOfClass:[NSString class]] && !isEmptyString(key) && [obj isKindOfClass:[TTRichTextImageInfoModel class]]) {
                NSDictionary *imageInfoDict = [obj toDictionary];
                if (!SSIsEmptyDictionary(imageInfoDict)) {
                    [dictForImageInfoDict setValue:imageInfoDict forKey:key];
                }
            }
        }];
        
        if (!SSIsEmptyDictionary(dictForImageInfoDict)) {
            [richSpansMutableDic setValue:dictForImageInfoDict forKey:TTRichSpansKeyImageList];
        }
    }
    
    return [richSpanDictionary copy];
}

+ (NSString *)JSONStringForRichSpans:(TTRichSpans *)richSpans {
    NSDictionary *richSpansDic = [TTRichSpans dictionaryForRichSpans:richSpans];
    if (!richSpansDic) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:richSpansDic options:0 error:&error];
    if (!jsonData) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (TTRichSpans *)richSpansForDictionary:(NSDictionary *)dictionary {
    NSArray<NSDictionary *> *linkDictionaries = [dictionary tt_arrayValueForKey:TTRichSpansKeyLinks];
    if (!linkDictionaries || ![linkDictionaries isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSArray<TTRichSpanLink *> *links = [TTRichSpanLink richSpanLinksForDictionaries:linkDictionaries];
    if ([links count] == 0) {
        return nil;
    }
    
    NSMutableDictionary *imageInfoModelDict = [[NSMutableDictionary alloc] init];
    NSDictionary *imageListDict = [dictionary tt_dictionaryValueForKey:TTRichSpansKeyImageList];
    if (!SSIsEmptyDictionary(imageListDict)) {
        [imageListDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (key && [key isKindOfClass:[NSString class]] && obj && [obj isKindOfClass:[NSDictionary class]]) {
                NSString *keyString = (NSString *)key;
                NSDictionary *imageDict = (NSDictionary *)obj;
                if (!isEmptyString(keyString) && !SSIsEmptyDictionary(imageDict)) {
                    TTRichTextImageInfoModel *imageInfoModel = [[TTRichTextImageInfoModel alloc] initWithDictionary:imageDict];
                    if (imageInfoModel) {
                        [imageInfoModelDict setValue:imageInfoModel forKey:keyString];
                    }
                }
            }
        }];
    }
    
    TTRichSpans *richSpans = [[TTRichSpans alloc] init];
    richSpans.innerLinks = [links mutableCopy];
    richSpans.innerImageInfoModesDict = [[NSMutableDictionary alloc] init];
    if (!SSIsEmptyDictionary(imageInfoModelDict)) {
        [richSpans.innerImageInfoModesDict addEntriesFromDictionary:imageInfoModelDict];
    }
    richSpans.originDictionary = [dictionary copy];
    return richSpans;
}

+ (TTRichSpans *)richSpansForJSONString:(NSString *)JSONString {
    if (isEmptyString(JSONString)) {
        return nil;
    }
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    NSError *error;
    NSDictionary *richSpansDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!richSpansDic || ![richSpansDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [TTRichSpans richSpansForDictionary:richSpansDic];
}

+ (NSString *)filterValidRichSpanString:(NSString *)richSpanString {
    if (isEmptyString(richSpanString)) {
        return nil;
    }
    
    TTRichSpans *contentRichSpans = [TTRichSpans richSpansForJSONString:richSpanString];
    if (!contentRichSpans) {
        return nil;
    }
    
    TTRichSpans *optimizeRichSpans = nil;
    if (!SSIsEmptyArray(contentRichSpans.links) ) {
        
        NSMutableArray *richSpanLinkArray = [[NSMutableArray alloc] init];
        
        for (TTRichSpanLink *link in contentRichSpans.links) {
            if (link.type >= TTRichSpanLinkTypeQuotedCommentUser) {
                link.type = TTRichSpanLinkTypeUnknown;
            }
            [richSpanLinkArray addObject:link];
        }
        
        optimizeRichSpans = [[TTRichSpans alloc] initWithRichSpanLinks:richSpanLinkArray imageInfoModelsDict:contentRichSpans.imageInfoModesDict];
    }
    
    NSString *optimizeContentRichSpanString = nil;
    if (optimizeRichSpans) {
        optimizeContentRichSpanString = [TTRichSpans JSONStringForRichSpans:optimizeRichSpans];
    }
    return optimizeContentRichSpanString;
}

+ (NSInteger)richSpanCountRichSpans:(TTRichSpans *)richSpans forRichSpanLinkType:(TTRichSpanLinkType)linkType{

    if(!richSpans || SSIsEmptyArray(richSpans.links)){
        return 0;
    }

    __block NSInteger finalCount = 0;

    [richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj && [obj isKindOfClass:[TTRichSpanLink class]]){
            if(obj.type == linkType){
                finalCount += 1;
            }
        }
    }];

    return finalCount;
}

+ (BOOL)richSpanJsonStringHasImageInfoLink:(NSString *)jsonString {
    if (isEmptyString(jsonString)) {
        return NO;
    }

    return [TTRichSpanText richSpanJsonStringHasImageInfoWithContentString:nil richSpanString:jsonString];
}


@end

@interface TTRichSpanText () <NSCoding>

@property (nonatomic, copy, readwrite) NSString *text;
@property (nonatomic, strong, readwrite) TTRichSpans *richSpans;

@end

@implementation TTRichSpanText

-(NSString *)base64EncodedString {
    NSData *richSpanTextData = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSString *draftBase64Text = [richSpanTextData base64EncodedString];
    return draftBase64Text;
}

-(instancetype)initWithBase64EncodedString:(NSString *)base64String {
    if(self = [super init]) {
        NSData *richSpanTextData = [base64String base64DecodedData];
        TTRichSpanText *richSpanText = [NSKeyedUnarchiver unarchiveObjectWithData:richSpanTextData];
        self.text = richSpanText.text;
        self.richSpans = richSpanText.richSpans?:[[TTRichSpans alloc] initWithRichSpanLinks:@[] imageInfoModelsDict:@{}];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:[TTRichSpans JSONStringForRichSpans:self.richSpans] forKey:@"richSpans"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.richSpans = [TTRichSpans richSpansForJSONString:[aDecoder decodeObjectForKey:@"richSpans"]];
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text richSpansJSONString:(NSString *)richSpansJSONString {
    self = [super init];
    if (self) {
        return [self initWithText:text richSpans:[TTRichSpans richSpansForJSONString:richSpansJSONString]];
    }
    
    return self;
}

- (instancetype)initWithText:(NSString *)text richSpans:(TTRichSpans *)richSpans {
    self = [super init];
    if (self) {
        return [self initWithText:text richSpanLinks:richSpans.links imageInfoModelDictionary:richSpans.imageInfoModesDict];
    }
    return self;
}


- (instancetype)initWithText:(NSString *)text richSpanLinks:(NSArray <TTRichSpanLink *>*)links imageInfoModelArray:(NSArray<TTRichTextImageInfoModel *> *)imageInfoModelArray {
    
    NSMutableDictionary *imageInfoMutableDict = [[NSMutableDictionary alloc] init];
    if (!SSIsEmptyArray(imageInfoModelArray)) {
        for (TTRichTextImageInfoModel *imageInfoModel in imageInfoModelArray) {
            if (!isEmptyString(imageInfoModel.uri)) {
                [imageInfoMutableDict setValue:imageInfoModel forKey:imageInfoModel.uri];
            }
        }
    }
    return [self initWithText:text richSpanLinks:links imageInfoModelDictionary:(!SSIsEmptyDictionary(imageInfoMutableDict)?imageInfoMutableDict:nil)];
}

- (instancetype)initWithText:(NSString *)text richSpanLinks:(NSArray <TTRichSpanLink *>*)links imageInfoModelDictionary:(NSDictionary<NSString *, TTRichTextImageInfoModel *> *)imageInfoModelDictionary {
    self = [super init];
    if (self) {
        self.text = text;
        NSMutableArray<TTRichSpanLink *> *finalLinks = [[NSMutableArray alloc] initWithCapacity:[links count]];
        [links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[TTRichSpanLink class]]) {
                if (obj.start + obj.length <= [text length]) {
                    [finalLinks addObject:obj];
                }
            }
        }];
        TTRichSpans *richSpans = [[TTRichSpans alloc] init];
        richSpans.innerLinks = finalLinks;
        
        richSpans.innerImageInfoModesDict = [[NSMutableDictionary alloc] init];
        if (!SSIsEmptyDictionary(imageInfoModelDictionary)) {
            [richSpans.innerImageInfoModesDict addEntriesFromDictionary:imageInfoModelDictionary];
        }
        self.richSpans = richSpans;
    }
    return self;
}

- (void)appendRichSpanText:(TTRichSpanText *)aRichSpanText {
    NSMutableArray<TTRichSpanLink *> *offsetLinks = [[NSMutableArray alloc] initWithCapacity:[aRichSpanText.richSpans.links count]];
    [aRichSpanText.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if (obj.start + obj.length <= [aRichSpanText.text length]) {
                NSUInteger offset = [self.text length];
                TTRichSpanLink *offsetLink = [[TTRichSpanLink alloc] initWithStart:(obj.start + offset)
                                                                            length:obj.length
                                                                              link:obj.link
                                                                              text:obj.text
                                                                   imageInfoModels:obj.imageInfoModels
                                                                              type:obj.type
                                                                          flagType:obj.flagType];
                offsetLink.userInfo = obj.userInfo;
                [offsetLinks addObject:offsetLink];
            }
        }
    }];
    
    if (!isEmptyString(aRichSpanText.text)) {
        self.text = [self.text stringByAppendingString:aRichSpanText.text];
    }
    if (!SSIsEmptyArray(offsetLinks)) {
        [self.richSpans.innerLinks addObjectsFromArray:offsetLinks];
    }
    
    if (!SSIsEmptyDictionary(aRichSpanText.richSpans.imageInfoModesDict)) {
        [self.richSpans.innerImageInfoModesDict addEntriesFromDictionary:aRichSpanText.richSpans.imageInfoModesDict];
    }
    
}

- (void)insertRichSpanText:(TTRichSpanText *)aRichSpanText atIndex:(NSUInteger)atIndex {
    
    if (atIndex > self.text.length) {
        return;
    }
    __block TTRichSpanLink *brokenLink = nil;
    [self.richSpans.innerLinks enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if ((obj.start <= atIndex) &&
                (obj.start + obj.length <= atIndex)) {
                //Do Nothing
            }
            else if ((obj.start < atIndex) &&
                     (obj.start + obj.length > atIndex)) {
                //Break
                brokenLink = obj;
            }
            else if ((obj.start >= atIndex)) {
                //Add Offset
                obj.start += aRichSpanText.text.length;
            }
        }
    }];
    
    if (brokenLink) {
        [self.richSpans.innerLinks removeObject:brokenLink];
    }
    
    NSMutableArray<TTRichSpanLink *> *insertLinks = [[NSMutableArray alloc] initWithCapacity:[aRichSpanText.richSpans.links count]];
    [aRichSpanText.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if (obj.start + obj.length <= aRichSpanText.text.length) {
                TTRichSpanLink *insertLink = [[TTRichSpanLink alloc] initWithStart:(atIndex + obj.start)
                                                                            length:obj.length
                                                                              link:obj.link
                                                                              text:obj.text
                                                                   imageInfoModels:obj.imageInfoModels
                                                                              type:obj.type
                                                                          flagType:obj.flagType];
                insertLink.userInfo = obj.userInfo;
                [insertLinks addObject:insertLink];
            }
        }
    }];
    
    if (!isEmptyString(aRichSpanText.text)) {
        self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange(atIndex, 0) withString:aRichSpanText.text];
    }
    
    if (!SSIsEmptyArray(insertLinks)) {
        [self.richSpans.innerLinks addObjectsFromArray:insertLinks];
    }
    
    if (!SSIsEmptyDictionary(aRichSpanText.richSpans.imageInfoModesDict)) {
        [self.richSpans.innerImageInfoModesDict addEntriesFromDictionary:aRichSpanText.richSpans.imageInfoModesDict];
    }
    
}

- (void)appendText:(NSString *)aText {
    if (!isEmptyString(aText)) {
        self.text  = [self.text stringByAppendingString:aText];
    }
}

- (void)insertText:(NSString *)aText atIndex:(NSUInteger)atIndex {
    if (atIndex > self.text.length) {
        return;
    }
    __block TTRichSpanLink *brokenLink = nil;
    [self.richSpans.innerLinks enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if ((obj.start <= atIndex) &&
                (obj.start + obj.length <= atIndex)) {
                //Do Nothing
            }
            else if ((obj.start < atIndex) &&
                     (obj.start + obj.length > atIndex)) {
                //Break
                brokenLink = obj;
            }
            else if ((obj.start >= atIndex)) {
                //Add Offset
                obj.start += [aText length];
            }
        }
    }];
    
    if (brokenLink) {
        [self.richSpans.innerLinks removeObject:brokenLink];
    }
    
    self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange(atIndex, 0) withString:aText ?: @""];
}

- (NSArray <TTRichSpanLink *> *)replaceCharactersInRange:(NSRange)range withText:(NSString *)aText {
    if (range.location > self.text.length) {
        return nil;
    }
    NSMutableArray<TTRichSpanLink *> *brokenLinks = [[NSMutableArray alloc] init];
    [self.richSpans.innerLinks enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            
            //图片一类的属于这个里面了
            if ((obj.start <= range.location) &&
                (obj.start + obj.length <= range.location)) {
                //Do Nothing
            }
            else if ((obj.start >= range.location + range.length) &&
                     (obj.start + obj.length >= range.location + range.length)) {
                //Add Offset
                obj.start += ([aText length] - range.length);
            }
            else {
                //Break
                [brokenLinks addObject:obj];
            }
        }
    }];
    
    [self.richSpans.innerLinks removeObjectsInArray:brokenLinks];
    
    self.text = [self.text stringByReplacingCharactersInRange:range withString:aText ?: @""];
    
    return brokenLinks;
}

+ (NSInteger)richSpanCountRichSpanText:(TTRichSpanText *)richSpanText forRichSpanLinkType:(TTRichSpanLinkType)linkType {

    if(!richSpanText || SSIsEmptyArray(richSpanText.richSpans.links)){
        return 0;
    }

    __block NSInteger finalCount = 0;

    [richSpanText.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj && [obj isKindOfClass:[TTRichSpanLink class]]){
            if(obj.type == linkType && (obj.start + obj.length <= richSpanText.text.length)){
                finalCount += 1;
            }
        }
    }];

    return finalCount;
}

+ (NSInteger)richSpanCountWithContentString:(NSString *)contentString richSpanString:(NSString *)richSpanString forRichSpanLinkType:(TTRichSpanLinkType)linkType {
    if (isEmptyString(richSpanString)) {
        return 0;
    }

    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:richSpanString];
    if(!richSpans || SSIsEmptyArray(richSpans.links)){
        return 0;
    }

    __block NSInteger finalCount = 0;

    [richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj && [obj isKindOfClass:[TTRichSpanLink class]]){
            if(obj.type == linkType && (obj.start + obj.length <= contentString.length)){
                finalCount += 1;
            }
        }
    }];
    return finalCount;
}


+ (BOOL)richSpanJsonStringHasImageInfoWithContentString:(NSString *)contentString richSpanString:(NSString *)richSpanString {
    if (isEmptyString(richSpanString)) {
        return NO;
    }

    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:richSpanString];
    if(!richSpans || SSIsEmptyArray(richSpans.links)){
        return NO;
    }

    __block NSInteger imageLinkNum = 0;

    [richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj && [obj isKindOfClass:[TTRichSpanLink class]]){
            if(obj.type == TTRichSpanLinkTypeImage && (obj.start + obj.length <= contentString.length)){
                imageLinkNum += 1;
            }
        }
    }];
    if (imageLinkNum > 0) {
        return YES;
    };
    return NO;
}


- (void)trimmingCharactersInSet:(NSCharacterSet *)characterSet {
    [self trimmingLeftCharactersInSet:characterSet];
    [self trimmingRightCharactersInSet:characterSet];
}

- (void)trimmingLeftCharactersInSet:(NSCharacterSet *)characterSet {
    NSUInteger location = 0;
    NSUInteger length = [self.text length];
    unichar charBuffer[length];
    [self.text getCharacters:charBuffer];
    
    for ( ; location < length; location++) {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }
    [self replaceCharactersInRange:NSMakeRange(0, location) withText:@""];
}

- (void)trimmingRightCharactersInSet:(NSCharacterSet *)characterSet {
    NSUInteger length = [self.text length];
    unichar charBuffer[length];
    [self.text getCharacters:charBuffer];
    for (; length > 0; length--) {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }
    [self replaceCharactersInRange:NSMakeRange(length, [self.text length] - length) withText:@""];
}

- (void)trimmingHashtagsWithStartIndex:(NSInteger)startIndex {
    __block TTRichSpanLink *firstHashtag = nil;
    [self.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull link, NSUInteger idx, BOOL * _Nonnull stop) {
        if (link.type == TTRichSpanLinkTypeHashtag && link.start == startIndex) {
            firstHashtag = link;
            *stop = YES;
        }
    }];
    if (firstHashtag) {
        [self replaceCharactersInRange:NSMakeRange(firstHashtag.start, firstHashtag.length) withText:@""];
    }
}

- (NSArray <TTRichSpanLink *> *)sortedRichSpanLinks:(NSArray <TTRichSpanLink *> *)richSpanLinks {
    return [richSpanLinks sortedArrayUsingComparator:^NSComparisonResult(TTRichSpanLink *link1, TTRichSpanLink *link2) {
        if (link1.start < link2.start) {
            return NSOrderedAscending;
        } else if (link1.start > link2.start) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (id)copyWithZone:(NSZone *)zone {
    NSString *text = self.text;
    NSMutableArray<TTRichSpanLink *> *links = [[NSMutableArray alloc] initWithCapacity:[self.richSpans.links count]];
    [self.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if (obj.start + obj.length <= [text length]) {
                TTRichSpanLink *link = [[TTRichSpanLink alloc] initWithStart:obj.start
                                                                      length:obj.length
                                                                        link:obj.link
                                                                        text:obj.text
                                                             imageInfoModels:obj.imageInfoModels
                                                                        type:obj.type
                                                                    flagType:obj.flagType];
                link.userInfo = obj.userInfo;
                link.idStr = obj.idStr;
                link.originDictionary = obj.originDictionary;
                [links addObject:link];
            }
        }
    }];
    
    TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:links imageInfoModelDictionary:self.richSpans.imageInfoModesDict];
    return richSpanText;
}

#pragma mark - detectAndAddLinks

- (void)detectAndAddLinks {
    if (isEmptyString(self.text)) {
        return;
    }
    
    BOOL isDetectLinks = [objc_getAssociatedObject(self, @selector(detectAndAddLinks)) boolValue];
    if (isDetectLinks) {
        return;
    }
    objc_setAssociatedObject(self, @selector(detectAndAddLinks), @(YES), OBJC_ASSOCIATION_ASSIGN);
    
    NSArray *matches = [[self dataDetector] matchesInString:self.text options:0 range:NSMakeRange(0, self.text.length)];
    NSArray<TTRichSpanLink *> *richSpansLinks = self.richSpans.links;
    
    if (matches.count > 0) {
        for (NSTextCheckingResult *result in matches) {
            NSRange linkRange = result.range;
            NSString *linkString = result.URL.absoluteString;
            if (NSMaxRange(linkRange) <= self.text.length) {
                if (![self linkRange:linkRange inRichSpansLinks:richSpansLinks]) {
                    TTRichSpanLink *detectedLink = [[TTRichSpanLink alloc] initWithStart:linkRange.location
                                                                                  length:linkRange.length
                                                                                    link:linkString
                                                                                    text:nil
                                                                         imageInfoModels:nil
                                                                                    type:TTRichSpanLinkTypeAutoDetectLink
                                                                                flagType:TTRichSpanLinkFlagTypeDefault];
                    [self.richSpans.innerLinks addObject:detectedLink];
                }
            }
        }
    }
}

- (BOOL)linkRange:(NSRange)linkRange inRichSpansLinks:(NSArray<TTRichSpanLink *> *)richSpansLinks {
    BOOL inRichSpansLinks = NO;
    NSUInteger startInsertIndex = linkRange.location;
    NSUInteger endInsertIndex = linkRange.location + linkRange.length - 1;
    for (TTRichSpanLink *link in richSpansLinks) {
        NSUInteger startIndex = link.start;
        NSUInteger endIndex = link.start + link.length - 1;
        
        if (startInsertIndex >= startIndex && startInsertIndex <= endIndex) {
            inRichSpansLinks = YES;
            break;
        }
        if (endInsertIndex >= startIndex && endInsertIndex <= endIndex) {
            inRichSpansLinks = YES;
            break;
        }
    }
    
    return inRichSpansLinks;
}

- (NSDataDetector *)dataDetector {
    NSDataDetector *dataDetector = objc_getAssociatedObject(self, @selector(dataDetector));
    if (!dataDetector) {
        dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        objc_setAssociatedObject(self, @selector(dataDetector), dataDetector, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return dataDetector;
}

@end
