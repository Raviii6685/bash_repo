#!/usr/bin/env bash

###TODO emit a BMP file

#converting a number into the little endian 
make-ui32le() {
    local file_size="$1" 

    #here we are converting the number into the 4 bit octets or hexadecimal

    #number broken into 4 octets
    local octet1=$(((file_size>>24) & 0xFF))
    local octet2=$(((file_size>>16) & 0xFF))
    local octet3=$(((file_size>>8) & 0xFF))
    local octet4=$(((file_size>>0) & 0xFF))

    printf '%b' "$(printf '\\x%02x\\x%02x\\x%02x\\x%02x' \
        "$octet4" "$octet3" "$octet2" "$octet1")" 
}

make-ui16le() {
    local file_size="$1" 

    #here we are converting the number into the 4 bit octets or hexadecimal

    #number broken into 4 octets
    local octet1=$(((file_size>>8) & 0xFF))
    local octet2=$(((file_size>>0) & 0xFF))

    printf '%b' "$(printf '\\x%02x\\x%02x' "$octet2" "$octet1")" 
}

rgb() {
    local r=$1
    local g=$2
    local b=$3
  
    printf '%b' "$(printf '\\x%02x\\x%02x\\x%02x' "$b" "$g" "$r")" 
}

bmp-header() {
    local width=$1
    local height=$2

#header (14B)
    #signature (2B)
    printf 'BM'

    #bitcount (2B)
    local bits_per_px=24
    local bytes_per_px=$((bits_per_px / 8)) #this is bitcount
    local row_size=$((width * bytes_per_px))

    #BMP to be aligned to 4Byte boundary means row_size%4==0 must
    local padding=0
    while ((row_size%4!=0));
    do
        ((row_size++))
        ((padding++))
    done

    #filesize (4B)
    local pixel_data_size=$((height*row_size))
    local data_offset=$((40+14))
    local file_size=$((pixel_data_size+data_offset))

    make-ui32le "$file_size"

    #reserved   (4B)
    make-ui32le 0

    #data offset (4B)
    make-ui32le "$data_offset"

#additional Info-Header (40B)
    #Size(4B)(40B bydfault)
    make-ui32le 40

    #width(4B)
    make-ui32le "$width"

    #heigth(4B)
    make-ui32le "$height"

    # planes (2B 1by default)
    make-ui16le 1

    make-ui16le "$bits_per_px"

    #Compression(4B)
    make-ui32le 0

    #ImageSize(4B)
    make-ui32le "$pixel_data_size"

    #xpixelsPerM(4B)
    make-ui32le 0

    #ypixelsPerM(4B)
    make-ui32le 0

    #ColorsUsed(4B)
    make-ui32le 0

    #ColorsImportant(4B)
    make-ui32le 0

    REPLY=$padding
}

bmp-pad(){
    local padding=$1
    for ((i=0;i<padding;i++));
    do
        printf '\0'
    done
}


##we are going to make this only as library 