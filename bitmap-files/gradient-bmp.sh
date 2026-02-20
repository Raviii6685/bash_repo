source ./lib-bmp.sh || exit 1

debug(){
    local x=$@
    echo "[debug]: line executed $x"  >&2
}
main() {

local width=400
local height=400

bmp-header "$width" "$height"
local padding=$REPLY

#ColorTable
    #Red(1B)
    local r g b 

    for ((y=0 ; y< height ;y++));
    do 
        for ((x=0 ; x<width ;x++));
        do 
            ((r=x*255/width ))
            ((g=y*255/height))
            rgb $r $g 0 
            debug $x 

        done
        bmp-pad "$padding"
    done 


    
}
#data

main "$@"