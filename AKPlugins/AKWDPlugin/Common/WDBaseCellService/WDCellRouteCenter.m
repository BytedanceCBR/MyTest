//
//  WDCellRouteCenter.m
//  wenda
//
//  Created by xuzichao on 2017/2/8.
//  Copyright © 2017年 xuzichao. All rights reserved.
//

#import "WDCellRouteCenter.h"
#import <objc/runtime.h>
#import "WDDefines.h"

@interface WDCellRouteCenter ()
@property (nonatomic,strong) NSMutableArray *serviceArray;

@end

@implementation WDCellRouteCenter

+ (instancetype)sharedInstance
{
    static WDCellRouteCenter *routeManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routeManager = [[WDCellRouteCenter alloc] init];
    });
    
    return routeManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serviceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)registerCellGroup:(id<WDCellServiceProctol>)service
{
    if (service) {
        [self.serviceArray addObject:service];
    }
}

- (Class)cellClassFromDataClass:(Class)dataClass
{
    Class cellClass;
    for (id service in self.serviceArray) {
        if ([service respondsToSelector:@selector(cellClassFromDataClass:)]) {
            cellClass = [service cellClassFromDataClass:dataClass];
        }
        if (cellClass) {
            break;
        }
    }
    return cellClass;
}

- (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width
{
    Class cellClass = [self cellClassFromDataClass:[data class]];
    Method class_method = class_getClassMethod(cellClass, @selector(heightForData:cellWidth:listType:));
    if (!isEmptyString(NSStringFromSelector(method_getName(class_method)))) {
        return [cellClass heightForData:data cellWidth:width listType:0];
    }
    return 0;
}

- (UITableViewCell<WDBaseCellDelegate> *)dequeueTableCellForData:(id)data
                              tableView:(UITableView *)view
                            atIndexPath:(NSIndexPath *)indexPath
{

    Class cellClass = [self cellClassFromDataClass:[data class]];
    NSString *identifier = NSStringFromClass(cellClass);
    
    id cell = [view dequeueReusableCellWithIdentifier:identifier];
    if (cell) {
        if ([cellClass isSubclassOfClass:[WDBaseCell class]]) {
            ((WDBaseCell *)cell).tableView = view;
        }
        return cell;
    } else {
        if ([cellClass isSubclassOfClass:[UITableViewCell class]]) {
            return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    }
    
    
    return nil;
}

@end
