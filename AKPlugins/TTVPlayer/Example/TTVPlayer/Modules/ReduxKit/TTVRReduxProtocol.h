
#ifndef ReduxHeader_h
#define ReduxHeader_h

@protocol TTVRActionProtocol,TTVRStateProtocol,TTVRReducerProtocol;

typedef void(^TTVSubscription)(id <TTVRActionProtocol> action,id<TTVRStateProtocol>state);

@protocol TTVRStoreProtocol<NSObject>

@property (nonatomic,strong) id<TTVRStateProtocol> state;

- (void)dispatch:(id<TTVRActionProtocol>)action;

- (NSString *)subscribe:(TTVSubscription)TTVSubscription;

- (void)unSubscribe:(NSString *)key;

- (void)executeAllSubscribeWithAction:(id<TTVRActionProtocol>)action state:(id<TTVRStateProtocol>)state;

@end

@protocol TTVRReducerProtocol<NSObject>

- (void)executeWithAction:(id<TTVRActionProtocol>)action state:(id<TTVRStateProtocol>)state finishBlock:(void (^)(id <TTVRStateProtocol> state))finishBlock;

@end

@protocol TTVRActionProtocol<NSObject>

@property (nonatomic ,copy) NSString *type;

@property (nonatomic ,strong) NSDictionary *info;

@end

@protocol TTVRStateProtocol<NSObject>

@end


#endif /* ReduxHeader_h */
