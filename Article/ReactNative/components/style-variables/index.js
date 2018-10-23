/**
 * TODO
 * 1. 完善所有规范色值
 * 2. 考虑如何使用active色值
 * 3. 实现fadeout
 */
function fadeout (color, degree) {
    // FIXME
    return color;
}
/* day colors */
const new_blackgray_1 = '#222222';
const new_blackgray_1_active = fadeout(new_blackgray_1, 0.5);
const new_blackgray_2 = '#505050';
const new_blackgray_2_active = fadeout(new_blackgray_2, 0.5);
const new_blackgray_3 = '#999999';
const new_blackgray_3_active = fadeout(new_blackgray_3, 0.5);
const new_blackgray_4 = '#e8e8e8';
const new_blackgray_4_active = '#dddddd';
const new_blackgray_5 = '#e0e0e0';
const new_blackgray_5_active = '#e8e8e8';
const new_blackgray_6 = '#f4f5f6';
const new_blackgray_6_active = '#e8e8e8';
const new_blackgray_7 = '#f6f5f4';
const new_blackgray_7_active = '#e8e8e8';
const new_blackgray_8 = '#cacaca';
const new_blackgray_8_active = '#e8e8e8';
const new_blackgray_9 = '#f0f0f0';
const new_blackgray_9_active = '#dddddd';
const new_blackgray_10 = '#979fac';
const new_blackgray_10_active = fadeout(new_blackgray_10, 0.5);
const new_blackgray_11 = '#f8f8f8';
const new_blackgray_11_active = '#e8e8e8';
const new_separator_line_1 = '#e8e8e8';
const new_separator_line_1_active = fadeout(new_separator_line_1, 0.5);
const new_separator_line_2 = '#d8d8d8';
const new_separator_line_2_active = fadeout(new_separator_line_2, 0.5);
const new_separator_line_3 = '#dddddd';
const new_separator_line_3_active = fadeout(new_separator_line_3, 0.5);
const new_red_1 = '#f85959';
const new_red_1_active = fadeout(new_red_1, 0.5);
const new_red_2 = fadeout(new_red_1, 0.5);
const new_red_2_active = fadeout(new_red_1, 0.5);
const new_blue_1 = '#406599';
const new_blue_1_active = fadeout(new_blue_1, 0.5);
const new_blue_2 = '#2a90d7';
const new_blue_2_active = fadeout(new_blue_2, 0.5);
const new_blue_3 = fadeout(new_blue_2, 0.5);
const new_blue_3_active = fadeout(new_blue_2, 0.5);
const new_blue_4 = fadeout(new_blue_1, 0.5);
const new_blue_4_active = fadeout(new_blue_1, 0.5);
const pure_white = '#ffffff';
const new_white_1 = pure_white;
const new_white_1_active = '#e0e0e0';
const new_white_2 = fadeout(pure_white, 0.10);
const new_white_2_active = fadeout(pure_white, 0.10);
const new_white_3 = fadeout(pure_white, 0.04);
const new_white_3_active = fadeout(pure_white, 0.04);
const new_white_4 = pure_white;
const new_white_4_active = fadeout(pure_white, 0.5);
const new_white_5 = fadeout(pure_white, 0.5);
const new_white_5_active = fadeout(pure_white, 0.5);
const pure_black = '#000000';
const new_black_1 = pure_black;
const new_black_1_active = fadeout(pure_black, 0.5);
const new_black_2 = fadeout(pure_black, 0.70);
const new_black_2_active = fadeout(pure_black, 0.70);
const new_black_3 = fadeout(pure_black, 0.10);
const new_black_3_active = fadeout(pure_black, 0.10);
const new_black_4 = fadeout(pure_black, 0.5);
const new_black_4_active = fadeout(pure_black, 0.5);
const new_black_5 = fadeout(pure_black, 0.85);
const new_black_5_active = fadeout(pure_black, 0.85);
const new_black_6 = pure_black;
const new_black_6_active = pure_black;
/* night colors */
const new_night_black_1 = '#707070';
const new_night_black_1_active = fadeout(new_night_black_1, 0.5);
const new_night_black_2 = '#252525';
const new_night_black_2_active = '#1b1b1b';
const new_night_black_3 = '#1b1b1b';
const new_night_black_3_active = '#111111';
const new_night_separator_line_1 = '#464646';
const new_night_separator_line_1_active = fadeout(new_night_separator_line_1, 0.5);
const new_night_red_1 = '#935656';
const new_night_red1_active = fadeout(new_night_red_1, 0.5);
const new_night_red_2 = fadeout(new_night_red_1, 0.5);
const new_night_red_2_active = fadeout(new_night_red_1, 0.5);
const new_night_blue_1 = '#67778b';
const new_night_blue_1_active = fadeout(new_night_blue_1, 0.5);
const new_night_blue_2 = fadeout(new_night_blue_1, 0.5);
const new_night_blue_2_active = fadeout(new_night_blue_1, 0.5);

export default {
    'word1': {
        day: new_blackgray_1,
        night: new_night_black_1,
    },
    'word3': {
        day: new_blackgray_3,
        night: new_night_black_1,
    },
    'word4': {
        day: new_red_1,
        night: new_night_red_1,
    },
    'word6': {
        day: new_blue_2,
        night: new_night_blue_2,
    },
    'word7': {
        day: new_white_4,
        night: new_night_black_2,
    },
    'word13': {
        day: new_blackgray_10,
        night: new_night_black_1,
    },
    'line1': {
        day: new_separator_line_1,
        night: new_night_separator_line_1,
    },
    'line2': {
        day: new_red_1,
        night: new_night_red_1,
    },
    'line3': {
        day: new_blue_2,
        night: new_night_blue_1,
    },
    'plane2': {
        day: new_blackgray_4,
        night: new_night_black_3,
    },
    'plane4': {
        day: new_white_1,
        dayActive: new_white_1_active,
        night: new_night_black_2,
        nightActive: new_night_black_2_active,
    },
    'plane7': {
        day: new_red_1,
        night: new_night_red_1,
    }
}
