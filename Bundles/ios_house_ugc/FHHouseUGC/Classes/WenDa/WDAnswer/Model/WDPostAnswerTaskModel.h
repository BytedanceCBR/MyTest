//
//  WDPostAnswerTaskModel.h
//  Article
//
//  Created by 王霖 on 15/12/21.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WDPostAnswerType) {
    WDPostAnswerTypeRichText = 0, // 富文本回答，实际上就只有一个HTML文本，解析出对应的video和image标签，传输content一个字段
    WDPostAnswerTypePictureText = 1, // 图文回答，需要传输content，imageList以及richSpanText三个字段
    // 小视频回答不支持从taskModel进行发送
};

@protocol WDUploadImageModelProtocol;
@class WDImageObjectUploadImageModel, WDImagePathUploadImageModel;

@interface WDPostAnswerTaskModel : NSObject<NSCoding, NSCopying>

@property (nonatomic, copy, readonly, nonnull) NSString *qid; // 唯一标识对应qid，不允许为空

@property (nonatomic, copy) NSString *content; // 上传内容，对富文本是HTML，对图文是文本内容（排除@标签）
@property (nonatomic, copy, nullable) NSArray<id<WDUploadImageModelProtocol>> *imageList; // 上传的图片
@property (nonatomic, copy, nullable) NSString *richSpanText; // 图文模式下上传的标签
@property (nonatomic, assign) WDPostAnswerType answerType; // 回答类型，分富文本和图文

@property (nonatomic, assign) BOOL isMutate;
@property (nonatomic, assign) NSTimeInterval timeStamp;

@property (nonatomic, assign) NSUInteger pasteTimes;
@property (nonatomic, assign) NSUInteger pastLength;

/** 图文用构造方法 */
- (instancetype)initWithQid:(NSString *)qid
                    content:(nullable NSString *)content
            contentRichSpan:(nullable NSString *)contentRichSpan
                  imageList:(nullable NSArray<WDImageObjectUploadImageModel *> *)imageList;

- (void)refreshCurrentSandBoxPath;
- (void)refreshTimeStamp;

- (nullable NSArray<NSString *> *)remoteImgUris; // 如果图片上传完之后，会返回图片的uri数组

@end

// 现在的实现，是把草稿和上传统一成一个Model，但是这个Model设计成KVO的形式，因此需要有一个值单独表示草稿还未加载这种case（不能依赖content来判断，毕竟answerType不同策略不同）
@interface WDPostAnswerTaskModel (DraftManager)

@property (nonatomic, assign) BOOL hasLoadDraft; // 是否草稿已经加载过，不持久化

@end

NS_ASSUME_NONNULL_END
