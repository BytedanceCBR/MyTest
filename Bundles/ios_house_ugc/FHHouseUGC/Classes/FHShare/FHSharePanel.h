//
//  FHSharePanel.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import <BDUGActivityPanelControllerProtocol.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHSharePanel : NSObject <BDUGActivityPanelControllerProtocol>

@property (nonatomic, weak, nullable) id<BDUGActivityPanelDelegate> delegate;

@end


NS_ASSUME_NONNULL_END
