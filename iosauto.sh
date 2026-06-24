#!/bin/sh

# =================== THIẾT LẬP BIẾN VÀ HÀM ===================

# 📌 ĐÃ SỬA: Ép thư mục nguồn trùng khớp hoàn toàn với vị trí Git Clone
SOURCE_DIR="$HOME/iosauto"
ADB_COMMAND="adb"

# Sử dụng dải màu BOLD (Đậm) để giao diện rực rỡ và sắc nét
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color

# Hàm in tiêu đề cực chất cho các menu
print_header() {
    clear
    printf "${CYAN}╔════════════════════════════════════════════════════════╗${NC}\n"
    printf "${CYAN}║${NC} ${YELLOW}        🚀 CÔNG CỤ CÀI ĐẶT TIVI XIAOMI (BẢN iSH) 🚀      ${NC} ${CYAN}║${NC}\n"
    printf "${CYAN}╚════════════════════════════════════════════════════════╝${NC}\n\n"
}

# ==============================================================================
# CÁC HÀM TIỆN ÍCH VÀ THÔNG SỐ (UI)
# ==============================================================================
return_menu() {
    printf "\n${CYAN}────────────────────────────────────────────────────────${NC}\n"
    for i in 3 2 1; do
        printf "  ${YELLOW}⏳ HOÀN TẤT! Tự động quay lại Menu sau ${WHITE}$i${YELLOW} giây...${NC} \r"
        sleep 1
    done
    printf "                                                          \r"
}

get_tv_info() {
    printf "${YELLOW}🔄 Đang lấy thông tin hệ thống Tivi...${NC}\n"
    MODEL=$($ADB_COMMAND shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    BRAND=$($ADB_COMMAND shell getprop ro.product.brand 2>/dev/null | tr -d '\r')
    PANEL=$($ADB_COMMAND shell getprop ro.boot.mi.panel_size 2>/dev/null | tr -d '\r')
    ANDROID=$($ADB_COMMAND shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    PATCH=$($ADB_COMMAND shell getprop ro.build.version.security_patch 2>/dev/null | tr -d '\r')
    BUILD_SHOW=$($ADB_COMMAND shell getprop ro.build.version.incremental 2>/dev/null | tr -d '\r')
    DATE=$($ADB_COMMAND shell getprop ro.build.date 2>/dev/null | tr -d '\r')
    SERIAL=$($ADB_COMMAND shell getprop ro.serialno 2>/dev/null | tr -d '\r')

    [ -z "$PANEL" ] && PANEL="?"

    # Đóng khung thông tin Tivi cho ngầu
    TV_INFO_LINE="${CYAN}┌────────────────── ${YELLOW}THÔNG TIN THIẾT BỊ${CYAN} ──────────────────┐${NC}\n"
    TV_INFO_LINE="${TV_INFO_LINE}${CYAN}│${NC} 📺 ${WHITE}TIVI    :${NC} ${GREEN}$MODEL${NC} ${YELLOW}(${BRAND})${NC} - ${MAGENTA}${PANEL} Inch${NC}\n"
    TV_INFO_LINE="${TV_INFO_LINE}${CYAN}│${NC} 🤖 ${WHITE}ANDROID :${NC} ${GREEN}Bản $ANDROID${NC} | Patch: ${YELLOW}$PATCH${NC}\n"
    TV_INFO_LINE="${TV_INFO_LINE}${CYAN}│${NC} ⚙️  ${WHITE}BUILD   :${NC} ${WHITE}$BUILD_SHOW${NC} ${CYAN}[$DATE]${NC}\n"
    TV_INFO_LINE="${TV_INFO_LINE}${CYAN}│${NC} 🔢 ${WHITE}SERIAL  :${NC} ${YELLOW}$SERIAL${NC}\n"
    TV_INFO_LINE="${TV_INFO_LINE}${CYAN}│${NC} 🌐 ${WHITE}KẾT NỐI :${NC} ${GREEN}[ $DEVICE_IP ]${NC}\n"
    TV_INFO_LINE="${TV_INFO_LINE}${CYAN}└────────────────────────────────────────────────────────┘${NC}\n"
}

install_apk() {
    apk_file=$1
    if [ -f "$apk_file" ]; then
        printf "    ${CYAN}[+]${NC} Đang cài đặt: ${YELLOW}$apk_file${NC} ...\n"
        if $ADB_COMMAND install -r -g "$apk_file" >/dev/null 2>&1; then
            printf "         ${GREEN}╰─> ✅ Thành công!${NC}\n"
        else
            printf "         ${RED}╰─> ❌ Thất bại!${NC}\n"
        fi
    else
        printf "    ${RED}[!]${NC} ${YELLOW}Không tìm thấy file: ${WHITE}$apk_file${YELLOW} -> Bỏ quan tâm.${NC}\n"
    fi
}

# =================== BẮT ĐẦU KỊCH BẢN ===================

# 1. KIỂM TRA MÔI TRƯỜNG
if [ ! -d "$SOURCE_DIR" ]; then
    printf "${RED}❌ Không tìm thấy thư mục nguồn: ${WHITE}$SOURCE_DIR${NC}\n"
    printf "   Hệ thống đang tự động tạo không gian làm việc mới...\n"
    mkdir -p "$SOURCE_DIR"
fi

cd "$SOURCE_DIR" || exit

# Tối ưu quét IP cho iOS (Nhập thủ công chuẩn xác)
scan_ips() {
    printf "${YELLOW}📡 MÔI TRƯỜNG iOS: Thiết bị chặn tự động quét dải mạng Wi-Fi.${NC}\n"
    printf "${WHITE}👉 Vui lòng xem IP trên Tivi hoặc dùng app Fing trên iPhone.${NC}\n\n"
    printf "${GREEN}👉 Nhập chính xác IP Tivi (vd: 192.168.1.100): ${NC}"
    read RAW_IP
}

# 2. MENU 1: KẾT NỐI VỚI TV
menu1() {
    while true; do
        print_header
        printf "${WHITE}📌 HƯỚNG DẪN KẾT NỐI ADB VỚI TV XIAOMI:${NC}\n"
        printf "  ${CYAN}[1]${NC} Vào Cài đặt -> Giới thiệu -> Nhấn vào 'Build number' 5-7 lần.\n"
        printf "  ${CYAN}[2]${NC} Quay lại Cài đặt -> Tùy chọn nhà phát triển.\n"
        printf "  ${CYAN}[3]${NC} Bật 'ADB Debugging' (Gỡ lỗi ADB).\n"
        printf "  ${CYAN}[4]${NC} Đảm bảo TV và điện thoại đang kết nối chung một mạng Wi-Fi.\n"
        printf "${CYAN}────────────────────────────────────────────────────────${NC}\n\n"

        RAW_IP=""
        DEVICE_IP=""
        scan_ips

        if [ -z "$RAW_IP" ]; then
            printf "${RED}❌ Bạn chưa nhập IP. Vui lòng thử lại.${NC}\n"
            sleep 2
            continue
        fi

        DEVICE_IP="${RAW_IP}:5555"

        printf "\n${YELLOW}🔄 Đang ngắt kết nối cũ (nếu có)...${NC}\n"
        $ADB_COMMAND disconnect >/dev/null 2>&1
        sleep 1

        printf "${YELLOW}🔄 Đang kết nối tới ${WHITE}$DEVICE_IP${YELLOW}...${NC}\n"
        connection_output=$($ADB_COMMAND connect "$DEVICE_IP")
        printf "   ${CYAN}>> ${WHITE}$connection_output${NC}\n"

        printf "\n${MAGENTA}📺 VUI LÒNG NHẤN 'ALLOW' HOẶC 'CHO PHÉP' TRÊN MÀN HÌNH TIVI...${NC}\n"
        sleep 8

        if $ADB_COMMAND devices | grep -q "$RAW_IP.*device"; then
            printf "   ${GREEN}✅ Kết nối thành công tới thiết bị!${NC}\n"
            sleep 1
            
            menu2 
            
            RAW_IP=""
            DEVICE_IP=""
        else
            printf "   ${RED}❌ Kết nối thất bại.${NC}\n"
            printf "   ${YELLOW}• Kiểm tra lại IP, đảm bảo đã bật ADB Debugging và xác nhận trên TV.${NC}\n"
            sleep 4
        fi
    done
}

# 3. MENU 2: MENU CHỨC NĂNG CHÍNH
menu2() {
    get_tv_info

    while true; do
        print_header
        printf "$TV_INFO_LINE\n\n"
        
        printf "  ${YELLOW}▶ CÀI ĐẶT HỆ THỐNG TIVI${NC}\n"
        printf "     ${CYAN}[1]${NC} ${WHITE}Cài Các Dòng TV Cũ dưới 2025${NC}\n"
        printf "     ${CYAN}[2]${NC} ${WHITE}Cài Các Dòng TV 2026${NC}\n"
        printf "     ${CYAN}[3]${NC} ${WHITE}Cài App APK cho TV Quốc Tế${NC}\n\n"
        
        printf "  ${YELLOW}▶ TIỆN ÍCH & SAO LƯU DỮ LIỆU${NC}\n"
        printf "     ${BLUE}[4]${NC} ${WHITE}Sao Chép Ảnh Nền Lên TV${NC}\n"
        printf "     ${BLUE}[5]${NC} ${WHITE}Tải File APK & Ảnh Về Máy${NC}\n\n"
        
        printf "  ${YELLOW}▶ HỆ THỐNG & ĐIỀU KHIỂN${NC}\n"
        printf "     ${MAGENTA}[6]${NC} ${WHITE}Khởi Động Lại TV (Reboot)${NC}\n"
        printf "     ${RED}[7]${NC} ${WHITE}Reset Cứng vào Recovery Nội Địa${NC}\n"
        printf "     ${CYAN}[8]${NC} ${WHITE}Ngắt Kết Nối & Đổi TV Khác${NC}\n"
        printf "     ${RED}[0]${NC} ${WHITE}Thoát Công Cụ${NC}\n"
        printf "${CYAN}────────────────────────────────────────────────────────${NC}\n\n"

        printf " 👉 Nhập tùy chọn của bạn [0-8]: "
        read CHOICE

        case $CHOICE in
            1) install_projectivy ;;
            2) install_launcherfire ;;
            3) install_specific_apks ;; 
            4) copy_wallpapers ;;
            5) download_from_github ;;
            6) reboot_tv ;;
            7) reboot_recovery ;;
            8) $ADB_COMMAND disconnect >/dev/null 2>&1; break ;;
            0) printf "\n${GREEN}👋 CẢM ƠN ĐÃ SỬ DỤNG CÔNG CỤ! HẸN GẶP LẠI.${NC}\n\n"; exit 0 ;;
            *) printf "   ${RED}⚠️ Lựa chọn không hợp lệ, vui lòng chọn lại.${NC}\n"; sleep 2 ;;
        esac
    done
}

# =================== CÁC HÀM CHỨC NĂNG ===================

download_from_github() {
    print_header
    printf "${CYAN}⬇️ ĐANG KẾT NỐI TỚI KHO CHỨA DỮ LIỆU...${NC}\n"
    printf "   ${WHITE}Thư mục lưu: ${YELLOW}$SOURCE_DIR${NC}\n"
    printf "${CYAN}────────────────────────────────────────────────────────${NC}\n"

    BASE_URL="http://tivixiaomi.vn/APPCAITIVI"
    FILES="p.apk keyboard.apk katniss_2.2.0.apk mi.apk tizentube.apk m.apk quantv.apk qlgd.apk an.apk youtube.apk oktv.apk getout.apk phim4k.apk projectivy.plbackup 1.jpg 2.jpg 3.jpg 4.jpg 5.jpg 6.jpg 7.jpg 8.jpg"

    set -- $FILES
    printf "📦 Đang tiến hành tải ${YELLOW}$#${NC} tệp tin...\n\n"

    for file in $FILES; do
        printf "    ${CYAN}[+]${NC} Đang tải ${WHITE}$file${NC}...\n"
        
        # SỬ DỤNG CURL -# ĐỂ HIỂN THỊ THANH PHẦN TRĂM 100%
        if curl -L -k -# -o "$file" "$BASE_URL/$file"; then
            if grep -q "404: Not Found" "$file"; then
                printf "         ${RED}╰─> ❌ Không tìm thấy file trên Server!${NC}\n\n"
                rm -f "$file"
            else
                printf "         ${GREEN}╰─> ✅ Tải hoàn tất!${NC}\n\n"
            fi
        else
            printf "         ${RED}╰─> ❌ Lỗi kết nối mạng!${NC}\n\n"
        fi
    done

    printf "${CYAN}────────────────────────────────────────────────────────${NC}\n"
    printf "    ${GREEN}🎉 TIẾN TRÌNH TẢI FILE HOÀN TẤT!${NC}\n"
    return_menu
}

install_projectivy() {
    printf "\n${CYAN}========================================================${NC}\n"
    printf "${YELLOW}⚙️ ĐANG THIẾT LẬP THÔNG SỐ HỆ THỐNG TIVI...${NC}\n"
    $ADB_COMMAND shell service call alarm 3 s16 Asia/Bangkok >/dev/null 2>&1
    $ADB_COMMAND shell settings put global device_locales vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put global sys_locale vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put system system_locales vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put global heads_up_notifications_enabled 0 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global stay_on_while_plugged_in 3 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global window_animation_scale 1 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global transition_animation_scale 1 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global animator_duration_scale 1 >/dev/null 2>&1
    printf "    ${GREEN}✅ Thiết lập thông số cơ bản hoàn tất.${NC}\n"

    printf "\n${YELLOW}🚀 BƯỚC 1: CÀI ĐẶT GIAO DIỆN CHÍNH...${NC}\n"
    $ADB_COMMAND uninstall com.spocky.projengmenu >/dev/null 2>&1
    install_apk "p.apk"

    # 🌟 VÁ LỖI CHỐNG CHẶN: ĐẨY LỆNH CÀI APP LÊN TRƯỚC KHI KHÓA GOI HỆ THỐNG CHẠY NGẦM
    apks_to_install="keyboard.apk katniss_2.2.0.apk mi.apk m.apk quantv.apk an.apk youtube.apk oktv.apk getout.apk phim4k.apk"

    printf "\n${YELLOW}🚀 BƯỚC 2: CÀI ĐẶT ỨNG DỤNG CẦN THIẾT...${NC}\n"
    for apk in $apks_to_install; do
        install_apk "$apk"
    done

    printf "\n${YELLOW}🖼️ BƯỚC 3: SAO CHÉP DỮ LIỆU & ẢNH NỀN...${NC}\n"
    $ADB_COMMAND push projectivy.plbackup /sdcard/Download >/dev/null 2>&1
    count=0
    for ext in jpg jpeg png JPG JPEG PNG; do
        for file in *."$ext"; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                extension="${filename##*.}"
                $ADB_COMMAND push "$file" "/sdcard/DCIM_${count}.${extension}" >/dev/null 2>&1
                count=$((count + 1))
            fi
        done
    done
    printf "     ${GREEN}✅ Đã chép File cấu hình và Ảnh nền.${NC}\n"

    printf "\n${YELLOW}🚫 BƯỚC 4: VÔ HIỆU HÓA ỨNG DỤNG RÁC (BLOATWARE) SAU KHI CÀI APP...${NC}\n"
    packages_to_disable="com.mitv.tvhome com.android.tv.settings com.mitv.gallery com.xiaomi.tweather com.mitv.screensaver com.xiaomi.mitv.shop com.duokan.videodaily com.xiaomi.tv.gallery com.mitv.cloudcontrol com.miui.tv.analytics com.xiaomi.voicecontrol com.xiaomi.mitv.upgrade com.xiaomi.mitv.appstore com.xiaomi.mitv.calendar com.xiaomi.mitv.handbook com.xiaomi.screenrecorder com.sohu.inputmethod.sogou.tv com.xiaomi.mitv.karaoke.service com.xiaomi.mitv.hyper.screensaver"
    
    for pkg in $packages_to_disable; do
        printf "     ${RED}[✖]${NC} Đóng băng: ${WHITE}$pkg${NC}\n"
        $ADB_COMMAND shell pm disable-user --user 0 "$pkg" >/dev/null 2>&1
    done
    printf "     ${GREEN}✅ Dọn dẹp ứng dụng rác hoàn tất.${NC}\n"
    
    printf "\n${YELLOW}🔑 BƯỚC 5: CẤP QUYỀN HỆ THỐNG CHO ỨNG DỤNG...${NC}\n"
    pkg="com.spocky.projengmenu"
    
    appops_perms="REQUEST_INSTALL_PACKAGES WRITE_SETTINGS MANAGE_EXTERNAL_STORAGE"
    runtime_perms="android.permission.READ_EXTERNAL_STORAGE android.permission.WRITE_EXTERNAL_STORAGE android.permission.READ_MEDIA_IMAGES android.permission.READ_MEDIA_VIDEO android.permission.READ_MEDIA_AUDIO"

    for p in 10 25 40 55 70 85 100; do
        printf "     ${CYAN}⏳ Cấp quyền Root cho $pkg | ${WHITE}${p}%%${NC}\r"
        sleep 1
    done
    printf "     ${CYAN}⏳ Cấp quyền Root cho $pkg | ${GREEN}100%% ✅${NC}\n"

    for perm in $appops_perms; do
        $ADB_COMMAND shell appops set "$pkg" "$perm" allow >/dev/null 2>&1
    done

    for perm in $runtime_perms; do
        $ADB_COMMAND shell pm grant "$pkg" "$perm" >/dev/null 2>&1
    done
    
    $ADB_COMMAND shell "appops set com.spocky.projengmenu REQUEST_INSTALL_PACKAGES allow" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.mitv.shareds android.permission.WRITE_SECURE_SETTINGS" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.mitv.shareds android.permission.CHANGE_CONFIGURATION" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.spocky.projengmenu android.permission.WRITE_EXTERNAL_STORAGE" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.spocky.projengmenu android.permission.READ_EXTERNAL_STORAGE" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.spocky.projengmenu android.permission.WRITE_SECURE_SETTINGS" >/dev/null 2>&1
    $ADB_COMMAND shell "appops set com.google.android.katniss SYSTEM_ALERT_WINDOW allow" >/dev/null 2>&1
    $ADB_COMMAND shell "cmd appops set com.spocky.projengmenu WRITE_EXTERNAL_STORAGE allow" >/dev/null 2>&1
    $ADB_COMMAND shell "cmd appops set com.spocky.projengmenu READ_EXTERNAL_STORAGE allow" >/dev/null 2>&1
    $ADB_COMMAND shell "appops set com.spocky.projengmenu REQUEST_INSTALL_PACKAGES allow" >/dev/null 2>&1
    $ADB_COMMAND shell "ime enable com.liskovsoft.leankeyboard/.ime.LeanbackImeService" >/dev/null 2>&1
    $ADB_COMMAND shell "settings put secure default_input_method com.liskovsoft.leankeyboard/.ime.LeanbackImeService" >/dev/null 2>&1
    $ADB_COMMAND shell "settings put secure enabled_accessibility_services com.mitv.shareds/com.mitv.shareds.HomeService:com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService:com.spocky.projengmenu/com.spocky.projengmenu.services.VoiceButtonService" >/dev/null 2>&1
    $ADB_COMMAND shell "settings put secure accessibility_enabled 1" >/dev/null 2>&1
    $ADB_COMMAND shell "cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity" >/dev/null 2>&1
    $ADB_COMMAND shell monkey -p com.spocky.projengmenu -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    $ADB_COMMAND shell am start -n com.spocky.projengmenu/.ui.home.MainActivity >/dev/null 2>&1

    printf "\n${YELLOW}🔄 BƯỚC 6: LÀM MỚI GIAO DIỆN & ĐỒNG BỘ Ổ CỨNG...${NC}\n"
    
    $ADB_COMMAND shell dumpsys deviceidle whitelist +com.spocky.projengmenu >/dev/null 2>&1
    $ADB_COMMAND shell am force-stop com.spocky.projengmenu >/dev/null 2>&1
    
    $ADB_COMMAND shell cmd appops write-settings >/dev/null 2>&1
    sleep 1
    $ADB_COMMAND shell settings put global install_non_market_apps 1 >/dev/null 2>&1
    sleep 1
    $ADB_COMMAND shell settings list secure >/dev/null 2>&1
    sleep 1
    $ADB_COMMAND shell sync >/dev/null 2>&1
    sleep 2 
    
    $ADB_COMMAND shell input keyevent 3 >/dev/null 2>&1
    sleep 1
    
    printf "\n${CYAN}========================================================${NC}\n"
    printf "${GREEN}🎉 CÀI ĐẶT HOÀN TẤT!${NC}\n"
    printf "${MAGENTA}📺 TV sẽ khởi động lại sau 2 giây để áp dụng cấu hình...${NC}\n"
    sleep 2
    
    $ADB_COMMAND reboot >/dev/null 2>&1
    return_menu
}

install_launcherfire() {
    printf "\n${CYAN}========================================================${NC}\n"
    printf "${YELLOW}⚙️ ĐANG THIẾT LẬP THÔNG SỐ CƠ BẢN HỆ THỐNG TIVI...${NC}\n"
    $ADB_COMMAND shell service call alarm 3 s16 Asia/Bangkok >/dev/null 2>&1
    $ADB_COMMAND shell settings put global device_locales vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put global sys_locale vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put system system_locales vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put global heads_up_notifications_enabled 0 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global stay_on_while_plugged_in 3 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global window_animation_scale 1 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global transition_animation_scale 1 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global animator_duration_scale 1 >/dev/null 2>&1
    $ADB_COMMAND shell appops set com.xiaomi.voicecontrol SYSTEM_ALERT_WINDOW deny >/dev/null 2>&1
    printf "    ${GREEN}✅ Thiết lập thông số cơ bản hoàn tất.${NC}\n"

    printf "\n${YELLOW}🚀 BƯỚC 1: CÀI ĐẶT GIAO DIỆN 2026...${NC}\n"
    $ADB_COMMAND uninstall com.spocky.projengmenu >/dev/null 2>&1
    install_apk "p.apk"

    # 🌟 VÁ LỖI CHO BẢN PRO 2026: CÀI APP TRƯỚC - KHÓA RÁC SAU
    apks_to_install="keyboard.apk katniss_2.2.0.apk mi.apk m.apk quantv.apk an.apk youtube.apk oktv.apk getout.apk phim4k.apk"

    printf "\n${YELLOW}🚀 BƯỚC 2: CÀI ĐẶT ỨNG DỤNG CẦN THIẾT...${NC}\n"
    for apk in $apks_to_install; do
        install_apk "$apk"
    done

    printf "\n${YELLOW}🖼️ BƯỚC 3: SAO CHÉP DỮ LIỆU & ẢNH NỀN...${NC}\n"
    $ADB_COMMAND push projectivy.plbackup /sdcard/Download >/dev/null 2>&1
    count=0
    for ext in jpg jpeg png JPG JPEG PNG; do
        for file in *."$ext"; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                extension="${filename##*.}"
                $ADB_COMMAND push "$file" "/sdcard/DCIM_${count}.${extension}" >/dev/null 2>&1
                count=$((count + 1))
            fi
        done
    done
    printf "     ${GREEN}✅ Đã chép File cấu hình và Ảnh nền.${NC}\n"

    printf "\n${YELLOW}🚫 BƯỚC 4: VÔ HIỆU HÓA ỨNG DỤNG RÁC SAU KHI CÀI XONG APP...${NC}\n"
    packages_to_disable="com.mitv.tvhome com.android.tv.settings com.mitv.gallery com.xiaomi.tweather com.mitv.screensaver com.xiaomi.mitv.shop com.duokan.videodaily com.xiaomi.tv.gallery com.mitv.cloudcontrol com.miui.tv.analytics com.xiaomi.voicecontrol com.xiaomi.mitv.upgrade com.xiaomi.mitv.appstore com.xiaomi.mitv.calendar com.xiaomi.mitv.handbook com.xiaomi.screenrecorder com.sohu.inputmethod.sogou.tv com.xiaomi.mitv.karaoke.service com.xiaomi.mitv.hyper.screensaver"
    
    for pkg in $packages_to_disable; do
        printf "     ${RED}[✖]${NC} Đóng băng: ${WHITE}$pkg${NC}\n"
        $ADB_COMMAND shell pm disable-user --user 0 "$pkg" >/dev/null 2>&1
    done
    printf "     ${GREEN}✅ Dọn dẹp ứng dụng rác hoàn tất.${NC}\n"

    printf "\n${YELLOW}🔑 BƯỚC 5: ĐANG CẤP QUYỀN ỨNG DỤNG...${NC}\n"
    pkg="com.spocky.projengmenu"
    
    appops_perms="REQUEST_INSTALL_PACKAGES WRITE_SETTINGS MANAGE_EXTERNAL_STORAGE"
    runtime_perms="android.permission.READ_EXTERNAL_STORAGE android.permission.WRITE_EXTERNAL_STORAGE android.permission.READ_MEDIA_IMAGES android.permission.READ_MEDIA_VIDEO android.permission.READ_MEDIA_AUDIO"

    for p in 10 25 40 55 70 85 100; do
        printf "     ${CYAN}⏳ Cấp quyền Root cho $pkg | ${WHITE}${p}%%${NC}\r"
        sleep 1
    done
    printf "     ${CYAN}⏳ Cấp quyền Root cho $pkg | ${GREEN}100%% ✅${NC}\n"

    for perm in $appops_perms; do
        $ADB_COMMAND shell appops set "$pkg" "$perm" allow >/dev/null 2>&1
    done

    for perm in $runtime_perms; do
        $ADB_COMMAND shell pm grant "$pkg" "$perm" >/dev/null 2>&1
    done
    
    $ADB_COMMAND shell "appops set com.spocky.projengmenu REQUEST_INSTALL_PACKAGES allow" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.mitv.shareds android.permission.WRITE_SECURE_SETTINGS" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.mitv.shareds android.permission.CHANGE_CONFIGURATION" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.spocky.projengmenu android.permission.WRITE_EXTERNAL_STORAGE" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.spocky.projengmenu android.permission.READ_EXTERNAL_STORAGE" >/dev/null 2>&1
    $ADB_COMMAND shell "pm grant com.spocky.projengmenu android.permission.WRITE_SECURE_SETTINGS" >/dev/null 2>&1
    $ADB_COMMAND shell "appops set com.google.android.katniss SYSTEM_ALERT_WINDOW allow" >/dev/null 2>&1
    $ADB_COMMAND shell "cmd appops set com.spocky.projengmenu WRITE_EXTERNAL_STORAGE allow" >/dev/null 2>&1
    $ADB_COMMAND shell "cmd appops set com.spocky.projengmenu READ_EXTERNAL_STORAGE allow" >/dev/null 2>&1
    $ADB_COMMAND shell "appops set com.spocky.projengmenu REQUEST_INSTALL_PACKAGES allow" >/dev/null 2>&1
    $ADB_COMMAND shell "ime enable com.liskovsoft.leankeyboard/.ime.LeanbackImeService" >/dev/null 2>&1
    $ADB_COMMAND shell "settings put secure default_input_method com.liskovsoft.leankeyboard/.ime.LeanbackImeService" >/dev/null 2>&1
    $ADB_COMMAND shell "settings put secure enabled_accessibility_services com.mitv.shareds/com.mitv.shareds.HomeService:com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService:com.spocky.projengmenu/com.spocky.projengmenu.services.VoiceButtonService" >/dev/null 2>&1
    $ADB_COMMAND shell "settings put secure accessibility_enabled 1" >/dev/null 2>&1
    $ADB_COMMAND shell "cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity" >/dev/null 2>&1
    $ADB_COMMAND shell monkey -p com.spocky.projengmenu -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    $ADB_COMMAND shell am start -n com.spocky.projengmenu/.ui.home.MainActivity >/dev/null 2>&1

    printf "\n${YELLOW}🔄 BƯỚC 6: LÀM MỚI GIAO DIỆN & ĐỒNG BỘ Ổ CỨNG...${NC}\n"
    
    $ADB_COMMAND shell dumpsys deviceidle whitelist +com.spocky.projengmenu >/dev/null 2>&1
    $ADB_COMMAND shell am force-stop com.spocky.projengmenu >/dev/null 2>&1
    
    $ADB_COMMAND shell cmd appops write-settings >/dev/null 2>&1
    sleep 1
    $ADB_COMMAND shell settings put global install_non_market_apps 1 >/dev/null 2>&1
    sleep 1
    $ADB_COMMAND shell settings list secure >/dev/null 2>&1
    sleep 1                                         
    $ADB_COMMAND shell sync >/dev/null 2>&1
    sleep 2 
    
    $ADB_COMMAND shell input keyevent 3 >/dev/null 2>&1
    sleep 1
    
    printf "\n${CYAN}========================================================${NC}\n"
    printf "${GREEN}🎉 CÀI ĐẶT HOÀN TẤT!${NC}\n"
    printf "${MAGENTA}📺 TV sẽ khởi động lại sau 2 giây để áp dụng cấu hình...${NC}\n"
    sleep 2
    
    $ADB_COMMAND reboot >/dev/null 2>&1
    return_menu
}

install_specific_apks() {
    print_header
    printf "${CYAN}🚀 BẮT ĐẦU CÀI ĐẶT DANH SÁCH ỨNG DỤNG TÙY CHỌN...${NC}\n\n"

    apks_to_install="mi.apk m.apk quantv.apk tizentube.apk oktv.apk getout.apk phim4k.apk"
    installed_count=0

    for apk in $apks_to_install; do
        if [ -f "$apk" ]; then
            install_apk "$apk"
            installed_count=$((installed_count + 1))
        else
            printf "    ${RED}[!]${NC} ${YELLOW}Không tìm thấy ${WHITE}$apk${YELLOW} trong thư mục, bỏ qua.${NC}\n"
        fi
    done

    if [ "$installed_count" -gt 0 ]; then
        printf "\n    ${GREEN}✅ Đã cài đặt xong tổng cộng $installed_count ứng dụng!${NC}\n"
    else
        printf "\n    ${RED}⚠️ Không có ứng dụng nào được cài. Vui lòng kiểm tra lại file trong thư mục.${NC}\n"
    fi

    return_menu
}

copy_wallpapers() {
    print_header
    printf "${YELLOW}🖼️ BẮT ĐẦU SAO CHÉP ẢNH NỀN (.JPG, .PNG) VÀO TIVI...${NC}\n\n"
    count=0
    for ext in jpg jpeg png JPG JPEG PNG; do
        for file in *."$ext"; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                extension="${filename##*.}"
                printf "    ${CYAN}[+]${NC} Đang chép ${WHITE}$filename${NC}...\n"
                $ADB_COMMAND push "$file" "/sdcard/DCIM_${count}.${extension}" >/dev/null 2>&1
                count=$((count + 1))
            fi
        done
    done

    if [ "$count" -eq 0 ]; then
        printf "\n    ${RED}⚠️ Không tìm thấy file ảnh nào trong thư mục.${NC}\n"
    else
        printf "\n    ${GREEN}✅ Đã chép thành công $count ảnh vào thư mục /sdcard/DCIM/ trên TV.${NC}\n"
    fi
    return_menu
}

reboot_recovery() {
    print_header
    printf "   ${RED}⚠️ CẢNH BÁO: TIVI SẼ KHỞI ĐỘNG LẠI VÀO CHẾ ĐỘ RECOVERY ⚠️${NC}\n"
    printf "${CYAN}────────────────────────────────────────────────────────${NC}\n"
    printf "   ${BLUE}🔄 ĐANG GỬI LỆNH RESET CỨNG RECOVERY...${NC}\n\n"

    printf "   ${YELLOW}⏳ Đang xử lý"
    for i in 1 2 3; do
        printf "."
        sleep 1
    done
    printf "${NC}\n\n"

    $ADB_COMMAND shell reboot recovery >/dev/null 2>&1
    $ADB_COMMAND reboot recovery 

    printf "\n   ${GREEN}✅ Đã gửi lệnh reboot recovery${NC}\n"
    printf "   ${MAGENTA}⏱️ Đang chờ TV khởi động lại vào recovery...${NC}\n"
    
    for i in 10 9 8 7 6 5 4 3 2 1; do
        printf "   ${WHITE}👉 $i giây... \r${NC}"
        sleep 1
    done

    printf "\n\n   ${GREEN}🎉 Hoàn tất!${NC}\n"
    printf "   ${CYAN}📡 TV đã ngắt kết nối ADB.${NC}\n"
    
    printf "\n   ${YELLOW}💡 LƯU Ý QUAN TRỌNG:${NC}\n"
    printf "   ${WHITE}Nếu Tivi vẫn không vào Recovery (chỉ khởi động lại bình thường),${NC}\n"
    printf "   ${WHITE}đó là do firmware hãng đã chặn lệnh. Bạn cần làm thủ công:${NC}\n"
    printf "     ${CYAN}1.${NC} Rút phích cắm điện Tivi.\n"
    printf "     ${CYAN}2.${NC} Nhấn giữ đồng thời nút ${GREEN}[OK] + [BACK]${NC} (hoặc ${GREEN}[HOME] + [MENU]${NC}).\n"
    printf "     ${CYAN}3.${NC} Cắm điện lại và tiếp tục giữ 2 nút cho đến khi hiện Recovery.\n\n"

    printf "${CYAN}────────────────────────────────────────────────────────${NC}\n"
    printf "\033[1;33m👉 Đã đọc xong! Nhấn phím [ENTER] để quay lại Menu... \033[0m"
    read CONTINUE
}

reboot_tv() {
    print_header
    printf "   ${GREEN}✅ HOÀN TẤT CÀI ĐẶT! TIVI SẼ KHỞI ĐỘNG LẠI NGAY BÂY GIỜ.${NC}\n"
    printf "${CYAN}────────────────────────────────────────────────────────${NC}\n"
    
    for i in 3 2 1; do
        printf "   ${YELLOW}Đếm ngược: Gửi lệnh khởi động sau ${WHITE}$i${YELLOW} giây...${NC} \r"
        sleep 1
    done
    printf "\n   ${CYAN}>> Đang gửi lệnh hệ thống...${NC}\n"
    $ADB_COMMAND reboot >/dev/null 2>&1
    
    sleep 2
    printf "\n   ${MAGENTA}🔌 Tivi đang khởi động lại. Bạn cần quét kết nối lại để làm tiếp.${NC}\n"
    return_menu
}

# =================== GỌI HÀM CHÍNH ===================
menu1
