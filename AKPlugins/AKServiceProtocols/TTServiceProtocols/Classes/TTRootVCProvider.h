//
//  TTRootVCProvider.h
//  Pods
//
//  Created by fengyadong on 2017/3/23.
//
//

@protocol TTRootVCProvider <NSObject>

@required

/**
 在tabBar上注册子vc和文案图片

 @param vc 被注册的vc
 @param title tabBarItem的标题
 @param bundleName tabBarItem图片所在bundle的名字，默认为主bundle
 @param imagePath 自定义图片保存的沙盒目录，该参数不为空的话优先级比bundleName要高
 @param imageName tabBarItem图片的文件名，如果开始名字叫home 则夜间必须是home_night 选中时home_pressed 夜间选中时home_night_pressed
 @param index 被注册vc所在tab的下标
 */
- (void)registerViewController:(UIViewController *)vc
                        title:(NSString *)title
                   bundleName:(NSString *)bundleName
                customImagePath:(NSString *)imagePath
                        imageName:(NSString *)imageName
                        atIndex:(NSUInteger)index;



/**
 获取tabBar上item的title

 @param index item的位置
 @return item的title
 */
- (NSString *)getItemTitleForIndex:(NSUInteger)index;

/**
 获取tabBar上item的image

 @param index item的位置
 @return item的image
 */
- (UIImage *)getItemImageForIndex:(NSUInteger)index isHighlighted:(BOOL)highlighted;

/**
 返回整个app的根vc

 @return 整个app的根vc
 */
- (UIViewController *)rootViewController;

@end
