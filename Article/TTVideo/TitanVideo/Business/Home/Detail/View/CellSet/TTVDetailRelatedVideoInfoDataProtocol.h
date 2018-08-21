//
//  TTVDetailRelatedVideoInfoDataProtocol.h
//  Article
//
//  Created by pei yun on 2017/6/2.
//
//

#ifndef TTVDetailRelatedVideoInfoDataProtocol_h
#define TTVDetailRelatedVideoInfoDataProtocol_h

@class TTImageInfosModel;
@class TTVRelatedVideoAD;
@protocol TTVDetailRelatedADInfoDataProtocol;
@protocol TTVDetailRelatedVideoInfoDataProtocol <NSObject>

@property (nonatomic, strong, readonly) NSNumber *groupFlags;
@property (nonatomic, strong, readonly) NSString *source;
@property (nonatomic, retain, readonly) NSNumber * commentCount;
@property (nonatomic, retain, readonly) NSString     *mediaName;//订阅号名称
@property (nonatomic, retain, readonly) NSDictionary *videoDetailInfo;
@property (nonatomic, strong, readonly) NSString *relatedVideoExtraInfoShowTag;//相关视频数据特殊数据（视频专题、视频合辑、视频推广等），非持久化 add by 5.6
/**
 *  相关视频广告，将广告数据全存在此属性内
 */
@property (nonatomic, retain, readonly) NSNumber     *videoDuration;
@property (nonatomic, retain, readonly) NSNumber * hasRead;
@property (nonatomic, retain, readonly) NSString       *title;
@property (nonatomic, strong, readonly) id<TTVDetailRelatedADInfoDataProtocol> videoAdExtra;


- (nullable TTImageInfosModel *)listMiddleImageModel;

@end

#endif /* TTVDetailRelatedVideoInfoDataProtocol_h */
