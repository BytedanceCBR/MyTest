//
//  FHIntroduceModel.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHIntroduceItemModel : NSObject

@property (nonatomic , copy) NSString *title;
@property (nonatomic , copy) NSString *subTitle;
@property (nonatomic , assign) BOOL showJumpBtn;
@property (nonatomic , assign) BOOL showEnterBtn;

@property (nonatomic , copy) NSString *lotty;

@end

@interface FHIntroduceModel : NSObject

@property (nonatomic , strong) NSArray<FHIntroduceItemModel *> *items;

@end

NS_ASSUME_NONNULL_END
