//
//  TSVTabViewModel.m
//  Article
//
//  Created by 王双华 on 2017/10/30.
//

#import "TSVTabViewModel.h"
#import "TSVCategoryManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTCategory+ConfigDisplayName.h"

@interface TSVTabViewModel()

@property (nonatomic, copy) NSArray<TSVCategory *> *categories;

@end

@implementation TSVTabViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self bindModel];
    }
    return self;
}

- (void)bindModel
{
    @weakify(self);
    [RACObserve(self, categories) subscribeNext:^(id x) {
        @strongify(self);
        NSMutableArray *categoryNames = [NSMutableArray arrayWithCapacity:[self.categories count]];
        for (TSVCategory *category in self.categories) {
            [categoryNames addObject:[category adjustDisplayName]];
        }
        self.currentIndex = 0;
        self.categoryNames = categoryNames;
    }];
    [RACObserve(self, currentIndex) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        NSString *currentCategoryName;
        if (self.currentIndex >= 0 && self.currentIndex < self.categories.count) {
            currentCategoryName = [self.categories objectAtIndex:self.currentIndex].categoryID;
        } else {
            currentCategoryName = @"";
        }
        [[TSVCategoryManager sharedManager] setCurrentSelectedCategoryID:currentCategoryName];
    }];
}

- (void)fetchCategoryData
{
    //先加载本地数据库中的频道列表
    self.categories = [[TSVCategoryManager sharedManager] localCategories];
    //再请求服务端频道列表
    @weakify(self);
    [[TSVCategoryManager sharedManager] fetchCategoriesFromRemote:^(NSArray<TSVCategory *> *categories) {
        @strongify(self);
        if ([categories count] > 0) {
            self.categories = categories;
        }
    }];
}

- (NSArray<TSVCategory *> *)pageCategories
{
    return self.categories;
}

- (NSInteger)indexOfCategory:(NSString *)categoryID
{
    NSInteger idx = 0;
    
    for (TSVCategory *category in self.categories) {
        if ([category.categoryID isEqualToString:categoryID]) {
            return idx;
        }
        idx += 1;
    }
    
    return NSNotFound;
}

- (NSString *)currentCategoryName
{
    return [[TSVCategoryManager sharedManager] currentSelectedCategoryID];
}

@end
