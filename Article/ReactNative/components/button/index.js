import React, { Component, PropTypes } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity
} from 'react-native';

var systemButtonOpacity = 0.2;

function coalesceNonElementChildren(children, coalesceNodes) {
  var coalescedChildren = [];

  var contiguousNonElements = [];
  React.Children.forEach(children, (child) => {
    if (!React.isValidElement(child)) {
      contiguousNonElements.push(child);
      return;
    }

    if (contiguousNonElements.length) {
      coalescedChildren.push(
        coalesceNodes(contiguousNonElements, coalescedChildren.length)
      );
      contiguousNonElements = [];
    }

    coalescedChildren.push(child);
  });

  if (contiguousNonElements.length) {
    coalescedChildren.push(
      coalesceNodes(contiguousNonElements, coalescedChildren.length)
    );
  }

  return coalescedChildren;
}

export default React.createClass({
  propTypes: {
    ...TouchableOpacity.propTypes,
    containerStyle: View.propTypes.style,
    disabled: PropTypes.bool,
    style: Text.propTypes.style,
    styleDisabled: Text.propTypes.style,
  },

  render() {
    var touchableProps = {
      activeOpacity: this._computeActiveOpacity(),
    };
    if (!this.props.disabled) {
      touchableProps.onPress = this.props.onPress;
      touchableProps.onPressIn = this.props.onPressIn;
      touchableProps.onPressOut = this.props.onPressOut;
      touchableProps.onLongPress = this.props.onLongPress;
    }

    return (
      <TouchableOpacity {...touchableProps} style={this.props.containerStyle}>
        {this._renderGroupedChildren()}
      </TouchableOpacity>
    );
  },

  _renderGroupedChildren() {
    var {disabled} = this.props
    var style = [
      styles.text,
      disabled ? styles.disabledText : null,
      this.props.style,
      disabled ? this.props.styleDisabled : null,
    ];

    var children = coalesceNonElementChildren(this.props.children, (children, index) => {
      return (
        <Text key={index} style={style}>
          {children}
        </Text>
      );
    });

    console.log(children.length);
    switch (children.length) {
      case 0:
        return null;
      case 1:
        return children[0];
      default:
        return <View style={styles.group}>{children}</View>;
    }
  },

  _computeActiveOpacity() {
    if (this.props.disabled) {
      return 1;
    }
    return this.props.activeOpacity != null ?
      this.props.activeOpacity :
      systemButtonOpacity;
  },
});

const styles = StyleSheet.create({
  text: {
    color: '#007aff',
    fontFamily: 'sans-serif',
    fontSize: 17,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  disabledText: {
    color: '#dcdcdc',
  },
  group: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
});
