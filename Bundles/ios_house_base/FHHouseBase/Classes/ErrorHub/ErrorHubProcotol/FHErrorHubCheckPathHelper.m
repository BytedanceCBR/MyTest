//
//  FHErrorHubCheckPathHelper.m
//  FHHouseBase
//
//  Created by liuyu on 2020/6/11.
//

#import "FHErrorHubCheckPathHelper.h"

@implementation FHErrorHubCheckPathHelper
+ (NSArray *)FHErrorHubCheckRequestPathList {
    return @[
        @"https://i.haoduofangs.com/f100/api/neighborhood/info", //周边详情页请求
        @"https://i.haoduofangs.com/f100/api/court/info",//新房详情页请求
        @"https://i.haoduofangs.com/f100/api/house/info",//二手房详情页请求
        @"https://i.haoduofangs.com/f100/api/rental/info",//租房详情页请求
        @"https://i.haoduofangs.com/f100/api/related_rent",//租房详情页-周边房源
        @"https://i.haoduofangs.com/f100/api/same_neighborhood_rent",//租房详情页-同小区房源
        @"https://i.haoduofangs.com/f100/api/v2/recommend",//recommend接口请求
        @"https://i.haoduofangs.com/f100/v2/api/config", //config接口请求
        @"https://i.haoduofangs.com/f100/api/same_neighborhood_house",//二手房同小区房源
        @"https://i.haoduofangs.com/f100/api/related_neighborhood",//二手房周边小区
        @"https://i.haoduofangs.com/f100/api/related_house",//二手房周边房源
        @"https://i.haoduofangs.com/f100/api/search",//请求房子信息
        @"https://i.haoduofangs.com/f100/api/search_rent",//租房请求
        @"https://i.haoduofangs.com/f100/api/search_court",//新房列表请求
        @"https://i.haoduofangs.com/f100/api/search_neighborhood",//小区列表请求
        @"https://i.haoduofangs.com/f100/ugc/thread",//ugc发帖
        @"https://i.haoduofangs.com/f100/ugc/material/v1/vote_detail",//投票详情页
        @"https://i.haoduofangs.com/f100/social_group_basic_info",//圈子详情页的头部信息接口
        @"https://i.haoduofangs.com/ff100/ugc/vote/publish",//投票发布相关接口
        @"https://i.haoduofangs.com/ff100/ugc/question/publish",//提问发布器相关接口
        @"https://i.haoduofangs.com/f100/api/similar_house",//首页相似推荐房源接口
        @"https://i.haoduofangs.com/f100/ugc/digg",//点赞通用接口
        @"https://i.haoduofangs.com/f100/ugc/vote/submit",// 提交投票
        @"https://i.haoduofangs.com/f100/ugc/vote/cancel",//取消投票
        @"https://i.haoduofangs.com/f100/ugc/follow",//关注
        @"https://i.haoduofangs.com/f100/ugc/unfollow",//取消关注
        @"https://i.haoduofangs.com/f100/api/popup_api/get_popup_configs",//弹窗下发
    ];
}
@end
