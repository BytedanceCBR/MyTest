//
//  TTFoldableLayout.h
//  Article
//
//  Created by Dai Dongpeng on 4/17/16.
//
//

#import <UIKit/UIKit.h>
#import "TTFoldableLayoutDefinitaions.h"


@interface TTFoldableLayout : NSObject <TTFoldableLayoutProtocol>

@property (nonatomic, weak) id <TTFoldableLayoutDelegate> layoutDelegate;
@property (nonatomic, strong, readonly) NSArray <UIViewController <TTFoldableLayoutItemDelegate>*> * items;

@property (nonatomic, assign) BOOL lockHeaderAutoFolded;

- (instancetype)initWithItems:(NSArray <NSObject <TTFoldableLayoutItemDelegate>*> *)items;
- (instancetype)initWithItems:(NSArray <NSObject <TTFoldableLayoutItemDelegate>*> *)items
                                    delegate:(id <TTFoldableLayoutDelegate>)layoutDelegate;

@end

//@interface UIResponder (_TTFoldableLayoutItemDelegate) <TTFoldableLayoutItemDelegate>
//@end




