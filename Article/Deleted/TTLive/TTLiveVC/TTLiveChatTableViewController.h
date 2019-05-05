//
//  TTLiveChatTableViewController.h
//  Article
//
//  Created by matrixzk on 2/1/16.
//
//

#import <UIKit/UIKit.h>

@class TTLiveMessage, TTLiveMainViewController, TTLiveTabCategoryItem;

//#import "TTLiveMessageBox.h"
//#import "TTLiveTabCategoryItem.h"

/** 信息刷新类型 */
typedef NS_ENUM(NSUInteger, TTLiveMessageListRefreshType) {
    /** 轮询 */
    TTLiveMessageListRefreshTypePolling,
    /** 获取新消息(首次进入) */
    TTLiveMessageListRefreshTypeGetNew,
    /** 获取旧消息(下拉获取) */
    TTLiveMessageListRefreshTypeGetOld
};

//typedef NS_ENUM(NSUInteger, TTLiveMsgListRefreshType) {
//    TTLiveMsgListRefreshTypePolling,        // 轮询
//    TTLiveMsgListRefreshTypePullUpForNew,   // 上拉刷新
//    TTLiveMsgListRefreshTypePullDownForOld      // 下拉加载历史
//};

/** 聊天流TableView */
@interface TTLiveChatTableViewController : UITableViewController

/** 关联的频道控件 */
@property (nonatomic, weak) TTLiveTabCategoryItem * _Nullable channelItem;
/** 本地消息去重数组 */
@property (nonatomic, strong) NSMutableArray * _Nullable distinctArray;
/** 首次加载 */
@property (nonatomic, assign) BOOL firstLoad;

@property (nonatomic, strong, readonly) NSMutableArray * _Nullable idsOfMessageToBeRemoved;
@property (nonatomic, strong, readonly) NSMutableArray * _Nonnull messageArray;

- (nonnull instancetype)initWithChannelItem:(TTLiveTabCategoryItem * _Nonnull)item inChatroom:(TTLiveMainViewController * _Nonnull)chatroom;
- (void)addChatMessageItems:(NSArray<TTLiveMessage *> * _Nullable)messageItems;
- (void)scrollToBottomWithAnimation:(BOOL)animation;

- (void)fetchLiveStreamDataSourceWithRefreshType:(TTLiveMessageListRefreshType)refreshType;

- (void)appendTempMessagesIfNeeded;

@end
