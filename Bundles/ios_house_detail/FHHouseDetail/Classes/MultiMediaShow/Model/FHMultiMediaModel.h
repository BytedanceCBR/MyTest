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
};

NS_ASSUME_NONNULL_BEGIN

@interface FHMultiMediaItemModel : NSObject

@property(nonatomic, assign) FHMultiMediaType mediaType;
@property(nonatomic, copy) NSString *groupType;
@property(nonatomic, copy) NSString *videoID;
@property(nonatomic, copy) NSString *imageUrl;
@property(nonatomic, assign) NSTimeInterval currentPlaybackTime;
@property(nonatomic, strong) UIView *playerView;

@end

@interface FHMultiMediaModel : NSObject

@property(nonatomic, strong) NSArray<FHMultiMediaItemModel *> *medias;

@end

NS_ASSUME_NONNULL_END
