#!/bin/bash


for dir in */; do
    touch "$dir"/{1..500}-cache
done
