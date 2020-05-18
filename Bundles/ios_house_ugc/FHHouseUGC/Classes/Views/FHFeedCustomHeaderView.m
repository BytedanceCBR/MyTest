//
//  FHFeedCustomHeaderView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/30.
//

#import "FHFeedCustomHeaderView.h"

@interface FHFeedCustomHeaderView ()

@property(nonatomic , assign) BOOL addProgressView;

@end

@implementation FHFeedCustomHeaderView

- (instancetype)initWithFrame:(CGRect)frame addProgressView:(BOOL)addProgressView {
    self = [super initWithFrame:frame];
    if (self) {
        _addProgressView = addProgressView;
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    if(_addProgressView){
        self.progressView = [FHPostUGCProgressView sharedInstance];
        [self addSubview:self.progressView];
    }
}

@end
