//
//  UITableView+Block.m
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import "UITableView+Block.h"

@implementation UITableView (Block)

static NSString *const UITableViewImpKey = @"UITableViewImpKey";

- (id<UITableViewDataSource,UITableViewDelegate>)imp
{
    return objc_getAssociatedObject(self, (__bridge const void *)UITableViewImpKey);
}

- (void)setImp:(id<UITableViewDataSource,UITableViewDelegate>)imp
{
    self.dataSource = imp;
    self.delegate = imp;
    objc_setAssociatedObject(self, (__bridge const void *)UITableViewImpKey, imp, OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger (^)(UITableView *))numberOfSectionsBlock
{
    return objc_getAssociatedObject(self, @selector(numberOfSectionsInTableView:));
}

- (void)setNumberOfSectionsBlock:(NSInteger (^)(UITableView *))numberOfSectionsBlock
{
    objc_setAssociatedObject(self, @selector(numberOfSectionsInTableView:), numberOfSectionsBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger (^)(UITableView *, NSInteger))numberOfRowsBlock
{
    return objc_getAssociatedObject(self, @selector(tableView:numberOfRowsInSection:));
}

- (void)setNumberOfRowsBlock:(NSInteger (^)(UITableView *, NSInteger))numberOfRowsBlock
{
    objc_setAssociatedObject(self, @selector(tableView:numberOfRowsInSection:), numberOfRowsBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat (^)(UITableView *, NSIndexPath *))heightForRowBlock
{
    return objc_getAssociatedObject(self, @selector(tableView:heightForRowAtIndexPath:));
}

- (void)setHeightForRowBlock:(CGFloat (^)(UITableView *, NSIndexPath *))heightForRowBlock
{
    objc_setAssociatedObject(self, @selector(tableView:heightForRowAtIndexPath:), heightForRowBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableViewCell *(^)(UITableView *, NSIndexPath *))cellForRowBlock
{
    return objc_getAssociatedObject(self, @selector(tableView:cellForRowAtIndexPath:));
}

- (void)setCellForRowBlock:(UITableViewCell *(^)(UITableView *, NSIndexPath *))cellForRowBlock
{
    objc_setAssociatedObject(self, @selector(tableView:cellForRowAtIndexPath:), cellForRowBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(UITableView *, NSIndexPath *))didSelectBlock
{
    return objc_getAssociatedObject(self, @selector(tableView:didSelectRowAtIndexPath:));
}

- (void)setDidSelectBlock:(void (^)(UITableView *, NSIndexPath *))didSelectBlock
{
    objc_setAssociatedObject(self, @selector(tableView:didSelectRowAtIndexPath:), didSelectBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)registerCellClass:(Class)cellClass
{
    Class registedClass = [UITableViewCell class];
    if ([cellClass isKindOfClass:[UITableViewCell class]]) {
        registedClass = cellClass;
    }
    [self registerClass:registedClass forCellReuseIdentifier:NSStringFromClass(registedClass)];
}

- (__kindof UITableViewCell *)dequeueReusableCellWithClass:(Class)cellClass
                                              forIndexPath:(NSIndexPath *)indexPath
{
    Class registedClass = [UITableViewCell class];
    if (cellClass) {
        registedClass = cellClass;
    }
    return [self dequeueReusableCellWithIdentifier:NSStringFromClass(registedClass)
                                      forIndexPath:indexPath];
}

@end
