//
//  AKShareView.h
//  Article
//
//  Created by 冯靖君 on 2018/3/12.
//

#import <UIKit/UIKit.h>
#import <SSThemed.h>
#import "AKShareManager.h"

@interface AKShareButton : UIControl
@end

typedef NS_ENUM(NSInteger,AKShareIconType)
{
    AKShareIconTypeDefault = 0,
    AKShareIconTypeFetch,//摸牌页面所使用的样式
    AKShareIconTypeNoBorder,//分享板，没有边框的图标
};

typedef NS_ENUM(NSInteger, AKShareSupportPlatform)
{
    AKShareSupportPlatformWeChat = 1 << 1,
    AKShareSupportPlatformWeChatFriend = 1 << 2,
    AKShareSupportPlatformQQ = 1 << 3,
};

typedef void(^ShareBlock)(AKSharePlatform type);
typedef void(^ShareResultBlock)(AKSharePlatform type, NSDictionary *extra, NSError *error);

@interface AKShareView : UIScrollView

/**
 当点击分享入口的时候会执行该block
 */
@property (nonatomic, copy)ShareBlock                    shareBlock;
@property (nonatomic, copy)ShareResultBlock              shareResultBlock;
@property (nonatomic, copy)NSString                     *labelTextColorHex;
@property (nonatomic, assign)AKShareIconType           iconType;
@property (nonatomic, copy)  NSDictionary               *shareInfo;
@property (nonatomic, strong)UIImage                    *shareImage;
@property (nonatomic, assign)AKShareSupportPlatform    disablePlatform;//禁用支持的部分按钮，默认禁用保存图片
@property (nonatomic, copy, readonly)  NSArray<AKShareButton *> *supportShareButton;
//传入event_type，event_type不要传枚举,以及share_type
@property (nonatomic, copy)NSDictionary                 *trackDict;
@property (nonatomic, copy)NSAttributedString           *tipTitle;
/**
 创建一个分享面板,缺少一个分享内容的字段，后补
 
 @param shareBlock 点击的时候回调
 @param viewWidth 指定宽度，传入-1则使用默认
 @return AKShareView
 */
- (instancetype)initWithShareBlock:(ShareBlock)shareBlock
                         viewWidth:(CGFloat)viewWidth
                         shareInfo:(NSDictionary *)shareInfo
                        disableTip:(BOOL)disableTip;

/**
 创建一个分享面板,缺少一个分享内容的字段，后补
 
 @param shareBlock 点击的时候回调
 @param ShareResultBlock 结果回调
 @param viewWidth 指定宽度，传入-1则使用默认
 @return AKShareView
 */
- (instancetype)initWithShareBlock:(ShareBlock)shareBlock
                  shareResultBlock:(ShareResultBlock)shareResultBlock
                         viewWidth:(CGFloat)viewWidth
                         shareInfo:(NSDictionary *)shareInfo
                        disableTip:(BOOL)disableTip NS_DESIGNATED_INITIALIZER;


@end
