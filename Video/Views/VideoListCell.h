//
//  VideoListCell.h
//  Video
//
//  Created by Tianhang Yu on 12-7-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum VideoListCellType {
    VideoListCellTypeNormal,
    VideoListCellTypeDownloading,
    VideoListCellTypeHasDownload
} VideoListCellType;

@class VideoData;

@interface VideoListCell : UITableViewCell

@property (nonatomic, retain, readonly) VideoData *videoData;
@property (nonatomic, copy) NSString *trackEventName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setVideoData:(VideoData *)videoData type:(VideoListCellType)type;
- (void)refreshUI;

@end
