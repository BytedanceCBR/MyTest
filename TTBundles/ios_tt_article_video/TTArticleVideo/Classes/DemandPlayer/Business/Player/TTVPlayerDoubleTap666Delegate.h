//
//  TTVPlayerDoubleTap666Delegate.h
//  Article
//
//  Created by pei yun on 2017/11/1.
//

#ifndef TTVPlayerDoubleTap666Delegate_h
#define TTVPlayerDoubleTap666Delegate_h

typedef NS_ENUM(NSUInteger, TTVDoubleTapDigType) {
    TTVDoubleTapDigTypeCanDig,
    TTVDoubleTapDigTypeForbidDig,
    TTVDoubleTapDigTypeAlreadyDig,
    TTVDoubleTapDigTypeAlreadyBury,
};

@protocol TTVPlayerDoubleTap666Delegate <NSObject>

- (TTVDoubleTapDigType)ttv_doubleTapDigType;
- (void)ttv_doDigActionWhenDoubleTap:(TTVDoubleTapDigType)digType;

@end

#endif /* TTVPlayerDoubleTap666Delegate_h */
