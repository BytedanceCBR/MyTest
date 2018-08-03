//
//  TTImagePickerTrackDelegate.m
//  Article
//
//  Created by tyh on 2017/4/25.
//
//

#import "TTImagePickerTrackDelegate.h"
#import <TTTrackerWrapper.h>

@interface TTImagePickerTrackDelegate()

@property (nonatomic,copy)NSDictionary *ssTrackDict;
@property (nonatomic,copy)NSString *eventName;

@end

@implementation TTImagePickerTrackDelegate


- (instancetype)initWithEventName:(NSString *)eventName TrackDic:(NSDictionary *)ssTrackDict;
{
    self = [super init];
    if (self) {
        self.ssTrackDict = ssTrackDict;
        self.eventName = eventName;
        [[TTImagePickerTrackManager manager] addTrackDelegate:self];
    }
    return self;
}

#pragma mark - TTImagePickTrackDelegate

- (void) ttImagePickOnTrackType:(TTImagePickerTrackKey) type extra:(NSDictionary*)extra
{
    
    switch (type) {
        //图片选择、预览类
        case TTImagePickerTrackKeyDidEnter:
            wrapperTrackEventWithCustomKeys(self.eventName, @"local_album", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyDidEnterNone:
            wrapperTrackEventWithCustomKeys(self.eventName, @"local_album_none", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyShoot:
            wrapperTrackEventWithCustomKeys(self.eventName, @"shoot", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyCancelShoot:
            wrapperTrackEventWithCustomKeys(self.eventName, @"cancel_shoot", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyConfirmShoot:
            wrapperTrackEventWithCustomKeys(self.eventName, @"confirm_shoot", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyClickAlbumList:
            wrapperTrackEventWithCustomKeys(self.eventName, @"album_list", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyAlbumChanged:
            wrapperTrackEventWithCustomKeys(self.eventName, @"album_list_changed", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyAlbumUnchanged:
            wrapperTrackEventWithCustomKeys(self.eventName, @"album_list_unchanged", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyListFinished:
            wrapperTrackEventWithCustomKeys(self.eventName, @"finish", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyPreview:
            wrapperTrackEventWithCustomKeys(self.eventName, @"preview", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyPreviewPhoto:
            wrapperTrackEventWithCustomKeys(self.eventName, @"preview_photo", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyPreviewFlip:
            wrapperTrackEventWithCustomKeys(self.eventName, @"flip", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyPreviewFinished:
            wrapperTrackEventWithCustomKeys(self.eventName, @"preview_photo_finish", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyPreviewPostEnter:
            wrapperTrackEventWithCustomKeys(self.eventName, @"post_photo_preview", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyPreviewPostDelete:
            wrapperTrackEventWithCustomKeys(self.eventName, @"post_photo_preview_delete", nil, nil, self.ssTrackDict);
            break;
            
        //视频选择、预览类
        case TTImagePickerTrackKeyVideoDidEnter:
            wrapperTrackEventWithCustomKeys(self.eventName, @"enter", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyVideoClickClose:
            wrapperTrackEventWithCustomKeys(self.eventName, @"video_click_close", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyVideoGestureClose:
            wrapperTrackEventWithCustomKeys(self.eventName, @"video_flick_close", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyVideoClickAlbumList:
            wrapperTrackEventWithCustomKeys(self.eventName, @"video_local_album", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyVideoAlbumChanged:
            wrapperTrackEventWithCustomKeys(self.eventName, @"video_album_changed", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyVideoAlbumUnchanged:
            wrapperTrackEventWithCustomKeys(self.eventName, @"video_album_unchanged", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyVideoPreview:
            wrapperTrackEventWithCustomKeys(self.eventName, @"video_preview", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyVideoPreviewPlay:
            wrapperTrackEventWithCustomKeys(self.eventName, @"video_play", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyVideoPreviewPause:
            wrapperTrackEventWithCustomKeys(self.eventName, @"video_pause", nil, nil, self.ssTrackDict);
            break;
        case TTImagePickerTrackKeyVideoPreviewFinish:
            wrapperTrackEventWithCustomKeys(self.eventName, @"video_finish", nil, nil, self.ssTrackDict);
            break;
        default:
            break;
    }
}

@end
