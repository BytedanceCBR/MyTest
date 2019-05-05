//
//  TTVVideoDetailVCDefine.h
//  Article
//
//  Created by pei yun on 2017/5/9.
//
//

#ifndef TTVVideoDetailVCDefine_h
#define TTVVideoDetailVCDefine_h

typedef NS_ENUM(NSInteger, TTVVideoDetailViewFromType)
{
    TTVVideoDetailViewFromTypeCategory,    //列表页
    TTVVideoDetailViewFromTypeRelated,     //详情页相关视频
    TTVVideoDetailViewFromTypeSplash,      //开屏 广告
    TTVVideoDetailViewFromTypeUnKnow
};

/*
 *  视频详情页展示状态
 */
typedef NS_ENUM(NSInteger, TTVVideoDetailViewShowStatus)
{
    TTVVideoDetailViewShowStatusVideo,     //显示视频区
    TTVVideoDetailViewShowStatusComment    //显示评论区
};

#endif /* TTVVideoDetailVCDefine_h */
