//
//  TTRNVideoView.h
//  Article
//
//  Created by yin on 2016/12/29.
//
//

#import "SSThemed.h"
#import "RCTView.h"

@interface TTRNVideoView : UIView

@property (nonatomic, strong) NSDictionary* cover;
@property (nonatomic, strong) NSString* video_id;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) NSInteger play;
@property (nonatomic, assign) NSInteger videoPosition;

@end
