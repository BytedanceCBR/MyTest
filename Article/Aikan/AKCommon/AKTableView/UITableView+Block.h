//
//  UITableView+Block.h
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import <Foundation/Foundation.h>

@interface UITableView (Block)

@property (nonatomic, strong) id <UITableViewDataSource, UITableViewDelegate> imp;

@property (nonatomic, copy) NSInteger (^numberOfSectionsBlock)(UITableView *tableView);
@property (nonatomic, copy) NSInteger (^numberOfRowsBlock)(UITableView *tableView, NSInteger section);
@property (nonatomic, copy) CGFloat (^heightForRowBlock)(UITableView *tableView, NSIndexPath *indexPath);
@property (nonatomic, copy) UITableViewCell* (^cellForRowBlock)(UITableView *tableView, NSIndexPath *indexPath);

@property (nonatomic, copy) void (^didSelectBlock)(UITableView *tableView, NSIndexPath *indexPath);

/*
 *  注册cell，传nil则默认为原生基类
 */
- (void)registerCellClass:(Class)cellClass;

/*
 *  根据cellClass和indexPath获取复用的cell对象
 */
- (__kindof UITableViewCell *)dequeueReusableCellWithClass:(Class)cellClass
                                              forIndexPath:(NSIndexPath *)indexPath;

@end
