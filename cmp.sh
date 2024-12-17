#!/bin/bash

config_file="config.ini"

if [ ! -f "$config_file" ]; then
    echo "Error: config.ini が見つかりません。"
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "使用法: $0 target_dir"
    exit 1
fi

target_dir="$1"

if [ ! -d "$target_dir" ]; then
    echo "Error: '$target_dir' は存在しないか、ディレクトリではありません。"
    exit 1
fi

cpp_files=$(find "$target_dir" -type f -name "*.cpp")

if [ -z "$cpp_files" ]; then
    echo "Error: '$target_dir' に .cpp ファイルが見つかりません。"
    exit 1
fi

for cpp_file in $cpp_files
do
    base_name=$(basename "$cpp_file" .cpp)
    output_file="$target_dir/$base_name.o"

    echo "===================== $cpp_file のフォーマット結果 ====================="
    clang-format "$cpp_file"

    echo "$cpp_file をコンパイルしています..."
    g++ "$cpp_file" -o "$output_file"

    if [ "$?" -ne 0 ]; then
        echo "Error: $cpp_file のコンパイルに失敗しました。"
        continue
    fi

    echo "$output_file を実行しています..."
    "$output_file"

    if [ "$?" -eq 0 ]; then
        echo "$output_file を削除しています..."
        rm "$output_file"
    else
        echo "Error: $output_file の実行に失敗しました。削除しません。"
    fi
done
