//
//  TSVDataFetchManager.m
//  Article
//
//  Created by 王双华 on 2017/9/20.
//

#import "TSVDataFetchManager.h"

@interface TSVDataFetchManager()

@property (nonatomic, strong, readwrite) TTShortVideoModel *replacedModel;//被替换掉的model
@property (nonatomic, assign, readwrite) NSInteger replacedIndex;

@end

@implementation TSVDataFetchManager

@synthesize currentIndex = _currentIndex;
@synthesize hasMoreToLoad = _hasMoreToLoad;
@synthesize isLoadingRequest = _isLoadingRequest;
@synthesize shouldShowNoMoreVideoToast = _shouldShowNoMoreVideoToast;
@synthesize listCellCurrentIndex = _listCellCurrentIndex;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _replacedIndex = NSNotFound;
    }
    return self;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if(_currentIndex != currentIndex) {
        if (_currentIndex == _replacedIndex) {
            [self replaceModel:nil atIndex:NSNotFound];
        }
        _currentIndex = currentIndex;
    }
}

- (void)replaceModel:(TTShortVideoModel *)model atIndex:(NSInteger)index
{
    self.replacedModel = model;
    self.replacedIndex = index;
}

- (NSUInteger)numberOfShortVideoItems
{
    NSAssert(NO, @"subclass must implement this function");
    return 0;
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index
{
    NSAssert(NO, @"subclass must implement this function");
    return nil;
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index replaced:(BOOL)replaced
{
    NSAssert(NO, @"subclass must implement this function");
    return nil;
}

- (NSInteger)replacedIndex
{
    return _replacedIndex;
}

- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
    NSAssert(NO, @"subclass must implement this function");
}

@end
