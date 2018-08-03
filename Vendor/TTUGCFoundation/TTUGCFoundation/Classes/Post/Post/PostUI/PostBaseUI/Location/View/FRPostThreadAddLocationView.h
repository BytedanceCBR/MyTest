//
//  FRPostThreadAddLocationView.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/15.
//
//

#import "SSThemed.h"
#import "FRLocationEntity.h"
#import "FRForumEntity.h"

@protocol FRPostThreadAddLocationViewDelegate <NSObject>

@optional

- (void)addLocationViewWillPresent;
- (void)addLocationViewDidDismiss;

@end

@interface FRPostThreadAddLocationView : SSThemedView

@property (nonatomic, strong, nonnull) SSThemedButton *button;
@property (nonatomic, strong, nullable) FRLocationEntity *selectedLocation;
@property (nonatomic, strong, nullable) NSString *concernId;
@property (nonatomic, copy, nullable) NSDictionary *trackDic;
@property (nonatomic, weak) id <FRPostThreadAddLocationViewDelegate> delegate;

- (nonnull instancetype)initWithFrame:(CGRect)frame andShowEtStatus:(FRShowEtStatus)showEtStatus NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithCoder:(NSCoder *_Nonnull)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)buttonClicked:(UIButton *_Nullable)sender;
- (void)refresh;
@end
