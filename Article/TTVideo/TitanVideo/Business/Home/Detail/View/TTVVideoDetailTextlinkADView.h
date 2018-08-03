//
//  TTVVideoDetailTextlinkADView.h
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import <TTThemed/SSThemed.h>
#import <TTVideoService/VideoInformation.pbobjc.h>

@protocol TTVVideoDetailTextlinkADViewDataProtocol <NSObject>

@property (nonatomic, strong) TTVAdminDebug *adminDebug;

@end

@interface TTVVideoDetailTextlinkADView : SSThemedView

@property (nonatomic, strong) id<TTVVideoDetailTextlinkADViewDataProtocol> viewModel;

@end
