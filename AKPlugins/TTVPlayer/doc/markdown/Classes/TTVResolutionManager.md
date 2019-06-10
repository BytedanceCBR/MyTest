# TTVResolutionManager Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** <a href="../Protocols/TTVPlayerContext.html">TTVPlayerContext</a>  
&nbsp;&nbsp;**Declared in** TTVResolutionManager.h<br />  
TTVResolutionManager.m  

## Tasks

### 

[&ndash;&nbsp;createResolutionButton](#//api/name/createResolutionButton)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/createResolutionButton" title="createResolutionButton"></a>
### createResolutionButton

/        [self.store.player configResolution:[TTVideoResolutionService defaultResolutionType] completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
/
/        }];

`- (UIButton *)createResolutionButton`

#### Discussion
/        [self.store.player configResolution:[TTVideoResolutionService defaultResolutionType] completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
/
/        }];

#### Declared In
* `TTVResolutionManager.m`

