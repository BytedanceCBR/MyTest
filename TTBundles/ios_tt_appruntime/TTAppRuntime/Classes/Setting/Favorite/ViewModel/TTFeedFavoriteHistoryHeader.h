//
//  TTFeedFavoriteHistoryHeader.h
//  Article
//
//  Created by fengyadong on 16/11/22.
//
//

#ifndef TTFeedFavoriteHistoryHeader_h
#define TTFeedFavoriteHistoryHeader_h

#define kFooterDeleteViewHeight [TTDeviceUIUtils tt_padding:44.f]

typedef NS_ENUM(NSUInteger, TTHistoryType)
{
    /**
     *  阅读历史
     */
    TTHistoryTypeRead = 0,
    /**
     *  推送历史
     */
    TTHistoryTypeReadPush = 1,
    /**
     *  刷新历史
     */
    TTHistoryTypeRefresh = 2,
};

@protocol TTFeedFavoriteHistoryProtocol <NSObject>

- (void)didEditButtonPressed:(id)sender;
- (BOOL)isCurrentVCEditing;
- (void)cleanupDataSource;

@end

#endif /* TTFeedFavoriteHistoryHeader_h */
