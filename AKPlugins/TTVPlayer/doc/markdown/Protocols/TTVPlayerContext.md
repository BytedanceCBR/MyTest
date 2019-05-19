# TTVPlayerContext Protocol Reference

&nbsp;&nbsp;**Conforms to** NSObject  
&nbsp;&nbsp;**Declared in** TTVPlayerContext.h  

## Tasks

### 

[&nbsp;&nbsp;playerStore](#//api/name/playerStore) *property* 

[&ndash;&nbsp;viewDidLoad:](#//api/name/viewDidLoad:)  

[&ndash;&nbsp;viewDidLayoutSubviews:](#//api/name/viewDidLayoutSubviews:)  

## Properties

<a name="//api/name/playerStore" title="playerStore"></a>
### playerStore

每个注册的实例都可以拿到 store, readonly 不可以了??
@required

`@property (nonatomic, weak) TTVReduxStore *playerStore`

#### Discussion
每个注册的实例都可以拿到 store, readonly 不可以了??
@required

#### Declared In
* `TTVPlayerContext.h`

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/viewDidLayoutSubviews:" title="viewDidLayoutSubviews:"></a>
### viewDidLayoutSubviews:

需要在此方法layout view

`- (void)viewDidLayoutSubviews:(TTVPlayer *)*playerVC*`

#### Parameters

*playerVC*  
&nbsp;&nbsp;&nbsp;playerVC 可以获取所有的 view，以及 part  

#### Discussion
需要在此方法layout view

#### Declared In
* `TTVPlayerContext.h`

<a name="//api/name/viewDidLoad:" title="viewDidLoad:"></a>
### viewDidLoad:

需要在此方法添加 view

`- (void)viewDidLoad:(TTVPlayer *)*playerVC*`

#### Parameters

*playerVC*  
&nbsp;&nbsp;&nbsp;playerVC 可以获取所有的 view，以及 part  

#### Discussion
需要在此方法添加 view

#### Declared In
* `TTVPlayerContext.h`

