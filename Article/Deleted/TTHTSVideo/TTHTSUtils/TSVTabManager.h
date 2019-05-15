//
//  TSVTabManager.h
//  Article
//
//  Created by 邱鑫玥 on 2017/9/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSVTabManager : NSObject

@property (nonatomic, assign, readonly, getter=isInShortVideoTab) BOOL inShortVideoTab;

+ (instancetype)sharedManager;

- (void)enterOrLeaveShortVideoTabWithLastViewController:(UIViewController *)lastViewController currentViewController:(UIViewController *)currentViewController;

- (NSInteger)indexOfShortVideoTab;

@end

NS_ASSUME_NONNULL_END
