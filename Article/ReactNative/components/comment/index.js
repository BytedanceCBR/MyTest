import React, { Component, PropTypes } from 'react';
import {
    StyleSheet,
    Text,
    View,
    Image,
    TouchableOpacity,
    TouchableHighlight
} from 'react-native';
import StyleVariables from '../style-variables';

class Reply extends Component {
    render () {
        return (
            <View>
                <TouchableOpacity>
                    <Text>掐你IE法律：</Text>
                </TouchableOpacity>
                <Text>他爸比他更适合做演员吧！小爽抗压能力不强</Text>
            </View>
        )
    }
}

class Comment extends Component {
    constructor (props) {
        super(props);
        this.state = {
            pressing: false,
        };
    }
    px () {
        alert(1);
        this.setState = {
            pressing: true,
        };
    }
    render () {
        return (
            <TouchableHighlight style={commentStyle.outerContainer}>
                <View style={commentStyle.innerContainer}>
                    <Image style={commentStyle.left}
                           source={{uri: 'https://facebook.github.io/react/img/logo_og.png'}} />
                    <View style={commentStyle.right}>
                        <View style={commentStyle.useranddigg}>
                            <TouchableOpacity>
                                <Text style={commentStyle.username}>ZLZ公司额</Text>
                            </TouchableOpacity>
                            <View style={commentStyle.diggouter}>
                                <Text style={commentStyle.diggword}>149赞</Text>
                            </View>
                        </View>
                        <Text style={commentStyle.comments}>
                            <Text>你问的是谁,你问的是你问的是谁？</Text>
                            <Text>&#47;&#47;</Text>
                            <Text style={{
                                color: this.state.pressing ? 'red' : 'yellow'
                            }} onPress={() => alert('1st')}>@宫崎骏</Text>
                            <Text>：</Text>
                            <Text>拿去“其实老爸只想和女儿多呆在一起”，好感空。期待他们的新作品</Text>
                        </Text>
                        <View style={commentStyle.bottominfo}>
                            <Text>2-28 12:45</Text>
                            <Text>&middot;</Text>
                            <TouchableOpacity><Text>5条回复</Text></TouchableOpacity>
                        </View>
                        <View style={commentStyle.replys}>
                            <TouchableOpacity>
                                <Text style={commentStyle.seemorereplys}>查看12条回复</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                </View>
            </TouchableHighlight>
        )
    }
}


var commentStyle = StyleSheet.create({
    outerContainer: {
        backgroundColor: 'white',
        marginTop: 28,
    },
    innerContainer: {
        marginLeft: 15,
        marginRight: 15,
        flexDirection: 'row',
    },
    left: {
        width: 36,
        height: 36,
        marginRight: 9,
        borderRadius: 18,
        borderWidth: 0.5,
        borderColor: '#e8e8e8',
    },
    right: {
        flex: 1,
    },
    useranddigg: {
        flex: 1,
        flexDirection: 'row',
    },
    username: {
        color: '#406599',
        fontSize: 16,
        marginTop: 6,
        marginBottom: 10,
    },
    diggouter: {
        alignSelf: 'flex-end',
    },
    diggword: {
        color: 'rgb(151, 159, 172)',
        fontSize: 15,
    },
    comments: {
        flexDirection: 'row',
        overflow: 'hidden',
        flexWrap: 'wrap',
        justifyContent: 'space-between',
        alignItems: 'flex-start',
    },
    quotename: {
        color: '#406599',
    },
    bottominfo: {
        flexDirection: 'row'
    },
    replys: {
        backgroundColor: '#e0e0e0',
        borderWidth: 0.5,
        borderColor: '#e8e8e8',
        marginTop: 12,
    },
    seemorereplys: {
        color: '#406599',
    }
});

export default Comment;
