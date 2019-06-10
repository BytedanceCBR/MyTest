//
//  TTPersonalHomeViewController.h
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import <UIKit/UIKit.h>

@interface TTPersonalHomeViewController : UIViewController
@property (nonatomic, assign) BOOL fromColdStart;
- (instancetype)initWithUserID:(NSString *)userID
                       mediaID:(NSString *)mediaID
                         refer:(NSString *)refer
                        source:(NSString *)source
                      fromPage:(NSString *)fromPage
                      category:(NSString *)categoryName
                       groupId:(NSString *)groupId
                 profileUserId:(NSString *)profileUserId
                   serverExtra:(NSString *)serverExtra
    enterHomepageV3ExtraParams:(NSDictionary *)enterHomepageV3ExtraParams;

//请在viewDidLoad前调用，可以不显示loading动画，快速打开
- (void)configWithUserName:(NSString *)userName
                    avatar:(NSString *)avatarURL
              userAuthInfo:(NSString *)userAuthInfo
               isFollowing:(BOOL)isFollowing
                isFollowed:(BOOL)isFollowed
                   summary:(NSString *)summary
               followCount:(NSUInteger)followCount
                 fansCount:(NSUInteger)fansCount;
@end
