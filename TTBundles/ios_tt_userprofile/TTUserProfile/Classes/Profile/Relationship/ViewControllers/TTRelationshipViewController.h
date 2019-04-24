//
//  TTRelationshipViewController.h
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import <UIKit/UIKit.h>
#import "TTBaseThemedViewController.h"
#import "TTSocialBaseViewController.h"
#import "TTRelationshipDefine.h"


@interface TTRelationshipViewController : TTBaseThemedViewController
@property (nonatomic, assign) NSUInteger selectedIndex;
// 点击同一个tab，是否支持重新加载
@property (nonatomic, assign) BOOL reloadSelectedEnabled; // default is NO

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles viewControllers:(NSArray<TTSocialBaseViewController *> *)viewController;
- (instancetype)initWithTitles:(NSArray<NSString *> *)titles viewControllers:(NSArray<TTSocialBaseViewController *> *)viewController friendModel:(ArticleFriend *)aFriend;
- (instancetype)initWithTitles:(NSArray<NSString *> *)titles classNames:(NSArray<NSString *> *)classNames friendModel:(ArticleFriend *)aFriend;
- (instancetype)initWithSelectedIndex:(NSUInteger)idx titles:(NSArray<NSString *> *)titles viewControllers:(NSArray<TTSocialBaseViewController *> *)viewControllers friendModel:(ArticleFriend *)aFriend;

/**
 *  为了兼容老的接口，并减少依赖，使用NSUInteger代替RelationViewAppearType，用相应的常量值替代即可
 *
 *   RelationViewAppearTypePGCLikeUser = 0,
 *   RelationViewAppearFollowing       = 1,
 *   RelationViewAppearTypeFollower    = 2,
 *   RelationViewAppearTypeVisitor     = 3,
 *
 *  @param type    初始化类型
 *  @param aFriend 好友model
 *
 *  @return 好友社交关系圈实例
 */
- (instancetype)initWithAppearType:(NSUInteger)type currentUser:(ArticleFriend *)aFriend;

- (TTSocialBaseViewController *)viewControllerAtIndex:(NSUInteger)index;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
@end
