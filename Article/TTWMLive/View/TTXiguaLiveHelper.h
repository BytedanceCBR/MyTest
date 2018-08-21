//
//  TTXiguaLiveHelper.h
//  Article
//
//  Created by lipeilun on 2017/12/5.
//

#import <Foundation/Foundation.h>

static inline CGFloat xg_left() {
    return 15.f;
}

static inline CGFloat xg_right() {
    return 15.f;
}

static inline CGFloat xg_horcell_mid() {
    return 9.f;
}

static inline CGFloat xg_horcell_top() {
    return [TTDeviceUIUtils tt_newPadding:40];
}

static inline CGFloat xg_horcell_toptitle_top() {
    return [TTDeviceUIUtils tt_newPadding:12];
}

static inline CGFloat xg_horcell_toptitle_width() {
    return [TTDeviceUIUtils tt_newPadding:60];
}

static inline CGFloat xg_horcell_toptitle_height() {
    return [TTDeviceUIUtils tt_newPadding:16];
}

static inline CGFloat xg_horcell_pic_hw_factor() {
    return 194.f / 168.f;
}

static inline CGFloat xg_horcell_title_height() {
    return [TTDeviceUIUtils tt_newPadding:24];
}

static inline CGFloat xg_horcell_title_top() {
    return [TTDeviceUIUtils tt_newPadding:8];
}

static inline CGFloat xg_horcell_desc_top() {
    return [TTDeviceUIUtils tt_newPadding:4];
}

static inline CGFloat xg_horcell_desc_padding() {
    return [TTDeviceUIUtils tt_newPadding:5];
}


static inline CGFloat xg_horcell_desc_height() {
    return [TTDeviceUIUtils tt_newPadding:17];
}

static inline CGFloat xg_horcell_desc_bottom() {
    return [TTDeviceUIUtils tt_newPadding:12];
}

static inline CGFloat xg_horcell_live_padding() {
    return [TTDeviceUIUtils tt_newPadding:8];
}

static inline CGFloat xg_colcell_left() {
    return [TTDeviceUIUtils tt_newPadding:12];
}

static inline CGFloat xg_colcell_right() {
    return [TTDeviceUIUtils tt_newPadding:12];
}


@class TTXiguaLiveModel;
@interface TTXiguaLiveHelper : NSObject

+ (NSString *)generateDescText:(TTXiguaLiveModel *)model;

@end
