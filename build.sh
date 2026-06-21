#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSWM_DIR="$SCRIPT_DIR/CSWM"
OUTPUT="cswm_amxx_i386.so"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[BUILD]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Проверка компилятора ---
find_compiler() {
    for cc in g++ g++-13 g++-12 g++-11 g++-10 g++-9 g++-8 g++-7 g++-6 g++-5 g++-4.9 g++-4.8; do
        if command -v "$cc" &>/dev/null; then
            echo "$cc"
            return
        fi
    done
    err "g++ не найден. Установите: sudo apt install g++"
}

# --- Проверка 32-bit библиотек ---
check_multilib() {
    if ! dpkg -l gcc-multilib &>/dev/null 2>&1; then
        if ! dpkg -l g++-multilib &>/dev/null 2>&1; then
            warn "32-bit библиотеки не установлены. Попробуйте: sudo apt install gcc-multilib g++-multilib"
        fi
    fi
}

# --- Компиляция ---
do_build() {
    local compiler
    compiler=$(find_compiler)
    log "Компилятор: $compiler"
    log "Целевая архитектура: i386 (32-bit)"
    log "Каталог сборки: $CSWM_DIR"

    check_multilib

    cd "$CSWM_DIR"

    log "Сборка $OUTPUT ..."
    $compiler -shared -mtune=i386 -O3 -m32 \
        -I ./ \
        -I ../ \
        -I ../SDK/ \
        -I ../SDK/metamod/ \
        -I ../SDK/cssdk \
        -DHAVE_STDINT_H \
        -D_CRT_SECURE_NO_WARNINGS \
        182/AMXX.cpp Module.cpp CSWM.cpp HEFW.cpp FakeCMD.cpp \
        -o "$OUTPUT"

    if [ -f "$OUTPUT" ]; then
        local size
        size=$(du -h "$OUTPUT" | cut -f1)
        log "Готово! Файл: $CSWM_DIR/$OUTPUT ($size)"
    else
        err "Файл не был создан"
    fi
}

# --- Очистка ---
do_clean() {
    cd "$CSWM_DIR"
    rm -f "$OUTPUT" *.o
    log "Очищено."
}

# --- Установка ---
do_install() {
    local dest="${1:-/home/cs/cs/cstrike/addons/amxmodx/modules}"
    do_build
    mkdir -p "$dest"
    cp "$CSWM_DIR/$OUTPUT" "$dest/"
    log "Установлено в: $dest/$OUTPUT"
}

# --- Главное ---
case "${1:-build}" in
    build)   do_build ;;
    clean)   do_clean ;;
    install) do_install "$2" ;;
    *)
        echo "Использование: $0 {build|clean|install [путь]}"
        echo ""
        echo "  build    - собрать модуль (по умолчанию)"
        echo "  clean    - удалить собранные файлы"
        echo "  install  - собрать и установить в папку модулей AMX Mod X"
        exit 1
        ;;
esac
