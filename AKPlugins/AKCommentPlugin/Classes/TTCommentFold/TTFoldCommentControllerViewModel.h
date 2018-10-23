//
//  TTFoldCommentControllerViewModel.h
//  Article
//
//  Created by muhuai on 21/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTCommentModelProtocol.h"
#import "TTFoldCommentCellLayout.h"
#import "TTCommentDefines.h"

@interface TTFoldCommentControllerViewModel : NSObject
@property (nonatomic, strong, readonly) NSString *groupID;
@property (nonatomic, strong, readonly) NSString *itemID;
@property (nonatomic, assign, readonly) NSInteger aggrType;
@property (nonatomic, strong, readonly) NSString *zzids;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) TTCommentsGroupType groupType;
@property (nonatomic, strong, readonly) NSString *forumID;
@property (nonatomic, assign) CGFloat cellWidth;


- (instancetype)initWithGroupID:(NSString *)groupID groupType:(TTCommentsGroupType)groupType itemID:(NSString *)itemID forumID:(NSString *)forumID aggrType:(NSInteger)aggrType zzids:(NSString *)zzids;

- (void)loadCommentWithCompletionHandler:(void(^)(NSError *error, BOOL hasMore))completion;

- (void)sendHeaderShowTrackerIfNeed;

- (NSArray<id<TTCommentModelProtocol>> *)commentModels;

- (NSArray<TTFoldCommentCellLayout *> *)layouts;

@end
