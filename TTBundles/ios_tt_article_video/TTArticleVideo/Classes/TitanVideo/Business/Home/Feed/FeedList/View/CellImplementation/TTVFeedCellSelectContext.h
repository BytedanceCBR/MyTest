//
//  TTVFeedCellSelectContext.h
//  Article
//
//  Created by panxiang on 2017/4/19.
//
//

#import <Foundation/Foundation.h>

@class TTVFeedListItem;
@class TTVFeedListViewController;

#pragma mark cellSelect上下文
@interface TTVFeedCellSelectContext : NSObject

// 设置log数据
@property(nonatomic, strong) NSMutableDictionary *eventContext;

// 统计用，cell所属页面
@property (nonatomic, strong) NSString *screenName;

// 入口refer
@property(nonatomic) NSUInteger refer;

@property(nonatomic, copy) NSString *categoryId;

// 点击cell上的评论
@property(nonatomic) BOOL clickComment;

@property (nonatomic, weak) TTVFeedListViewController *feedListViewController;

@end


#pragma mark cellSelect默认处理
@interface TTVFeedCellDefaultSelectHandler : NSObject

/**
 一些不依赖具体cell，与具体数据类型相关的处理
 */
+ (BOOL)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context;

/**
 所有的广告都调用
 */
+ (void)commonAdSelectionWithItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context;
@end
