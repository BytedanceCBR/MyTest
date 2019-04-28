//
//  ExploreMomentImageAlbum.h
//  Article
//
//  Created by SunJiangting on 15-1-23.
//
//

#import "SSThemed.h"
#import "TTImageInfosModel.h"

typedef NS_ENUM(NSUInteger, ExploreMomentImageAlbumUIStyle)
{
    ExploreMomentImageAlbumUIStyleForward,
    ExploreMomentImageAlbumUIStyleMoment,
};

@protocol ExploreMomentImageAlbumDelegate;
@interface ExploreMomentImageAlbum : SSThemedView
@property (nonatomic, assign)ExploreMomentImageAlbumUIStyle albumStyle;
@property (nonatomic, copy)NSArray/*TTImageInfosModel*/  *images;

@property (nonatomic, assign) CGFloat   margin;
@property (nonatomic, weak)   id<ExploreMomentImageAlbumDelegate> delegate;

// Thumbnail images
@property (nonatomic, strong, readonly) NSArray * displayImages;
@property (nonatomic, strong, readonly) NSArray * displayImageViewFrames; // based on window coordinate

/// 相对于 Album的frame
- (CGRect)rectForImageAtIndex:(NSInteger)index;

+ (CGFloat)heightForImages:(NSArray *)images
        constrainedToWidth:(CGFloat)width
                    margin:(CGFloat)margin;

@end

@protocol ExploreMomentImageAlbumDelegate <NSObject>

@optional
- (void)imageAlbum:(ExploreMomentImageAlbum *)imageAlbum didClickImageAtIndex:(NSInteger)index;

@end
