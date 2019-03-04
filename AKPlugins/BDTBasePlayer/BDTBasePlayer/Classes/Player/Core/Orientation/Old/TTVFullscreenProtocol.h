//
//  TTVFullscreenProtocol.h
//  Article
//
//  Created by xiangwu on 2017/1/4.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kTTVPlayerIsOnRotateAnimation @"kTTVPlayerIsOnRotateAnimation"

@protocol TTVFullscreenPlayerProtocol <NSObject>

@required
@property(nonatomic, assign ,readonly) BOOL hasMovieFatherCell;
@property(nonatomic, weak ,readonly) UITableView *movieFatherCellTableView;
@property(nonatomic, copy ,readonly) NSIndexPath *movieFatherCellIndexPath;
@property(nonatomic, weak ,readonly) UIView *movieFatherView;
- (CGRect)getMovieInFatherViewFrame;
- (void)forceStoppingMovie;

@end

@protocol TTVFullscreenCellProtocol <NSObject>

//- (CGRect)movieViewFrameRect;
//
//- (UIView *)detachMovieView;
//
//- (void)attachMovieView:(UIView *)movieView;

- (UIView *)ttv_playerSuperView;
@end
