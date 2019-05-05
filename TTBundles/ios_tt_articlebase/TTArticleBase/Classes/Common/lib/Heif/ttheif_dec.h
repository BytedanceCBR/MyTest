/*
 * Toutiao HEIF Decoder utils: definations and structures
 * 
 * Author Jiexi Wang (wangjiexi@bytedance.com)
 *
 * Copyright (c) 2017 bytedance
 * 
 * Date 2017-10-19
 *
 * This file is part of libtth
 */

#ifndef TT_HEIF_DEC
#define TT_HEIF_DEC

#include <stdint.h>
#include <stdbool.h>

typedef struct HeifOutputStream {
    uint32_t size;
    uint8_t * data;
} HeifOutputStream;


// Note: if decoding failed, the 'size' field of returned HeifOutputStream is 0,
// and the 'data' field of returned HeifOutputStream is NULL

// decode the heif file data to rgb data, and output the width and height of the image
HeifOutputStream heif_decode_to_rgb(uint8_t * heif_data, uint32_t data_size, uint32_t * width, uint32_t * height);

// decode the heif file data to rgb data, and output the width and height of the image
// alpha channel is not supported yet, and alpha is set to be UINT8_MAX to make the picture opaque
HeifOutputStream heif_decode_to_rgba(uint8_t * heif_data, uint32_t data_size, uint32_t * width, uint32_t * height);

// decode the heif file data to yuv420p data, and output the width and height of the image
HeifOutputStream heif_decode_to_yuv420p(uint8_t * heif_data, uint32_t data_size, uint32_t * width, uint32_t * height);

// only parse the undecoded hevc data
HeifOutputStream heif_decode_to_hevc(uint8_t * heif_data, uint32_t data_size);

// only parse the width and height, return true if parsing succeeded
bool heif_parse_size(uint8_t * heif_data, uint32_t data_size, uint32_t * width, uint32_t * height);

// judge whether this file is a .heic file
bool heif_judge_file_type(uint8_t * heif_data, uint32_t data_size);

#endif
