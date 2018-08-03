//
//  TTPushAlertModel.m
//  Article
//
//  Created by liuzuopeng on 06/07/2017.
//
//

#import "TTPushAlertModel.h"
#import "TTPushResourceMgr.h"



@implementation TTPushAlertModel

+ (instancetype)modelWithTitle:(NSString *)titleString
                        detail:(NSString *)detailString
                        images:(NSArray *)imageArray
{
    return [[self alloc] initWithTitle:titleString detail:detailString images:imageArray];
}

- (instancetype)initWithTitle:(NSString *)titleString
                       detail:(NSString *)detailString
                       images:(NSArray *)imageArray
{
    if ((self = [super init])) {
        self.titleString = titleString;
        self.detailString = detailString;
        self.images = imageArray;
    }
    return self;
}

- (void)setImages:(NSArray<id> *)images
{
    if (_images != images) {
        _images = images;
        
        [images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.class isNewImageURL:obj]) {
                [TTPushResourceMgr downloadImageWithURLString:obj completion:nil];
            }
        }];
    }
}

+ (BOOL)isNewImageURL:(id)obj
{
    if ([obj isKindOfClass:[UIImage class]]) {
        return NO;
    } else if ([obj isKindOfClass:[NSData class]])  {
        return NO;
    } else if ([obj isKindOfClass:[NSURL class]]) {
        NSURL *urlString = (NSURL *)obj;
        if ([urlString isFileURL]) {
            return NO;
        } else if ([TTPushResourceMgr cachedImageExistsForURLString:urlString.absoluteString]) {
            return NO;
        } else {
            return YES;
        }
    } else if ([obj isKindOfClass:[NSString class]]) {
        NSURL *urlString = [NSURL URLWithString:(NSString *)obj];
        if ([urlString isFileURL]) {
            return NO;
        } else if ([TTPushResourceMgr cachedImageExistsForURLString:urlString.absoluteString]) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (id)firstImageObject
{
    if ([self.images count] > 0) {
        return [self.images firstObject];
    }
    return nil;
}

@end
