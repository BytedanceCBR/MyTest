//
//  TTCommentStore.m
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import "TTMomentDetailStore.h"
#import "TTMomentDetailReducer.h"


@implementation TTMomentDetailIndependenceState

- (instancetype)init {
    self = [super init];
    if (self) {
        _hasMoreStickComment = YES;
    }
    return self;
}

@end

@interface TTMomentDetailStore()
@property (nonatomic, strong) id<Middleware> middleware;
@end

@implementation TTMomentDetailStore
@dynamic state;

+ (instancetype)sharedStore {
    static TTMomentDetailStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[TTMomentDetailStore alloc] init];
    });
    return store;
}

- (instancetype)init {
    self = [super initWithReducer:[[TTMomentDetailReducer alloc] init]];
    if (self) {
        self.reducer.store = self;
        self.state = [[TTMomentDetailIndependenceState alloc] init];
        self.middleware = [[TTMomentDetailMiddleware alloc] init];
        self.middleware.store = self;
    }
    return self;
}

-(void)setEnterFrom:(NSString *)enterFrom {
    
    _enterFrom = enterFrom;
    if ([self.middleware isKindOfClass:[TTMomentDetailMiddleware class]]) {
        
        TTMomentDetailMiddleware *middleware = (TTMomentDetailMiddleware *)self.middleware;
        middleware.enterFrom = enterFrom;
        
    }
}

-(void)setCategoryID:(NSString *)categoryID {
    
    _categoryID = categoryID;
    if ([self.middleware isKindOfClass:[TTMomentDetailMiddleware class]]) {
        
        TTMomentDetailMiddleware *middleware = (TTMomentDetailMiddleware *)self.middleware;
        middleware.categoryID = categoryID;
    }

}

-(void)setLogPb:(NSDictionary *)logPb {
    
    _logPb = logPb;
    if ([self.middleware isKindOfClass:[TTMomentDetailMiddleware class]]) {
        
        TTMomentDetailMiddleware *middleware = (TTMomentDetailMiddleware *)self.middleware;
        middleware.logPb = logPb;
    }

}

- (void)dispatch:(Action *)action {
    if (action.shouldMiddlewareHandle) {
        action.shouldMiddlewareHandle = NO;
        [self.middleware handleAction:action];
        return;
    }
    [super dispatch:action];
}

@end
