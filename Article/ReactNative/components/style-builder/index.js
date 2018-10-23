import {
    StyleSheet
} from 'react-native';
import StyleVariables from '../style-variables';

export default (BaseStyles) => {
    let day = {};
    let night = {};

    for (let selector in BaseStyles) {
        let declaration = BaseStyles[selector];

        day[selector] = {};
        night[selector] = {};

        for (let property in declaration) {
            let value = declaration[property];
            if (typeof value === "string" && value.indexOf('StyleVariables') > -1) {
                let var_field = value.split('.')[1];

                // console.log(selector, property, var_field, StyleVariables[var_field]);

                if (var_field.indexOf(',') > -1) {
                    // StyleVariables.#abc,#def
                    day[selector][property] = var_field.split(',')[0];
                    night[selector][property] = var_field.split(',')[1];
                } else {
                    // StyleVariables.plane4
                    day[selector][property] = StyleVariables[var_field].day;
                    night[selector][property] = StyleVariables[var_field].night;
                }
            } else {
                day[selector][property] = value;
                night[selector][property] = value;
            }
        }
    }

    // console.log(day, night);

    return {
        day: StyleSheet.create(day),
        night: StyleSheet.create(night)
    };
}
