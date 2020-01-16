//
//  FHUGCVoteViewModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class FHUGCVotePublishViewController;
@interface FHUGCVoteViewModel : NSObject

@property (nonatomic, assign, readonly) BOOL isPublishing;

- (instancetype)initWithScrollView:(UIScrollView *)tableView ViewController:(FHUGCVotePublishViewController *)viewController;
- (void)configModelForSocialGroupId: (NSString *)socialGroupId socialGroupName: (NSString *)socialGroupName hasFollowed:(BOOL)followed;
- (void)publish;
- (BOOL)isEditedVote;
@end

NS_ASSUME_NONNULL_END
