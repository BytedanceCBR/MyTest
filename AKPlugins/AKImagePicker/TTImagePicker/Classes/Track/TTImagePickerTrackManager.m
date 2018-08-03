//
//  TTImagePickTrackManager.m
//  Article
//
//  Created by SongChai on 2017/4/25.
//
//

#import "TTImagePickerTrackManager.h"
#import "TTImagePickerDefineHead.h"


@interface TTImagePickerTrackManager ()
- (void)reportTrack:(TTImagePickerTrackKey) key extra:(NSDictionary*) extra;
@end

__attribute__((overloadable)) void TTImagePickerTrack(TTImagePickerTrackKey key, NSDictionary* extra) {
//    NSLog(@"TTImagePickerTrackKey:%ld, extra:%@", key, extra);
    [[TTImagePickerTrackManager manager] reportTrack:key extra:extra];
}

@implementation TTImagePickerTrackManager {
    NSHashTable* _trackDelegates;
}

- (instancetype)init {
    if (self = [super init]) {
        _trackDelegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

+ (TTImagePickerTrackManager *)manager {
    static TTImagePickerTrackManager* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTImagePickerTrackManager alloc] init];
    });
    return instance;
}

- (void)addTrackDelegate:(id<TTImagePickTrackDelegate>)delegate {
    dispatch_main_async_safe_ttImagePicker(^{
        if (delegate && ![_trackDelegates containsObject:delegate]) {
            [_trackDelegates addObject:delegate];
        }
    });
}

- (void)removeTrackDelegate:(id<TTImagePickTrackDelegate>)delegate {
    dispatch_main_async_safe_ttImagePicker(^{
        if (delegate && [_trackDelegates containsObject:delegate]) {
            [_trackDelegates removeObject:delegate];
        }
    });
}

- (void)reportTrack:(TTImagePickerTrackKey) key extra:(NSDictionary*) extra {
    if (_trackDelegates) {
        dispatch_main_async_safe_ttImagePicker(^{
            for (id<TTImagePickTrackDelegate> delegate in _trackDelegates) {
                if ([delegate respondsToSelector:@selector(ttImagePickOnTrackType:extra:)]) {
                    [delegate ttImagePickOnTrackType:key extra:extra];
                }
            }
        });
    }
}
@end
