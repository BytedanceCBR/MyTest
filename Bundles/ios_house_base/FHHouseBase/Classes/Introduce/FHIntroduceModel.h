//
//  FHIntroduceModel.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 配置引导介绍页
 *
 * 负责管理引导页的参数配置
 */

@interface FHIntroduceItemModel : NSObject

//是否显示“跳过”按钮
@property (nonatomic , assign) BOOL showJumpBtn;
//是否显示“进入”按钮
@property (nonatomic , assign) BOOL showEnterBtn;
//这个暂时不用，以后直接放图片考虑使用
@property (nonatomic , copy) NSString *imageContentName;
//lottie动画使用的json文件名
@property (nonatomic , copy) NSString *lottieJsonStr;
//下方指示器的图片
@property (nonatomic , copy) NSString *indicatorImageName;
//是否已经播放过一次
@property (nonatomic , assign) BOOL played;

@end

@interface FHIntroduceModel : NSObject

@property (nonatomic , strong) NSArray<FHIntroduceItemModel *> *items;

@end

NS_ASSUME_NONNULL_END
