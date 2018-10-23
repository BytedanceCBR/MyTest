//
//  TTImagePickTrackManager.h
//  Article
//
//  Created by SongChai on 2017/4/25.
//
//

#import <Foundation/Foundation.h>



//key名和tag名字一致，
typedef enum: NSUInteger {
    //图片选择
    TTImagePickerTrackKeyDidEnter,          //进入本地图片选择页，有图
    TTImagePickerTrackKeyDidEnterNone,      //进入本地图片选择页，无图
    TTImagePickerTrackKeyShoot,             //点拍照
    TTImagePickerTrackKeyCancelShoot,       //取消拍照
    TTImagePickerTrackKeyConfirmShoot,      //确定拍照
    TTImagePickerTrackKeyClickAlbumList,    //点击相册列表
    TTImagePickerTrackKeyAlbumChanged,      //改变相册
    TTImagePickerTrackKeyAlbumUnchanged,    //收起，未改变
    TTImagePickerTrackKeyListFinished,      //列表完成
    TTImagePickerTrackKeyPreview,           //左下角进入预览页
    TTImagePickerTrackKeyPreviewPhoto,      //点图片进入预览页
    TTImagePickerTrackKeyPreviewFlip,       //预览滑动
    TTImagePickerTrackKeyPreviewFinished,   //预览完成
    
    TTImagePickerTrackKeyPreviewPostEnter,   //进入发布页预览
    TTImagePickerTrackKeyPreviewPostDelete,  //发布页预览、点击垃圾桶删除
    
    //视频选择
    TTImagePickerTrackKeyVideoDidEnter,      //进入视频选择页
    TTImagePickerTrackKeyVideoClickClose,    //点击关闭视频选择页
    TTImagePickerTrackKeyVideoGestureClose,  //手势关闭视频选择页
    TTImagePickerTrackKeyVideoClickAlbumList,//点击视频相册列表
    TTImagePickerTrackKeyVideoAlbumChanged,  //改变视频相册
    TTImagePickerTrackKeyVideoAlbumUnchanged,//收起视频相册，未改变
    TTImagePickerTrackKeyVideoPreview,       //进入视频预览页
    TTImagePickerTrackKeyVideoPreviewPlay,   //视频播放
    TTImagePickerTrackKeyVideoPreviewPause,  //视频暂停
    TTImagePickerTrackKeyVideoPreviewFinish, //进入视频完成
    
    
    //图片视频混合模式
    TTImagePickerTrackKeyPhotoVideoDidEnter, //进入图片视频选择页
    TTImagePickerTrackKeyPhotoVideoPreviewPhoto,  //进入图片详情页预览
    TTImagePickerTrackKeyPhotoVideoPreviewVideo,  //进入视频详情页预览
    TTImagePickerTrackKeyPhotoVideoPreview,//点击预览按钮预览
    //TTImagePickerTrackKeyPhotoVideoFlip(暂时用 TTImagePickerTrackKeyPreviewFlip)  //预览滑动图片或视频
    TTImagePickerTrackKeyPhotoVideoClickAlbumList,//点击视频相册列表
    TTImagePickerTrackKeyPhotoVideoAlbumChanged,  //改变视频相册
    TTImagePickerTrackKeyPhotoVideoAlbumUnchanged,//收起视频相册，未改变



} TTImagePickerTrackKey;

extern __attribute__((overloadable)) void TTImagePickerTrack(TTImagePickerTrackKey key, NSDictionary* extra);

@protocol TTImagePickTrackDelegate <NSObject>

- (void) ttImagePickOnTrackType:(TTImagePickerTrackKey) type extra:(NSDictionary*)extra;
@end

@interface TTImagePickerTrackManager : NSObject
+ (TTImagePickerTrackManager*) manager;

- (void) addTrackDelegate:(id<TTImagePickTrackDelegate>)delegate;
- (void) removeTrackDelegate:(id<TTImagePickTrackDelegate>)delegate;
@end
