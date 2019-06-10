//
//  TTVPreloadDetailManager.h
//  Article
//
//  Created by panxiang on 2017/5/3.
//
//

#import <Foundation/Foundation.h>
@class TTVFeedListViewModel;
@protocol TTVPreloadDetailManagerDelegate <NSObject>

- (void)onPreloadDetail;
- (void)onPreloadMore;

@end

@interface TTVPreloadDetailManager : NSObject
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) NSObject <TTVPreloadDetailManagerDelegate> *delegate;
- (instancetype)initWithModel:(TTVFeedListViewModel *)viewModel;
- (void)tryPreload;
- (void)suspendPreloadDetail;
@end
