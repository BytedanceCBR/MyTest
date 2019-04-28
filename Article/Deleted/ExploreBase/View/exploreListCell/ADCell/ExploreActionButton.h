//
//  ExploreDownloadButton.h
//  Article
//
//  Created by SunJiangting on 14-9-19.
//
//

#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData.h"
#import "SSADEventTracker.h"
#import "TTAdFeedDefine.h"
#import "TTAlphaThemedButton.h"
#import "TTTouchContext.h"

@interface ExploreActionButton : TTAlphaThemedButton

@property (nonatomic, strong) id<TTAdFeedModel> adModel;
@property (nonatomic, strong) ExploreOrderedData *actionModel;
@property (nonatomic, strong) TTTouchContext *lastTouchContext;

- (void)setIconImageNamed:(NSString *)imageName;
- (void)actionButtonClicked:(id)sender showAlert:(BOOL)showAlert;

- (void)actionButtonClicked:(id)sender context:(NSDictionary *)context;

- (void)refreshCreativeIcon;
- (void)refreshForceCreativeIcon;

@end
