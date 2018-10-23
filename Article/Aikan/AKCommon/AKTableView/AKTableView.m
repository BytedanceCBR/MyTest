//
//  AKTableView.m
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import "AKTableView.h"
#import <KVOController.h>

@implementation AKTableView

- (void)dealloc
{
    LOGD(@"-----[AKTableView] instance deallocated-----");
//    [self.KVOController removeObserver:_tableViewModel forKeyPath:@"datasourceArray"];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.imp = [AKTableView_IMP new];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor whiteColor];
        self.backgroundView = nil;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.separatorColor = [UIColor clearColor];
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
        }
    }
    return self;
}

- (void)setTableViewModel:(AKTableViewModel *)tableViewModel
{
    if (!tableViewModel) {
        _tableViewModel = nil;
        return;
    }
    
    if (_tableViewModel != tableViewModel) {        
        _tableViewModel = tableViewModel;
        WeakSelf;
        [self.KVOController observe:_tableViewModel keyPath:@"datasourceArray" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself reloadData];
            });
        }];
    }
}

@end
