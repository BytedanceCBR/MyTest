//
//  SSImageInfosModel.m
//  Article
//
//  Created by Zhang Leonardo on 12-12-5.
//
//

#import "SSImageInfosModel.h"

@implementation SSImageInfosModel

@synthesize URI = _URI;
@synthesize width = _width;
@synthesize height = _height;
@synthesize urlWithHeader = _urlWithHeader;

- (void)dealloc
{
    self.URI = nil;
    self.urlWithHeader = nil;
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.URI forKey:@"uri"];
    [aCoder encodeObject:self.urlWithHeader forKey:@"url_list"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.height forKey:@"height"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.URI = [aDecoder decodeObjectForKey:@"uri"];
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
        self.urlWithHeader = [aDecoder decodeObjectForKey:@"url_list"];
    }
    return self;
}

- (id)initWithURLAndHeader:(NSArray *)URLWithHeader withWidth:(CGFloat)w withHeight:(CGFloat)h withURI:(NSString *)URI
{
    if ([URLWithHeader count] == 0 && w <= 0 && h <= 0 && URI == nil) {
        return nil;
    }

    self = [self init];
    if (self) {
        
        if ([URI length] > 0) {
            self.URI = URI;
        }
        
        self.width = w;
        self.height = h;
        
//#warning test here
//        
//        NSMutableArray * tempAry = [NSMutableArray arrayWithCapacity:10];
//        if ([URLWithHeader count] > 0) {
//            NSString * uuurl = [[URLWithHeader objectAtIndex:0] objectForKey:@"url"];
//            NSDictionary * ddict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@0zcl", uuurl] forKey:@"url"];
//            [tempAry addObject:ddict];
//            [tempAry addObjectsFromArray:URLWithHeader];
//        }
//        self.urlWithHeader = [NSArray arrayWithArray:tempAry];
        
        
        
        self.urlWithHeader = [NSArray arrayWithArray:URLWithHeader];
        
    }
    return self;
}

- (id)initWithURL:(NSString *)URL withHeader:(NSDictionary *)header withWidth:(CGFloat)w withHeight:(CGFloat)h withURI:(NSString *)URI
{
    if (URL == nil && header == nil && w <= 0 && h <= 0 && URI == nil) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        if ([URI length] > 0) {
            self.URI = URI;
        }
        
        if ([URL length] > 0) {
            if ([self.URI length] == 0) {
                self.URI = URL;
            }
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:2];
            [dict setObject:[NSString stringWithString:URL] forKey:SSImageInfosModelURL];
            
            if (header != nil) {
                [dict setObject:header forKey:SSImageInfosModelHeader];
            }
            self.urlWithHeader = [NSArray arrayWithObject:[NSDictionary dictionaryWithDictionary:dict]];
            [dict release];
        }

        self.width = w;
        self.height =h;
        
    }
    return self;
}

- (id)initWithURL:(NSString *)URL withHeader:(NSDictionary *)header
{
    self = [self initWithURL:URL withHeader:header withWidth:0 withHeight:0 withURI:nil];
    
    if (self) {
        
    }
    return self;
}

- (id)initWithURL:(NSString *)URL
{
    self = [self initWithURL:URL withHeader:nil];
    if (self) {
        
    }
    return self;
}

+ (BOOL)isImageInfosModel:(SSImageInfosModel *)model1 equalesToModel:(SSImageInfosModel *)model2
{
    if (model1 == nil && model2 == nil) {
        return YES;
    }
    
    if ((model1 == nil && model2 != nil) || (model1 != nil && model2 == nil)) {
        return NO;
    }
    
    if (model1.URI != nil &&  model2.URI != nil && ![model1.URI isEqualToString:model2.URI]) {
        return NO;
    }
    
    if (model1.width != model2.width || model1.height != model2.height) {
        return NO;
    }
    
    if ([model1.urlWithHeader count] != [model2.urlWithHeader count]) {
        return NO;
    }

    for (int i = 0; i < [model1.urlWithHeader count]; i ++) {
        if (![[[model1.urlWithHeader objectAtIndex:i] objectForKey:SSImageInfosModelURL] isEqualToString:[[model2.urlWithHeader objectAtIndex:i] objectForKey:SSImageInfosModelURL]]) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@", self.urlWithHeader, self.URI];
}

@end
