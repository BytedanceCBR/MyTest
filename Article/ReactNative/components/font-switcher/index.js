/**
 * TODO
 * 1. 考虑适配不同尺寸 5s/6,6p/android
 */

export default (basicSize, fontMode) => {
    switch (fontMode) {
        case 's':
            return basicSize - 2;
            break;
        case 'l':
            return basicSize + 2;
            break;
        case 'xl':
            return basicSize + 5;
            break;
        default:
            return basicSize;
    }
}
