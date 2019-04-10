//
//  TTNotePermissionGuideManager.h
//  Article
//
//  Created by liuzuopeng on 11/07/2017.
//
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, TTNoteGuideFireTiming) {
    TTNoteGuideFireTimingReadArticle,    // 读`热`文
    TTNoteGuideFireTimingFollow,         // 关注
    TTNoteGuideFireTimingPublishArticle, // 发文、发帖
    TTNoteGuideFireTimingPublishComment, // 发表评论
};

typedef NS_ENUM(NSInteger, TTNoteGuideShowScene) {
    TTNoteGuideShowSceneFeed,
    TTNoteGuideShowSceneComment,
};

@interface TTNotePermissionGuideManager : NSObject

+ (instancetype)sharedNoteManager;

+ (BOOL)canShowNotePermissionGuideDialog;

+ (void)showNotePermissionGuideDialogIfNeeded;

@end



@interface TTNotePermissionGuideManager (ABConfigTest)

+ (void)parseNoteGuideFreqControlConfig:(NSDictionary *)dict;

/**
 *  更新显示权限弹窗的时间（距离1970）
 */
+ (void)updateShowDialogTime;

/**
 *  当前距离上次显示权限引导弹窗的时间间隔
 */
+ (NSInteger)daysFromLastShowDialog;

@end

