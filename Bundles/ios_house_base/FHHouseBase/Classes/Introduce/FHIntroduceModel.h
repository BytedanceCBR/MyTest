//
//  FHIntroduceModel.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHIntroduceItemModel : NSObject

@property (nonatomic , assign) BOOL showJumpBtn;
@property (nonatomic , assign) BOOL showEnterBtn;
@property (nonatomic , copy) NSString *imageContentName;
@property (nonatomic , copy) NSString *lottieJsonStr;
@property (nonatomic , copy) NSString *indicatorImageName;
//是否已经播放过一次
@property (nonatomic , assign) BOOL played;

@end

@interface FHIntroduceModel : NSObject

@property (nonatomic , strong) NSArray<FHIntroduceItemModel *> *items;

@end

NS_ASSUME_NONNULL_END
