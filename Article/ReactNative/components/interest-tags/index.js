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
    NativeAppEventEmitter,
    ScrollView
} from 'react-native';
import StyleBuilder from '../style-builder';
import StyleVariables from '../style-variables';
import FontSwitcher from '../font-switcher';
import Button from '../button';

class InterestTags extends Component {
    constructor (props) {
        super(props);
        this.bindEvents();
        try {
            this.isiPad = NativeModules.bridge.deviceModel.toLowerCase().indexOf('ipad') > -1;
        } catch (err) {
            this.isiPad = false;
        }
        this.state = {
            daymode: props.daymode,
            font: props.font,
            chosen: [],
            currentPage: 1,
            data: props.interest_list,
        };
    }

    componentWillReceiveProps (nextProps) {
        this.setState({
            daymode: nextProps.daymode,
            font: nextProps.font
        });
    }

    componentDidMount () {
        NativeModules.bridge.log({
            tag: 'interest_guide',
            label: 'display',
        });
        // this.fetch();
    }

    fetch () {
        fetch('http://ib.snssdk.com/stream/widget/interest/1/conf_words?from=feed')
            .then((response) => response.json())
            .then((responseData) => {
                if (responseData.message === 'success' && typeof responseData.data === 'object' && Array.isArray(responseData.data.words)) {
                    console.log('data length', responseData.data.words.length);
                    this.setState({
                        data: responseData.data.words,
                        chosen: [],
                    });
                }
            })
            .catch((error) => {
                console.error('fetch error');
            })
            .done(() => {
                console.log('fetch done');
            });
    }

    componentWillUnmount () {
        this.removeEvents();
    }

    onButtonClicked () {
        console.log('button clicked');
        if (this.state.chosen.length === 0) {
            NativeModules.bridge.toast({
                text: '请选择兴趣'
            });
        } else {
            NativeModules.bridge.log({
                tag: 'interest_guide',
                label: 'confirm_click',
            });

            NativeModules.bridge.refreshFeedList();
        }
    }

    onCloseClicked () {
        NativeModules.bridge.log({
            tag: 'interest_guide',
            label: 'dislike_menu'
        });
        setTimeout(() => {
            this.refs.closeButton.measure((fx, fy, width, height, px, py) => {
                NativeModules.bridge.showDislike({
                    x: fx + width / 2,
                    y: fy + height / 2
                }, () => {
                    NativeModules.bridge.log({
                        tag: 'interest_guide',
                        label: 'close'
                    });
                });
            })
        }, 0);
    }

    onTagClicked (targetIndex) {
        let _chosen = this.state.chosen;
        let _pos = _chosen.indexOf(targetIndex);
        let _word = this.state.data[targetIndex];
        let willChose = _pos === -1;

        if (willChose) {
            _chosen.push(targetIndex);
        } else {
            _chosen.splice(_pos, 1);
        }

        this.trace.push({
            status: willChose ? 1 : 0,
            timestamp: parseInt(Date.now() / 100),
            word_id: _word.word_id,
            name: _word.name,
            extra: _word.extra
        });

        NativeModules.bridge.syncFeedInterestWords({
            interest: this.trace
        });

        NativeModules.bridge.log({
            tag: 'interest_guide',
            label: willChose ? 'word_select' : 'word_deselect',
            value: willChose ? this.pressCount++ : this.cancelCount++,
            word: _word.name
        });

        this.setState({
            chosen: _chosen
        });
    }

    onMomentumScrollEnd (event) {
        // 惯性滚动结束后处理indicator
        // 要知道上一页是多少来发送统计参数
        let newPage = event.nativeEvent.contentOffset.x / event.nativeEvent.layoutMeasurement.width + 1;

        if (this.state.currentPage !== newPage) {
            NativeModules.bridge.log({
                tag: 'interest_guide',
                label: 'slide',
                value: newPage
            });

            this.setState({
                currentPage: newPage
            });
        }
    }

    bindEvents () {
        this.eventListeners = {};

        this.trace = [];
        this.pressCount = 1;
        this.cancelCount = 1;
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
        let plusicon = this.state.daymode === 'day'
                            ? require('./images/day/toast_keywords_add.png')
                            : require('./images/night/toast_keywords_add.png');
        let crossicon = this.state.daymode === 'day'
                            ? require('./images/day/toast_keywords_option.png')
                            : require('./images/night/toast_keywords_option.png');
        const props = this.props;

        let buildIndicators = () => {
            let shouldHavePages = Math.ceil(this.state.data.length / 9);
            let _inds = [];
            for (let i = 1; i <= shouldHavePages; i++) {
                _inds.push(
                    <View key={i} style={[s.indicator, i === this.state.currentPage ? s.indicatoractive : {}]}></View>
                )
            }
            return _inds;
        }

        let buildTags = (ofPages, ofLines) => {
            let _tags = [];
            let _fromIndex = (ofPages - 1) * 9 + (ofLines - 1) * 3;

            for (let i = 0; i < 3; i++) {
                let _item = this.state.data[_fromIndex + i];
                if (typeof _item === 'object') {
                    let isItemChosen = this.state.chosen.indexOf(_fromIndex + i) > -1;
                    _tags.push(
                        <TouchableOpacity key={_fromIndex + i} style={[s.tag, i === 1 ? {marginLeft: 8, marginRight: 8} : {}, isItemChosen ? s.tagactive : {}]} onPress={this.onTagClicked.bind(this, _fromIndex+i)}>
                            <Text style={[s.tagcontent, isItemChosen ? s.tagcontentactive : {}]} numberOfLines={1}>{_item.name}</Text>
                            <Image source={isItemChosen ? crossicon : plusicon} />
                        </TouchableOpacity>
                    )
                }
            }

            return _tags;
        }

        let buildLines = (ofPages) => {
            let shouldHaveTags = this.state.data.length > ofPages * 9 ? 9 : this.state.data.length - (ofPages - 1) * 9;
            let shouldHaveLines = Math.ceil(shouldHaveTags / 3);

            // console.log('shouldHaveTags', shouldHaveTags, 'shouldHaveLines', shouldHaveLines);

            let _lines = [];
            for (let i = 1; i <= shouldHaveLines; i++) {
                _lines.push(
                    <View key={i} style={[s.oneline, {marginBottom: i === 3 ? 0 : 16}]}>
                        {buildTags(ofPages, i)}
                    </View>
                )
            }
            return _lines;
        }

        let buildPages = () => {
            let shouldHavePages = Math.ceil(this.state.data.length / 9);
            let _pages = [];

            // console.log('shouldHavePages', shouldHavePages);

            for (let i = 1; i <= shouldHavePages; i++) {
                _pages.push(
                    <View key={i} style={s.onepage}>
                        {buildLines(i)}
                    </View>
                )
            }
            return _pages;
        }

        return (
            <View style={s.container}>
                <View style={s.honeout}><Text style={s.hone}>{this.state.chosen.length === 0 ? '选择我想看的' : ('已选择' + this.state.chosen.length + '个兴趣')}</Text></View>
                <TouchableOpacity style={s.close} ref="closeButton" onPress={this.onCloseClicked.bind(this)}>
                    <View>
                        <Image source={closeicon} />
                    </View>
                </TouchableOpacity>
                <View style={s.indicators}>
                    {buildIndicators()}
                </View>
                <ScrollView
                    ref={(scrollView) => { this.scrollViewInstance = scrollView;}}
                    automaticallyAdjustContentInsets={false}
                    horizontal={true}
                    pagingEnabled={true}
                    showsHorizontalScrollIndicator={false}
                    scrollsToTop={false}
                    scrollEventThrottle={200}
                    onMomentumScrollEnd={this.onMomentumScrollEnd.bind(this)}
                    style={s.scrollwrap}>
                    {buildPages()}
                </ScrollView>
                <View style={s.bottoms}>
                    <Button containerStyle={[s.button, this.state.chosen.length > 0 ? s.buttonactive : {}]}
                            onPress={this.onButtonClicked.bind(this)}>
                        <Text style={[s.buttontext, this.state.chosen.length > 0 ? s.buttontextactive : {}]} numberOfLines={1}>给我推荐</Text>
                    </Button>
                </View>
            </View>
        );
    }
}
var styles = StyleBuilder({
    container: {
        alignItems: 'center',
        overflow: 'hidden',
        paddingBottom: 24,
        paddingTop: 22,
        backgroundColor: 'StyleVariables.plane4',
    },
    honeout: {
        alignItems: 'center',
        height: 16,
    },
        hone: {
            fontSize: 16,
            lineHeight: 16,
            fontWeight: '500',
            color: 'StyleVariables.word1',
        },
    close: {
        justifyContent: 'center',
        alignItems: 'center',
        position: 'absolute',
        top: 0,
        right: 0, // ?
        width: 50,
        height: 60,
    },
    indicators: {
        marginTop: 8,
        marginBottom: 20,
        height: 4,
        alignItems: 'center',
        flexDirection: 'row',
    },
        indicator: {
            width: 4,
            height: 4,
            borderRadius: 4,
            backgroundColor: 'StyleVariables.plane2',
            marginLeft: 3,
            marginRight: 3
        },
        indicatoractive: {
            backgroundColor: 'StyleVariables.plane7'
        },
    scrollwrap: {
        height: 140,
    },
        onepage: {
            alignItems: 'center',
            width: Dimensions.get('window').width,
            paddingLeft: 18,
            paddingRight: 18,
        },
            oneline: {
                width: Dimensions.get('window').width - 36,
                height: 36,
                flexDirection: 'row',
            },
                tag: {
                    flex: 1,
                    flexDirection: 'row',
                    backgroundColor: 'StyleVariables.plane4',
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderRadius: 36,
                    borderWidth: 1/PixelRatio.get(),
                    borderColor: 'StyleVariables.#f0f0f0,#303030',
                    overflow: 'hidden',
                },
                tagactive: {
                    backgroundColor: 'StyleVariables.plane7',
                },
                    tagcontent: {
                        maxWidth: (Dimensions.get('window').width - 36 - 16) / 3 - 16 - 16,
                        fontSize: 14,
                        color: 'StyleVariables.word1',
                    },
                    tagcontentactive: {
                        fontSize: 14,
                        color: 'StyleVariables.word7',
                    },
    bottoms: {
        alignItems: 'center',
        marginTop: 20,
    },
        button: {
            width: 72,
            height: 24,
            borderWidth: 1,
            borderColor: 'StyleVariables.#979fac,#707070',
            borderRadius: 6,
            justifyContent: 'center',
            alignItems: 'center',
        },
        buttonactive: {
            borderColor: 'StyleVariables.line2',
        },
            buttontext: {
                fontSize: 12,
                color: 'StyleVariables.word13',
            },
            buttontextactive: {
                color: 'StyleVariables.word4',
            }
});

export default InterestTags;
