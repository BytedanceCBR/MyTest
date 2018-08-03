//
//  TTBubbleViewHeader.h
//  Article
//
//  Created by 王双华 on 2017/8/15.
//
//

#import "TTBubbleView.h"

typedef NS_ENUM(NSUInteger,TTBubbleViewType){
    TTBubbleViewTypeDefault = 1,                //默认tip,纯文字或者图在左边
    TTBubbleViewTypeTimerNewsTip,               //"首页"定时出tip
    TTBubbleViewTypeTimerVideoTip,              //"视频"定时出tip
    TTBubbleViewTypeTimerPostUGCTip,            //"发布器"定时出tip
    TTBubbleViewTypeTimerFollowTip,             //"关注"定时出tip
    TTBubbleViewTypeTimerWeitoutiaoTip,         //"微头条"定时出tip
    TTBubbleViewTypeTimerMineTabTip,            //"我的tab"定时出tip
    TTBubbleViewTypeTimerHTSTabTip,             //"小视频tab"定时出tip
    TTBubbleViewTypeTimerMineTopEntranceTip,    //"我的"顶部定时出的tips
    
    TTBubbleViewTypeVideoTip,                   //"视频"tip
    TTBubbleViewTypeConcernTip,                 //"关注"tip
    TTBubbleViewTypeMineTopEntranceTip,         //"我的"顶部的tips
    TTBubbleViewTypePostUGCTip,                 //"UGC发布入口"tip
    TTBubbleViewTypeMyFollowTip,                //我的关注旧用户引导tip
    TTBubbleViewTypePostUGCEntranceChangeTip,   //发布入口变更tip
    TTBubbleViewTypePrivateLetterTip,           //私信入口tip
    TTBubbleViewTypeWendaListTip,               //问答列表tips
    TTBubbleViewTypeSupportsEmojiInputTip,      //评论支持发布表情tip
    TTBubbleViewTypeNightShiftMode,             //护眼模式tip
    TTBubbleViewTypeResurfaceTip,               //换肤tip
    TTBubbleViewTypeCommonwealTip,              //@王迪 加下注释
    TTBubbleViewTypeMutilDiggTip,               //连续点赞tip
    TTBubbleViewTypeShortVideoTabTip,           //小视频tab tip
};
