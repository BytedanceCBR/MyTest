//
//  TTMovieFullscreenProtocol.h
//  Article
//
//  Created by xiangwu on 2017/1/4.
//
//

#import <Foundation/Foundation.h>
#import "TTVFullscreenProtocol.h"

@protocol TTMovieFullscreenProtocol <NSObject>

@required
@property(nonatomic, assign) BOOL hasMovieFatherCell;
@property(nonatomic, weak, nullable) UITableView *movieFatherCellTableView;
@property(nonatomic, copy, nullable) NSIndexPath *movieFatherCellIndexPath;
@property(nonatomic, weak, nullable) UIView *movieFatherView;
@property(nonatomic, assign) CGRect movieInFatherViewFrame;

- (void)forceStoppingMovie;

@end
