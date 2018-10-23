import React, { Component } from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    View,
    Image,
    TouchableOpacity,
    TouchableHighlight,
    Animated,
    Dimensions,
    NativeAppEventEmitter
} from 'react-native';
import Weather from './components/weather';
import Finance from './components/finance';
import InterestTags from './components/interest-tags';

var RCTLog = require('RCTLog'); // FIXME 尝试改为import语法

class RNCellView extends Component {
    constructor (props) {
        super(props);
        this.state = {
            daymode: this.props.daymode,
            font: this.props.font,
        };
        this.listenEvents();
    }

    changeDaymode (daymode) {
        if (typeof daymode === 'string' && ['day', 'night'].indexOf(daymode.toLowerCase()) > -1) {
            this.setState({
                daymode
            });
        }
    }

    changeFont (font) {
        if (typeof font === 'string' && ['s', 'm', 'l', 'xl'].indexOf(font.toLowerCase()) > -1) {
            this.setState({
                font
            });
        }
    }

    componentWillReceiveProps (nextProps) {
        this.changeDaymode(nextProps.daymode);
        this.changeFont(nextProps.font);
    }

    listenEvents () {
        this.eventListeners = {};
        // TODO 应当把子模块的事件监听移到此处
    }

    removeEvents () {
        for (let k in this.eventListeners) {
            this.eventListeners[k].remove();
        }
        this.eventListeners = {};
    }

    componentWillUnmount () {
        this.removeEvents();
    }

    render() {
        switch (this.props.module) {
            case 'weather':
                return (
                    <Weather {...this.props} {...this.state} />
                );
                break;
            case 'finance':
                return (
                    <Finance {...this.props} {...this.state} />
                );
                break;
            case 'interest_guide':
                return (
                    <InterestTags {...this.props} {...this.state} />
                );
                break;
            default:
                return (
                    <View {...this.props} {...this.state}></View>
                );
                break;
        }
    }
}

AppRegistry.registerComponent('RNCellView', () => RNCellView);
