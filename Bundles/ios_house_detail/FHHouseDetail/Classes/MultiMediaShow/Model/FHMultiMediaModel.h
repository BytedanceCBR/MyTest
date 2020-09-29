//
//  FHMultiMediaModel.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"

typedef NS_ENUM(NSUInteger, FHMultiMediaType) {
    FHMultiMediaTypeVideo, //视频
    FHMultiMediaTypePicture, //图片
    FHMultiMediaTypeVRPicture, //VR图片
    FHMultiMediaTypeBaiduPanorama, //百度街景
};


typedef NS_ENUM(NSUInteger, FHMultiMediaCellHouseType) {
    FHMultiMediaCellHouseSecond, //二手房
    FHMultiMediaCellHouseNeiborhood, //小区
};

NS_ASSUME_NONNULL_BEGIN
@protocol FHMultiMediaItemModel <NSObject>


@end

@interface FHMultiMediaItemModel : NSObject

@property(nonatomic, copy) NSString *pictureTypeName;           //rootName
@property(nonatomic, assign) FHDetailHouseImageType pictureType;//并没有用到
@property(nonatomic, assign) FHMultiMediaType mediaType;        //轮播图需要
@property(nonatomic, copy) NSString *vrOpenUrl;                 //vr的URL
@property(nonatomic, copy) NSString *groupType;                 //所属下面tab的名称
@property(nonatomic, assign) FHMultiMediaCellHouseType cellHouseType;
@property(nonatomic, copy) NSString *videoID;
@property(nonatomic, copy) NSString *imageUrl;
@property(nonatomic, assign) NSTimeInterval currentPlaybackTime;
@property(nonatomic, strong) UIView *playerView;
@property(nonatomic, assign)   CGFloat       vWidth;
@property(nonatomic, assign)   CGFloat       vHeight;
@property (nonatomic, copy , nullable) NSString *infoSubTitle;
@property (nonatomic, copy , nullable) NSString *infoTitle;
@property(nonatomic, copy) NSString *instantImageUrl;


@end

@interface FHMultiMediaModel : NSObject

@property(nonatomic, strong) NSArray<FHMultiMediaItemModel *> *medias;
@property (nonatomic, assign) BOOL isShowSkyEyeLogo;
@end


NS_ASSUME_NONNULL_END
