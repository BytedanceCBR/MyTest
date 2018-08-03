//
//  ArticleProfileFollowConst.h
//  Article
//
//  Created by Chen Hong on 14-10-11.
//
//

#ifndef Article_ArticleProfileFollowConst_h
#define Article_ArticleProfileFollowConst_h


// 用于统计‘用户个人主页’点击添加关注行为的来源
// https://wiki.bytedance.com/pages/viewpage.action?pageId=15142000

// 进用户首页的from标记
static NSString * const kFromNewsDetailComment = @"com";        // 详情页评论
static NSString * const kFromFeed = @"frfeed";                     // feed流推荐用户
static NSString * const kFromFeedDynamic = @"frdynamicrec";        // 动态推荐用户
static NSString * const kFromFeedForum = @"frforumrec";        // 话题推荐用户
static NSString * const kFromFeedItem = @"feeditem";            //动态feed流item用户
static NSString * const kFromFeedDigg = @"feeddigg";            //动态feed流赞用户
static NSString * const kFromFeedCom = @"feedcom";              //动态feed流评论用户
static NSString * const kFromPGC = @"frpgc";                    //pgc读者收藏/顶列表
static NSString * const kFromAddFriend = @"fradd";                // 动态添加好友页面
static NSString * const kFromMyFollowers = @"frmyfol";            // 自己的关注列表
static NSString * const kFromMyFans = @"frmyfan";                 // 自己的粉丝列表
static NSString * const kFromMyVisitors = @"frmyvisitors";         // 自己的游客列表
static NSString * const kFromOtherVisitors = @"frvisitors";        // 他人的游客列表
static NSString * const kFromOtherFollowers = @"frfol";           // 他人的关注列表
static NSString * const kFromOtherFans = @"frfan";                // 他人的粉丝列表
static NSString * const kFromFeedDetail = @"det";               // 动态详情页
static NSString * const kFromFeedDetailComment = @"detcom";     // 动态详情页评论
static NSString * const kFromFeedDetailDig = @"detdig";         // 动态详情页赞列表
static NSString * const kFromMyMsg = @"frmess";                  // 我的消息
static NSString * const kFromHotComment = @"frhotcom";            // pad热门评论
static NSString * const kFromEssayGodCom = @"godcom";           // 段子神评论

// 可直接关注的标记
static NSString * const kAddFriend = @"add";                    // 添加好友页面
static NSString * const kOtherFollowers = @"fol";               // 他人关注列表
static NSString * const kOtherFans = @"fan";                    // 他人粉丝列表
static NSString * const kMyFollowers = @"myfol";                // 自己的关注列表
static NSString * const kMyFans = @"myfan";                    // 自己的粉丝列表
static NSString * const kFeedRec = @"feedrec";                  // feed流推荐用户
static NSString * const kDynamicRec = @"dynrec";                // 动态推荐用户
static NSString * const kForumRec = @"forumrec";              // 话题推荐用户

#endif
