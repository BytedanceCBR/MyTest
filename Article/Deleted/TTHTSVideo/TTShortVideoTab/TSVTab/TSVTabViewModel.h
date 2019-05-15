//
//  TSVTabViewModel.h
//  Article
//
//  Created by 王双华 on 2017/10/30.
//

#import <Foundation/Foundation.h>
#import "TSVCategory.h"

@interface TSVTabViewModel : NSObject

@property (nonatomic, copy) NSArray <NSString *> *categoryNames;
@property (nonatomic, assign) NSInteger currentIndex;

- (void)fetchCategoryData;

///TSVCategoryContainerViewController未用MVVM实现，这里返回频道数组仅提供给TSVCategoryContainerViewController使用
- (NSArray<TSVCategory *> *)pageCategories;

- (NSInteger)indexOfCategory:(NSString *)categoryID;
- (NSString *)currentCategoryName;

@end
