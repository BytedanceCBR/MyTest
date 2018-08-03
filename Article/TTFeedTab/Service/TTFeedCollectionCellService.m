//
//  TTFeedCollectionCellService.m
//  Article
//
//  Created by Chen Hong on 2017/3/29.
//
//

#import "TTFeedCollectionCellService.h"

@interface TTFeedCollectionCellService ()
@property(nonatomic, strong)Class<TTFeedCollectionCellHelper> defalutCellHeperClass;
@property(nonatomic, strong)NSMutableOrderedSet<Class<TTFeedCollectionCellHelper>> *cellHelperSet;
@end

@implementation TTFeedCollectionCellService

+ (instancetype)sharedInstance
{
    static TTFeedCollectionCellService *cellService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellService = [[TTFeedCollectionCellService alloc] init];
    });
    
    return cellService;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellHelperSet = [NSMutableOrderedSet orderedSetWithCapacity:5];
    }
    return self;
}

- (void)setDefaultFeedCollectionCellHelperClass:(Class<TTFeedCollectionCellHelper>)cellHelper
{
    _defalutCellHeperClass = cellHelper;
}

- (void)registerFeedCollectionCellHelperClass:(Class<TTFeedCollectionCellHelper>)cellHelper
{
    if ([(Class)cellHelper conformsToProtocol:@protocol(TTFeedCollectionCellHelper)]) {
        [self.cellHelperSet addObject:cellHelper];
    }
}

- (nullable Class<TTFeedCollectionCell>)cellClassFromFeedCategory:(nonnull id<TTFeedCategory>)feedCategory
{
    __block Class<TTFeedCollectionCell> cellClass = nil;
    
    [self.cellHelperSet enumerateObjectsUsingBlock:^(Class<TTFeedCollectionCellHelper>  _Nonnull cellHelperClass, NSUInteger idx, BOOL * _Nonnull stop) {
        cellClass = [cellHelperClass cellClassFromFeedCategory:feedCategory];
        if (cellClass) {
            *stop = YES;
        }
    }];
    
    if (!cellClass) {
        cellClass = [_defalutCellHeperClass cellClassFromFeedCategory:feedCategory];
    }
    
    return cellClass;
}

- (void)enumerateCellClassUsingBlock:(void (NS_NOESCAPE ^)(Class<TTFeedCollectionCell> cellClass))block {
    if (!block) return;
    
    [self.cellHelperSet enumerateObjectsUsingBlock:^(Class<TTFeedCollectionCellHelper>  _Nonnull cellHelperClass, NSUInteger idx, BOOL * _Nonnull stop) {
        [[cellHelperClass supportedCellClasses] enumerateObjectsUsingBlock:^(Class<TTFeedCollectionCell>  _Nonnull cellClass, NSUInteger idx, BOOL * _Nonnull stop) {
            block(cellClass);
        }];
    }];
    
    [[_defalutCellHeperClass supportedCellClasses] enumerateObjectsUsingBlock:^(Class<TTFeedCollectionCell>  _Nonnull cellClass, NSUInteger idx, BOOL * _Nonnull stop) {
        block(cellClass);
    }];
}

@end
