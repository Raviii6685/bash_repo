source ./lib-bmp.sh || exit 1


main() {

width=2
height=2

bmp-header "$width" "$height"
padding=$REPLY

#ColorTable
    #Red(1B)
    rgb 0 0 0 
    rgb 255 255 255 
    bmp-pad "$padding"

    rgb 255 0 0 
    rgb 0 255 255 
    bmp-pad "$padding"
    #Blue(1B)
    #green(1B)
    #Reserved(1B)
}
#data

main "$@"