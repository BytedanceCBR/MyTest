//
//  TTCellBridge.m
//  Article
//
//  Created by Chen Hong on 16/2/18.
//
//

#import "TTCellBridge.h"

#pragma mark - TTCellClassInfo

@implementation TTCellClassInfo
@end


#pragma mark - TTCellBridge

static TTCellBridge *s_cellBridge;

@interface TTCellBridge ()

// cellIdentifier-> cellClassInfo
@property(nonatomic, strong) NSMutableDictionary<NSString *, TTCellClassInfo *> *cellClassInfoDict;

// cellDataClassName -> cellDataHelper
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<Class<TTCellDataHelper>> *> *cellDataHelperDict;

@end

@implementation TTCellBridge

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_cellBridge = [[TTCellBridge alloc] init];
    });
    
    return s_cellBridge;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClassInfoDict = [NSMutableDictionary dictionaryWithCapacity:20];
        self.cellDataHelperDict = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    return self;
}

- (void)registerCellClass:(Class)cellClass
            cellViewClass:(Class)cellViewClass
{
    if (cellClass && cellViewClass) {
        TTCellClassInfo *clsInfo = [[TTCellClassInfo alloc] init];
        clsInfo.cellCls = cellClass;
        clsInfo.cellViewCls = cellViewClass;
        [self.cellClassInfoDict setValue:clsInfo forKey:NSStringFromClass(cellClass)];
    }
}

- (void)registerCellDataClass:(Class)cellDataClass
          cellDataHelperClass:(Class)cellDataHelperClass
{
    if (cellDataClass && cellDataHelperClass) {
        NSString *clsName = NSStringFromClass(cellDataClass);
        if (!clsName) {
            return;
        }

        NSArray *clsArray = [self.cellDataHelperDict valueForKey:clsName];
        
        if ([clsArray containsObject:cellDataHelperClass]) {
            return;
        }
        
        NSMutableArray *array = nil;
        
        if (!clsArray) {
            array = [NSMutableArray array];
        } else {
            array = [NSMutableArray arrayWithArray:clsArray];
        }
        
        [array addObject:cellDataHelperClass];
        [self.cellDataHelperDict setValue:array forKey:clsName];
    }
}

// 遍历所有注册的cell类
- (void)enumerateCellInfoUsingBlock:(void (^)(NSString *cellId, TTCellClassInfo *classInfo))block
{
    if (!block) {
        return;
    }
    
    [self.cellClassInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TTCellClassInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        block(key, obj);
    }];
}

// cellData -> TTCellDataHelper
- (NSArray<Class<TTCellDataHelper>> *)cellHelperClassArrayForData:(id)data;
{
    Class dataCls = [data class];
    NSString *clsName = NSStringFromClass(dataCls);
    if (clsName) {
        return  self.cellDataHelperDict[clsName];
    }
    return nil;
}

- (Class)cellViewClassFromCellClass:(Class)cellClass
{
    NSString *clsName = NSStringFromClass(cellClass);
    if (clsName) {
        TTCellClassInfo *classInfo = self.cellClassInfoDict[clsName];
        return classInfo.cellViewCls;
    }
    return nil;
}



@end
