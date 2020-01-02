//
//  FHMultiMediaModel.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FHMultiMediaType) {
    FHMultiMediaTypeVideo, //视频
    FHMultiMediaTypePicture, //图片
    FHMultiMediaTypeVRPicture, //VR图片
};


typedef NS_ENUM(NSUInteger, FHMultiMediaCellHouseType) {
    FHMultiMediaCellHouseSecond, //二手房
    FHMultiMediaCellHouseNeiborhood, //小区
};

NS_ASSUME_NONNULL_BEGIN

@interface FHMultiMediaItemModel : NSObject

@property(nonatomic, assign) FHMultiMediaType mediaType;
@property(nonatomic, copy) NSString *groupType;
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
