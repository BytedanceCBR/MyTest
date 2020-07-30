//
//  FHBlockTransformer.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/7/30.
//

#import "BDBaseTransformer.h"

NS_ASSUME_NONNULL_BEGIN

typedef UIImage * _Nullable (^FHTransformBlock)(UIImage *_Nullable image);

@interface FHBlockTransformer : BDBaseTransformer

/**
 *  用于通过block创建Transformer。transform的图片会被缓存
 *
 *  @param block 处理图片使用的block
 *
 *  @return 一个使用block对图片进行处理的Transformer
 */
+ (nonnull instancetype)transformWithBlock:(nonnull FHTransformBlock)block;

@end

NS_ASSUME_NONNULL_END
