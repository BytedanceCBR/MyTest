//
//  FRUploadImageModel.h
//  Forum
//
//  Created by Zhang Leonardo on 15-4-30.
//
//

#import <Foundation/Foundation.h>
#import "TTForumPostImageCache.h"

@interface FRUploadImageModel : NSObject<NSCoding>

@property(nonatomic, strong, readonly)TTForumPostImageCacheTask * cacheTask;

/**
 *  maybe nil, 用于列表显示
 */
@property (nonatomic, strong)UIImage * thumbnailImg;

@property(nonatomic, assign)BOOL isUploaded;
/**
 *  上传之后获取到的URI,上传只上传大图
 */
@property(nonatomic, strong)NSString * webURI;

/**
 *  本地读区和压缩耗时
 */
@property(nonatomic, assign)uint64_t localCompressConsume;

/**
 *  图片上传网络耗时
 */
@property(nonatomic, assign)uint64_t networkConsume;

/**
 上传次数
 */
@property(nonatomic, assign)uint64_t uploadCount;

/**
 图片尺寸(kb)，可能为0，上传时才能获取到
 */
@property(nonatomic, assign)uint64_t size;

/**
 是否是gif
 */
@property(nonatomic, assign, readonly)BOOL isGIF;

/**
 最后一次上传的error
 */
@property(nonatomic, strong)NSError *error;


- (id)initWithCacheTask:(TTForumPostImageCacheTask*)task thumbnail:(UIImage *)thumbnailImg;
/**
 *  SDWebImage存储使用的key，避免重复持久化
 */
@property(nonatomic, copy)NSString* fakeUrl;

+ (NSString *)fakeUrl:(NSString*)taskId index:(NSUInteger)index;
@end
