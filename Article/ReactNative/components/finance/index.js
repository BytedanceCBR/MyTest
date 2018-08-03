import React, { Component, PropTypes } from 'react';
import {
    StyleSheet,
    Text,
    View,
    Image,
    TouchableOpacity,
    TouchableHighlight,
    PixelRatio
} from 'react-native';
import StyleVariables from '../style-variables';

const fakeListData = [
    {
        index: 2988.09,
        code: "000001",
        name: "上证指数",
        rate: "-0.95%",
        market: "sh",
        change: -28.75
    },
    {
        index: 10611.8,
        code: "399001",
        name: "深证成指",
        rate: "-0.08%",
        market: "sz",
        change: -8.78
    },
    {
        index: 2239,
        code: "399006",
        name: "创业板指",
        rate: "+0.23%",
        market: "sz",
        change: 5.08
    }
];

const COLOR_DAY = {
    rise: {
        color: '#fc5d5d'
    },
    even: {
        color: '#999999'
    },
    fall: {
        color: '#41be70'
    }
};
const COLOR_NIGHT = {
    rise: {
        color: '#935656'
    },
    even: {
        color: '#707070'
    },
    fall: {
        color: '#397d52'
    }
};
const COLOR_ALL = {
    day: COLOR_DAY,
    night: COLOR_NIGHT
};
var COLOR;

const ICONS_DAY = {
    rise: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABoAAAAlCAMAAABruAmEAAAAUVBMVEUAAADsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFLsXFJaqts/AAAAGnRSTlMAw0vWGexxAjGe7qF4LxW0dvjhzIxbVk1BB5/Bo58AAAB2SURBVCjP7dBJDoAgEETRxlmcZ+37H1RSASEiiQfg77rersmtmJaMPmuZOc0CErARAvMlYIXa8lntME86wXzUsLeQoqR8zBUQGbNSkSZtvSOGlDXaEi2GjAk8QUIswSRRPwjIQ7A13Qi9CUWK9JfOAO1yuOx1A0yuEISBCjjWAAAAAElFTkSuQmCC',
    fall: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABoAAAAlCAMAAABruAmEAAAATlBMVEUAAABBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnBBvnDzitcbAAAAGXRSTlMAw0vw0RU2bGmnu6nZQxPizL+TeGFVThkHG4LtqwAAAHJJREFUKM/tyUkOg0AQQ9EinRBo5hnf/6K0SjJTgcQB+BtLfrJvcH6W6xqguKEI+Lz00hOafB1bavNepANcfKYsnCIF1EgU+LCJGonyLWW1jVLKaiSVn8JmShT2Vws0Uk5WATnlYIxijGKMYo1iS1y0kwUVTQ+ndGtVdwAAAABJRU5ErkJggg==',
    error_update: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAUNJREFUeNqslLFLQlEUxn2iBIH4F7gJOdYi4qK8cHYJF6cagpb+lrZoarHNpdUWIwJxlwKHgqS5EAcjtO/C9+B0Oef2gnfgB5f7zvdxz3n3nuij389lGfnAtxhcgTlYkzn3Di1RQdmrgUvQVr5VySkYgzPwHDphC0wNMz/azG1Zhu5kt6CkiF/Bi7JfoqbmG0bgGpQV0TfYBwdc+1GmNpKGrskNo7QV+CQrI6eR/KjEsJfBjelJwzgDw1gaVjIwrEjDdSCxyIZHXAcjudjvYM/I2QUXYm3FQhpOA4YuzlOU/ChLvknxKv56PQNpOAITI3HDchZca+G0d9JwC455ebWJNCPadHKaE3r8SnBTowuWimiH+LGk5smaNvegHijfL7NOTXAeupM2QQcc8Y26S/sF3sADGLJn2zQDNunpiPwrfgQYANCZQMm8pHd9AAAAAElFTkSuQmCC',
    link: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAkBAMAAABh4ecdAAAAJFBMVEUAAAAiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIyrc4vAAAAC3RSTlMABquksfedlvGMgstePz8AAABDSURBVBjTY6AC4AwTQHBYdysiOGy7NyGkGLWRpYRoLZWALBWA4IggcRi9dxcgSWxGljCghQQzSAIRVAYIDlc7A7UAAPUmIAAV6avxAAAAAElFTkSuQmCC',
    even: '',
}
const ICONS_NIGHT = {
    rise: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABoAAAAlCAMAAABruAmEAAAAUVBMVEUAAACTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlaTVlbn9qQUAAAAGnRSTlMAw0vWcTECGRXu7J52obT44cmMeFtWTUEvBxwXOZ0AAAB1SURBVCjP7clZDoNADINhD9DCdKErW+5/UAKJZMSAxAH43+wPy4rXp8RmDxHJyz2hpUJLJbVCv9tbf9pS+iDS3ierVnKBUnalgTITaBQnmklUcVJ7umUmJLcA/ExIbhGo6qBCMvvmfzCSddJJR6nboSbWA9cIZOYQhEQTLyAAAAAASUVORK5CYII=',
    fall: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABoAAAAlCAMAAABruAmEAAAAQlBMVEUAAAA5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVI5fVJYsE5nAAAAFXRSTlMAw0vw0BQ2qGxqvNlB4r+TeG5hVRlO00h3AAAAa0lEQVQoz+3SSQqAMBQE0a9xnqe+/1XFQNvBEPAAqe3bloWdbrBECzAlqADKTJn+0DVUTUzreJhtgGu+1ALObII3EgXPrb03EqWq7TWSREaSyDxR3jpvD1E+NgOjJDAmkUlio8TtkqjeFYHca6QNN3GG0G4AAAAASUVORK5CYII=',
    error_update: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAUJJREFUeNqslDFLA0EQhT2JCELIL0gnmFKbENIknFinkeu1CNjktwgWkipN7NLYxiZBBEkfFFIoGOxDSBEJxrfwDsZlZj3hBj5Y9uY9duZ2J7pJkp08YzfwLQZdMANrMuPeqSUqKHsVcAuayrdD0gYjcAVeQydsgIlh5keTuQ3L0J3sHhQV8Tt4U/aL1FR8wwj0QEkRbcAxOOHajxK1kTR0Ta4Zpa3AgqyMnFr6o1LDPO5OIg3jHAxjaVjOwbAsDdeBxD02POI6GOnF/gRHRs4BuBZrK+bScBIwdNHJUPKTLPkuw6v46/X0peEQPBuJ3yxnzrUWTvsgDbfggpdXm0hTok0np7mkx68ENzVaYKmI9okfS2perGkzBtVA+X6ZVWqC89CdtA7OwDnfqLu0X+ADPIIBe7bNMmDTng7Jv+JHgAEARSVAYpAKJHUAAAAASUVORK5CYII=',
    link: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAkBAMAAABh4ecdAAAAJFBMVEUAAABwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHCwQjU1AAAAC3RSTlMABquksfedlvGMgstePz8AAABDSURBVBjTY6AC4AwTQHBYdysiOGy7NyGkGLWRpYRoLZWALBWA4IggcRi9dxcgSWxGljCghQQzSAIRVAYIDlc7A7UAAPUmIAAV6avxAAAAAElFTkSuQmCC',
    even: '',
}
const ICONS_ALL = {
    day: ICONS_DAY,
    night: ICONS_NIGHT
}
var ICONS;

var s;

class Index extends Component {
    render () {
        let index = this.props.index;
        let status = index.change > 0 ? 'rise' : index.change < 0 ? 'fall' : 'even';
        return (
            <View style={[s.listCell, {
                borderRightWidth: this.props.nj == 2 ? 1/PixelRatio.get() : 0,
                borderLeftWidth: this.props.nj == 2 ? 1/PixelRatio.get() : 0,
            }]}>
                <View style={s.listCellInner}>
                    <View>
                        <Text style={s.indexName}>
                            {index.name}
                        </Text>
                    </View>
                    <View style={s.indexouter}>
                        <Text style={[s.indexPrice, COLOR[status]]}>
                            {index.index.toFixed(2)}
                        </Text>
                        <Image source={{uri: ICONS[status]}}
                               style={{width: 8, height: 12, marginTop: 7, marginLeft: 6}} />
                    </View>
                    <View>
                        <Text style={[s.indexInfo, COLOR[status]]}>
                            {(index.change > 0 ? '+' : '') + index.change}
                            {'  '}
                            {index.rate}
                        </Text>
                    </View>
                </View>
            </View>
        );
    }
}

class Finance extends Component {
    constructor (props) {
        super(props)
        this.state = {
            daymode: props.daymode,
            loaded: false,
            dataSource: fakeListData,
            updateInfo: '最后更新于',//最后更新于2016-07-11 15:01
            updateTime: new Date()
        };
    }

    componentWillReceiveProps (nextProps) {
        this.setState({
            daymode: nextProps.daymode
        });
    }

    componentDidMount () {
        this.fetchData();
    }

    componentWillUnmount () {
        this.timer && clearTimeout(this.timer);
    }

    fetchData () {
        // 早9晚3间请求
        fetch('http://ic.snssdk.com/stock/get_quota/index/')
            .then((response) => response.json())
            .then((responseData) => {
                if (responseData.message === 'success') {
                    this.setState({
                        loaded: true,
                        updateInfo: '交易中，最后更新于',
                        dataSource: responseData.data.data,
                        updateTime: new Date()
                    });
                } else {
                    this.setState({
                        loaded: true,
                        updateInfo: '交易出错'
                    });
                }
            })
            .catch((error) => {
                this.setState({
                    loaded: true,
                    updateInfo: '交易出错'
                });
            })
            .done(() => {
                this.timer = setTimeout(this.fetchData.bind(this), 5000);
            });
    }

    onPanelClicked () {
        alert('onPanelClicked');
    }

    onLinkClicked () {
        alert('onLinkClicked');
    }

    render() {
        let uc = this.state.daymode === 'day'
                     ? StyleVariables.plane4.dayActive
                     : StyleVariables.plane4.nightActive;
        s = styles[this.state.daymode];
        ICONS = ICONS_ALL[this.state.daymode];
        COLOR = COLOR_ALL[this.state.daymode];
        const props = this.props;

        // if (!this.state.loaded) {
        //     return (
        //         <View style={[styles.container, {alignItems: 'center', justifyContent: 'center'}]}>
        //             <Text>Loading...</Text>
        //         </View>
        //     );
        // }

        return (
            <View style={s.container}>
                <TouchableHighlight onPress={this.onPanelClicked} underlayColor={uc}>
                    <View style={s.upwrapper}>
                        <View style={s.indexList}>
                            <Index index={this.state.dataSource[0]} nj="1" />
                            <Index index={this.state.dataSource[1]} nj="2" />
                            <Index index={this.state.dataSource[2]} nj="3" />
                        </View>
                        <View style={s.updatewordwrapper}>
                            <Text style={s.updateword}>
                                {this.state.updateInfo}
                                {this.state.updateTime.toLocaleDateString()}
                                {' '}
                                {this.state.updateTime.toLocaleTimeString()}
                            </Text>
                        </View>
                    </View>
                </TouchableHighlight>
                <TouchableHighlight onPress={this.onLinkClicked} underlayColor={uc}>
                    <View style={s.linkwordwrapper}>
                        <Text style={s.linkword}>
                            点击进入行情中心
                        </Text>
                        <Image source={{uri: ICONS['link']}}
                               style={{width: 8, height: 12, marginTop: 16, marginLeft: 6}} />
                    </View>
                </TouchableHighlight>
            </View>
        );
    }
}

var styles = {
    day: StyleSheet.create({
        container: {
            borderColor: StyleVariables.line1.day,
            borderTopWidth: 1/PixelRatio.get(),
            borderBottomWidth: 1/PixelRatio.get(),
            backgroundColor: StyleVariables.plane4.day,
        },
        upwrapper: {
            marginLeft: 15,
            marginRight: 15,
            borderBottomWidth: 1/PixelRatio.get(),
            borderColor: StyleVariables.line1.day,
        },
        indexList: {
            paddingTop: 16,
            paddingBottom: 10,
            flexDirection: 'row',
            marginLeft: -15,
            marginRight: -15,
        },
        listCell: {
            flex: 1,
            borderColor: StyleVariables.line1.day,
            justifyContent: 'center',
            alignItems: 'center',
        },
        listCellInner: {

        },
        indexName: {
            fontSize: 14,
            color: StyleVariables.word1.day,
        },

        indexouter: {
            flex: 1,
            marginTop: 2,
            flexDirection: 'row',
        },
        indexPrice: {
            fontSize: 19,
        },


        indexInfo: {
            fontSize: 11
        },


        updatewordwrapper: {
            marginBottom: 10,
        },
        updateword: {
            fontSize: 10,
            color: StyleVariables.word3.day,
        },

        linkwordwrapper: {
            height: 44,
            flexDirection: 'row',
        },
        linkword: {
            fontSize: 14,
            color: StyleVariables.word1.day,
            marginLeft: 15,
            marginTop: 15,
        }
    })
};

(() => {
    styles.night = {};
    for (let selector in styles.day) {
        styles.night[selector] = [styles.day[selector]];
    }
    styles.night.container.push({
        backgroundColor: StyleVariables.plane4.night,
        borderColor: StyleVariables.line1.night
    });
    styles.night.upwrapper.push({
        borderColor: StyleVariables.line1.night
    });
    styles.night.listCell.push({
        borderColor: StyleVariables.line1.night
    });
    styles.night.indexName.push({
        color: StyleVariables.word1.night
    });
    styles.night.updateword.push({
        color: StyleVariables.word3.night
    });
    styles.night.linkword.push({
        color: StyleVariables.word1.night
    });
})();

export default Finance;
