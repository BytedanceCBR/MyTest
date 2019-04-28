//
//  SSTrashManager.h
//  Article
//
//  Created by SunJiangting on 14-11-25.
//
//

#import <Foundation/Foundation.h>

@interface SSTrashManager : NSObject

+ (instancetype)sharedManager;

@property(nonatomic) BOOL tryEmptyTrashWhenEnterBackground;
/// 移到废纸篓
- (BOOL)trashItemAtPath:(NSString *)path resultingItemPath:(NSString **)outResultingPath error:(NSError **)error;
/// 清空废纸篓
- (void)emptyTrashWithCompletionHandler:(void (^)(BOOL finished))completion;

/// caclulate all trash size synchronized, will block current thread
- (NSUInteger)trashSize;

- (BOOL)isEmptying;

- (void)cancel;

@end

