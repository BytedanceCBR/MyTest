//
#import <BDTrackerProtocol/BDTrackerProtocol.h>
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
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"local_album" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyDidEnterNone:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"local_album_none" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyShoot:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"shoot" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyCancelShoot:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"cancel_shoot" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyConfirmShoot:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"confirm_shoot" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyClickAlbumList:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"album_list" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyAlbumChanged:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"album_list_changed" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyAlbumUnchanged:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"album_list_unchanged" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyListFinished:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"finish" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyPreview:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"preview" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyPreviewPhoto:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"preview_photo" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyPreviewFlip:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"flip" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyPreviewFinished:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"preview_photo_finish" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyPreviewPostEnter:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"post_photo_preview" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyPreviewPostDelete:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"post_photo_preview_delete" value:nil source:nil extraDic:self.ssTrackDict];
            break;
            
        //视频选择、预览类
        case TTImagePickerTrackKeyVideoDidEnter:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"enter" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyVideoClickClose:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"video_click_close" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyVideoGestureClose:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"video_flick_close" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyVideoClickAlbumList:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"video_local_album" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyVideoAlbumChanged:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"video_album_changed" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyVideoAlbumUnchanged:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"video_album_unchanged" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyVideoPreview:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"video_preview" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyVideoPreviewPlay:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"video_play" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyVideoPreviewPause:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"video_pause" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        case TTImagePickerTrackKeyVideoPreviewFinish:
            [BDTrackerProtocol trackEventWithCustomKeys:self.eventName label:@"video_finish" value:nil source:nil extraDic:self.ssTrackDict];
            break;
        default:
            break;
    }
}

@end
