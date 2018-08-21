import React, { Component, PropTypes } from 'react';
import {
    StyleSheet,
    Text,
    View,
    Image,
    TouchableOpacity,
    TouchableHighlight,
    NativeModules,
    PixelRatio,
    Dimensions,
    NativeMethodsMixin,
    NativeAppEventEmitter
} from 'react-native';
import StyleBuilder from '../style-builder';
import StyleVariables from '../style-variables';
import FontSwitcher from '../font-switcher';
import Button from '../button';

const iconsize = {
    true: {
        width: 51,
        height: 42
    },
    false: {
        width: 75,
        height: 49
    }
};

class Weather extends Component {
    constructor (props) {
        super(props);
        this.bindEvents();
        try {
            this.isiPad = NativeModules.birdge.deviceModel.toLowerCase().indexOf('ipad') > -1;
        } catch (err) {
            this.isiPad = false;
        }
        this.state = {
            daymode: props.daymode,
            willShowButton: (props.sub_type == 0 && !!props.islogin) ? false : !!props.button,
            needflex: false,
            settedflex: false,
            font: props.font,
            uniqueIDChanged: false
        };
    }

    componentDidMount () {
        NativeModules.TTRNBridge.log({
            tag: 'flexible_cell',
            label: 'top_display',
            sub_type: this.props.sub_type
        });
        if (this.props.button) {
            NativeModules.TTRNBridge.log({
                tag: 'flexible_cell',
                label: 'action_display',
                sub_type: this.props.sub_type
            });
        }
    }

    componentWillReceiveProps (nextProps) {
        if (nextProps.sub_type === this.props.sub_type) {
            this.setState({
                daymode: nextProps.daymode,
                font: nextProps.font,
                uniqueIDChanged: nextProps.uniqueID !== this.props.uniqueID
            });
        } else {
            // 当subtype变化，意味着cell的类型发生了改变，此时应当重新“初始化”
            this.state = {
                daymode: nextProps.daymode,
                willShowButton: (nextProps.sub_type == 0 && !!nextProps.islogin) ? false : !!nextProps.button,
                needflex: false,
                settedflex: false,
                font: nextProps.font,
                uniqueIDChanged: nextProps.uniqueID !== this.props.uniqueID
            };
        }
    }

    componentWillUnmount () {
        this.removeEvents();
    }

    onPanelClicked () {
        NativeModules.TTRNBridge.log({
            tag: 'flexible_cell',
            label: 'top_click',
            sub_type: this.props.sub_type
        });
        NativeModules.TTRNBridge.open(this.props.url);
    }

    onButtonClicked () {
        NativeModules.TTRNBridge.log({
            tag: 'flexible_cell',
            label: 'action_click',
            sub_type: this.props.sub_type
        });
        if (this.props.sub_type === 0) {
            NativeModules.TTRNBridge.login({
                login_source: 'flexible_cell'
            }, ()=>{});
        } else {
            NativeModules.TTRNBridge.open(this.props.button.action);
        }
    }

    onCloseClicked () {
        NativeModules.TTRNBridge.log({
            tag: 'flexible_cell',
            label: this.props.button ? 'both_dislike_click' : 'top_dislike_click',
            sub_type: this.props.sub_type
        });
        setTimeout(() => {
            this.refs.closeButton.measure((fx, fy, width, height, px, py) => {
                NativeModules.TTRNBridge.showDislike({
                    x: fx + width / 2,
                    y: fy + height / 2
                }, () => {
                    NativeModules.TTRNBridge.log({
                        tag: 'flexible_cell',
                        label: this.props.button ? 'both_disincline_click' : 'top_disincline_click',
                        sub_type: this.props.sub_type
                    });
                });
            })
        }, 0);
    }

    onTitlesLayout () {
        this.refs.titles.measure((fx, fy, width, height, px, py) => {
            var space = Dimensions.get('window').width - 15/*padding*/*2 - fx;
            if (!this.state.settedflex) {
                this.setState({
                    needflex: this.isiPad || space <= width,
                    settedflex: true
                });
            }
        });
    }

    bindEvents () {
        this.eventListeners = {};
        this.eventListeners.accountChanged = NativeAppEventEmitter.addListener('accountChanged', ({state}) => {
            if (this.props.button_hide_type == 1) {
                NativeModules.TTRNBridge.panelClose();
            }
            this.setState({
                willShowButton: (this.props.sub_type == 0 && state === 'login') ? false : this.state.willShowButton,
            });
        });
        this.eventListeners.addressbookSynced = NativeAppEventEmitter.addListener('addressbookSynced', ({state}) => {
            if (this.props.button_hide_type == 0) {
                this.setState({
                    button: null
                });
            } else if (this.props.button_hide_type == 1) {
                NativeModules.TTRNBridge.panelClose();
            }
        });
    }

    removeEvents () {
        for (let k in this.eventListeners) {
            this.eventListeners[k].remove();
        }
    }

    render() {
        let s = styles[this.state.daymode];
        let closeicon = this.state.daymode === 'day'
                            ? require('./images/day/dislikeicon_textpage.png')
                            : require('./images/night/dislikeicon_textpage.png');
        let uc = this.state.daymode === 'day'
                     ? StyleVariables.plane4.dayActive
                     : StyleVariables.plane4.nightActive;
        const props = this.props;
        let fIconnote = () => {
            if (props.iconnote) {
                return (
                    <Text style={s.subtitle}>{props.iconnote}</Text>
                );
            } else {
                return null;
            }
        };
        let fBottoms = () => {
            if (this.state.willShowButton) {
                return (
                    <View style={s.bottoms}>
                        <Button containerStyle={s.button}
                                onPress={this.onButtonClicked.bind(this)}>
                            <Text style={s.buttontext} numberOfLines={1}>{props.button.text}</Text>
                        </Button>
                    </View>
                )
            } else {
                return null;
            }
        }
        return (
            <TouchableHighlight onPress={this.onPanelClicked.bind(this)} underlayColor={uc}>
                <View style={[s.container, {paddingTop: this.props.iconnote ? 7: 15}]}>
                    <View style={s.content}>
                        <View style={s.tops}>
                            <View style={s.topsLefts}>
                                <Image source={{uri: props.icon.source}}
                                       style={[iconsize[!!props.iconnote], {opacity: this.state.daymode === 'day' ? 1 : 0.5}]}/>
                                {fIconnote()}
                            </View>
                            <View style={[s.topsRights, {flex: this.state.needflex ? 1 : 0}]} ref="titles" onLayout={this.onTitlesLayout.bind(this)}>
                                <Text style={[s.title, {
                                    fontSize: FontSwitcher(19, this.state.font),
                                    lineHeight: FontSwitcher(23, this.state.font)
                                }]} numberOfLines={1}>{props.title}</Text>
                                <Text style={[s.subtitle, {
                                    paddingRight: this.state.willShowButton ? 0 : 20
                                }]} numberOfLines={1}>{props.subtitle}</Text>
                            </View>
                        </View>
                        {fBottoms()}
                    </View>
                    <TouchableOpacity onPress={this.onCloseClicked.bind(this)} ref="closeButton" style={s.close}>
                        <View style={{marginLeft: -3}}>
                            <Image source={closeicon} />
                        </View>
                    </TouchableOpacity>
                </View>
            </TouchableHighlight>
        );
    }
}
var styles = StyleBuilder({
    container: {
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'space-between',
        overflow: 'hidden',
        paddingRight: 15,
        paddingBottom: 15,
        paddingLeft: 15,
        backgroundColor: 'StyleVariables.plane4',
    },
    content: {
        flex: 1,
    },
        tops: {
            flexDirection: 'row',
            justifyContent: 'center',
            overflow: 'hidden',
        },
            topsLefts: {
                marginRight: 11,
                alignItems: 'center',
                justifyContent: 'flex-end',
            },
            topsRights: {
                justifyContent: 'flex-end',
            },
                title: {
                    color: 'StyleVariables.word1'
                },
                subtitle: {
                    color: 'StyleVariables.word3',
                    fontSize: 12,
                    lineHeight: 16,
                    marginTop: 6,
                },
        bottoms: {
            alignItems: 'center',
            marginTop: 12,
        },
            button: {
                height: 28,
                paddingLeft: 5,
                paddingRight: 5,
                borderWidth: 1,
                borderColor: 'StyleVariables.line3',
                borderRadius: 6,
                justifyContent: 'center',
            },
                buttontext: {
                    fontSize: 12,
                    color: 'StyleVariables.word6',
                },
    close: {
        justifyContent: 'center',
        alignItems: 'center',
        position: 'absolute',
        bottom: 0,
        right: 0,
        width: 44,
        height: 44,
        paddingTop: 2,
    },
});

export default Weather;
