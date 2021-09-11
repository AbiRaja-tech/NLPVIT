#!/bin/bash

. $(dirname $BASH_SOURCE)/base.sh

device=$1
transformer=$2
dataset=$3
seed=$4
prefix=$5
train_args=$6

wsd_xml=$fews/train/train.data.xml
wsd_label=$fews/train/train.gold.key.txt

dev_xml=$fews/dev/dev.data.xml
dev_label=$fews/dev/dev.gold.key.txt

cur=$experiment/$transformer/$dataset/sd_$seed
output=$cur/$prefix$(python $code/abbreviate_args.py $train_args)

CUDA_VISIBLE_DEVICES=$device python $(check_distributed $device) $code/main.py \
    --seed $seed \
    --cache_dir $cache \
    --model_name $transformer \
    --output_dir $output/model \
    --dataset_index $dataset \
    --do_train \
    --wsd_xml $wsd_xml \
    --wsd_label $wsd_label \
    --adam_epsilon 1e-6 \
    --warmup_ratio 0.1 \
    --do_eval \
    --dev_xml $dev_xml \
    --dev_label $dev_label \
    --load_best_model_at_end \
    --metric_for_best_model eval_f1 \
    --evaluation_strategy steps \
    --save_start_ratio 0.5 \
    --save_total_limit 8 \
    $train_args

rm -rf $output/model/checkpoint-*
