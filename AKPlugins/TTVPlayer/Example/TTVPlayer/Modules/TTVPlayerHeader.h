//
//  TTVPlayerHeader.h
//  Article
//
//  Created by panxiang on 2018/7/24.
//

#import <UIKit/UIKit.h>

//表示播放器所用在的场合类型
typedef NS_ENUM(NSUInteger, TTVPlayerSource){
    TTVPlayerSourceList,    //列表播放
    TTVPlayerSourceLocal,   //离线缓存
    TTVPlayerSourceDetail,  //详情页播放
    TTVPlayerSourceLiveRoom,//聊天室播放
};


