//
//  TTAdVideoManager.h
//  Article
//
//  Created by yin on 16/8/19.
//
//

#import "TTAdVideoRelateLeftImageView.h"
#import "TTAdVideoRelateRightImageView.h"
#import "TTAdVideoRelateTopImageView.h"
#import "TTDetailNatantRelateReadViewModel.h"
#import <Foundation/Foundation.h>

@interface TTAdVideoManager : NSObject

+ (instancetype)sharedManager;

#pragma mark 相关视频列表小图广告

//https://wiki.bytedance.com/pages/viewpage.action?pageId=63229181
- (BOOL)relateIsSmallPicAdValid:(Article*)article;

- (BOOL)relateIsSmallPicAdCell:(Article *)aricle;

- (void)trackRelateAdShow:(Article*)article;

- (TTAdVideoRelateRightImageView*)relateRigthImageView:(Article *)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block;

- (TTAdVideoRelateLeftImageView*)relateLeftImageView:(Article *)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block;

- (TTAdVideoRelateTopImageView*)relateTopImageView:(Article *)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block;

//小图广告、视频广告都走此处action处理
- (void)relateHandleAction:(Article*)article;

#pragma mark 视频详情页Banner位广告
- (void)enteredVideoDetailPage:(BOOL)enter;

- (BOOL)isInVideoDetailPage;

- (UIView*)detailBannerPaddingView:(CGFloat)width topLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow;
@end
