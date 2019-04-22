//
//  TTLiveFoldableLayout.h
//  Article
//
//  Created by 杨心雨 on 2016/11/3.
//
//

#import <UIKit/UIKit.h>
#import "TTFoldableLayoutDefinitaions.h"

@interface TTLiveFoldableLayout : NSObject <TTFoldableLayoutProtocol>

@property (nonatomic, weak) id <TTFoldableLayoutDelegate> layoutDelegate;
@property (nonatomic, strong, readonly) NSArray <UIViewController <TTFoldableLayoutItemDelegate>*> * items;

@property (nonatomic, assign) BOOL lockHeaderAutoFolded;
@property (nonatomic, assign) BOOL unlockPushToFolded;
@property (nonatomic, assign) BOOL lockFoldOneOpen;//用于在滑动时打开了nav，锁定
@property (nonatomic, assign) BOOL headerViewFolded;

- (instancetype)initWithItems:(NSArray <NSObject <TTFoldableLayoutItemDelegate>*> *)items;
- (instancetype)initWithItems:(NSArray <NSObject <TTFoldableLayoutItemDelegate>*> *)items
                     delegate:(id <TTFoldableLayoutDelegate>)layoutDelegate;

@end
