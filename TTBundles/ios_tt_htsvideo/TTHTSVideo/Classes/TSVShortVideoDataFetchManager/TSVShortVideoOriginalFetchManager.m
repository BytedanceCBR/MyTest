//
//  TSVShortVideoOriginalFetchManager.m
//  Article
//
//  Created by 王双华 on 2017/6/20.
//
//

#import "TSVShortVideoOriginalFetchManager.h"
#import "ExploreOrderedData+TTBusiness.h"

@interface TSVShortVideoOriginalFetchManager ()

@property (nonatomic, copy) NSArray *awemedDetailItems;
@property (nonatomic, strong) TSVShortVideoOriginalData *shortVideoOriginalData;
@property (nonatomic, copy) NSDictionary *logPb;

@end

@implementation TSVShortVideoOriginalFetchManager

- (instancetype)initWithShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData logPb:(NSDictionary *)logPb
{
    self = [super init];
    if (self){
        _shortVideoOriginalData = shortVideoOriginalData;
        self.shouldShowNoMoreVideoToast = NO;
        _logPb = logPb;
    }
    return self;
}

- (NSArray *)awemedDetailItems
{
    if (!_awemedDetailItems) {
        if (_shortVideoOriginalData){
            TTShortVideoModel *awemeDetail = _shortVideoOriginalData.shortVideo;
            awemeDetail.logPb = _logPb;
            [awemeDetail save];
            if (awemeDetail) {
                _awemedDetailItems = [NSArray arrayWithObject:awemeDetail];
            }
        }
    }
    return _awemedDetailItems;
}

#pragma mark -- TSVShortVideoDataFetchManagerProtocol

- (NSUInteger)numberOfShortVideoItems
{
    return [self.awemedDetailItems count];
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index
{
    return [self itemAtIndex:index replaced:YES];
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index replaced:(BOOL)replaced
{
    if (replaced && self.replacedModel && index == self.replacedIndex) {
        return self.replacedModel;
    } else if (index < [self.awemedDetailItems count]) {
        return [self.awemedDetailItems objectAtIndex:index];
    }
    return nil;
}

- (BOOL)hasMoreToLoad
{
    return NO;
}

- (BOOL)isLoadingRequest
{
    return NO;
}

- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
    if (finishBlock){
        finishBlock(0,nil);
    }
}

@end


