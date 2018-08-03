//
//  TTRNLiveView.h
//  Article
//
//  Created by yin on 2017/2/15.
//
//

#import "SSThemed.h"

@interface TTRNLiveView : UIView

@property (nonatomic, strong) NSDictionary* cover;
@property (nonatomic, strong) NSString* live_id;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) NSInteger play;
@property (nonatomic, assign) NSInteger videoPosition;
@end
