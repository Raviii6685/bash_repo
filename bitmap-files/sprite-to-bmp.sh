#!/opt/homebrew/bin/bash 



source ./lib-bmp.sh || exit 1

declare -A PALETTE

read -r -d '' USAGE <<- EOF
Usage: sprite-to-bmp -p <palette> [-o out.bmp] [-s scale]

Convert sprite text (stdin) to a 24-bit BMP.

Options:
  -h            Show help
  -p <palette>  Palette file (required)
  -o <file>     Output file (default: out.bmp)
  -s <scale>    Pixel scale factor (default: 1)
EOF

fatal() {
    echo "[fatal] $*" >&2
    exit 1
}

# Convert hex (#RRGGBB) to RGB
hex2rgb() {
    local hex=${1#\#}
    printf "%d %d %d" \
        "$((16#${hex:0:2}))" \
        "$((16#${hex:2:2}))" \
        "$((16#${hex:4:2}))"
}

load-palette() {
    local file=$1
    [[ -f $file ]] || fatal "palette file not found: $file"

    while read -r line; do
        [[ -z $line || $line =~ ^# ]] && continue

        local key=${line:0:1}
        local hex=${line:2}

        PALETTE[$key]=$(hex2rgb "$hex")
    done < "$file"
}

make-bmp() {
    local scale=$1

    mapfile -t SPRITE
    local height=${#SPRITE[@]}
    local width=${#SPRITE[0]}

    # Validate equal width
    for row in "${SPRITE[@]}"; do
        [[ ${#row} -ne $width ]] && fatal "inconsistent row width"
    done

    local scaled_width=$((width * scale))
    local scaled_height=$((height * scale))

    bmp-header "$scaled_width" "$scaled_height"
    local padding=$REPLY

    local y x sy sx char r g b

    for ((y = 0; y < height; y++)); do
        for ((sy = 0; sy < scale; sy++)); do

            for ((x = 0; x < width; x++)); do
                char=${SPRITE[height - y - 1]:x:1}
                read -r r g b <<< "${PALETTE[$char]:-0 0 0}"

                for ((sx = 0; sx < scale; sx++)); do
                    rgb "$r" "$g" "$b"
                done
            done

            bmp-pad "$padding"
        done
    done
}

main() {
    local output="out.bmp"
    local palette scale=1

    while getopts "hp:o:s:" opt; do
        case "$opt" in
            h) echo "$USAGE"; exit 0;;
            p) palette=$OPTARG;;
            o) output=$OPTARG;;
            s) scale=$OPTARG;;
            *) echo "$USAGE" >&2; exit 1;;
        esac
    done

    [[ -z $palette ]] && fatal "palette required (-p)"

    load-palette "$palette"
    make-bmp "$scale" > "$output" || fatal "failed to write $output"

    echo "Generated image: $output"
}

main "$@"