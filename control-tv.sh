#!/usr/bin/env bash
# ╭──────────────────────────────────────────────────────────────╮
# │  Control TV via linux — Android TV manager over ADB          │
# │  Author:  Eduard Nagaev                                      │
# │  License: MIT                                                │
# ╰──────────────────────────────────────────────────────────────╯
# Requires: bash 4.3+, adb (sudo apt install adb). Optional: unzip, xdg-open.
# Run:      chmod +x control-tv.sh && ./control-tv.sh
#
# MIT License
#
# Copyright (c) 2026 Eduard Nagaev
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

APP_TITLE="Control TV via linux"
VERSION="1.1"
AUTHOR="Eduard Nagaev"
LICENSE_NAME="MIT"

CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/control-tv"
CONF="$CONF_DIR/config"
HIST="$CONF_DIR/history"
APK_DIR="$HOME/Desktop"
SCAN_PORTS="5555"
UI_LANG=""
AERIAL_PORT="8790"

# ════════════════════════ Translations ════════════════════════
declare -A T
set_lang() {
  T=()
  case "$1" in
  ru) T=(
    [subtitle]="Поиск, подключение и установка приложений" [by]="Автор: Eduard Nagaev  •  Лицензия MIT"
    [no_nets]="Не найдено локальных сетей для поиска" [scan_title]="Поиск в сети %s  (ADB-порты: %s)" [scan_lbl]="Поиск"
    [scan_extra]="%s/%s адресов  •  в сети: %s  •  с ADB: %s" [connecting]="Подключение по ADB к %s адресам… (если на ТВ появится окно — разрешите)"
    [yes]="✔ есть" [no]="✖ нет"
    [net_title]="Устройства в сети по IP: %s с серверами управления  (других устройств: %s)" [net_none]="ТВ с открытыми сервисами не найдены. Нажмите s, чтобы повторить поиск."
    [col_ip]="IP-адрес" [col_host]="Имя в сети" [col_adb]="ADB" [col_cast]="Cast" [col_rc]="Пульт" [col_aerial]="Aerial" [col_ctrl]="Управление через программу"
    [net_adb_off]="ADB выключен — включите «Отладку» на ТВ" [net_adb_auth]="есть сервер ADB — подтвердите на ТВ"
    [net_connected]="✔ подключено — это ТВ №%s" [net_confirm]="⚠ подтвердите на ТВ (№%s)"
    [net_legend]="ADB — управление программой (порт %s) • Cast — трансляция (8009) • Пульт — Android TV Remote (6466) • Aerial — веб-панель (%s)"
    [st_ready]="✔ готов" [st_unauth]="⚠ подтвердите на ТВ" [st_offline]="✖ нет связи"
    [dev_title]="Подключены по ADB (можно управлять): %s   (Android TV: %s)" [dev_none]="Устройства не найдены."
    [dev_hint]="Проверьте: на ТВ включена «Отладка по USB / по сети», ТВ и ПК в одной сети."
    [col_no]="№" [col_name]="Название" [col_model]="Модель" [col_android]="Android" [col_port]="Порт" [col_conn]="Связь" [col_state]="Состояние"
    [conn_net]="Сеть" [conn_usb]="USB" [conn_wifi]="Wi-Fi" [unknown]="неизвестно"
    [ports_title]="Стандартные порты ADB" [port_5555]="ADB по сети — стандартный порт почти всех Android TV"
    [port_extra]="Дополнительные ADB-порты (редко: приставки, эмуляторы)" [port_wireless]="«Беспроводная отладка» Android 11+ — порт показан на экране ТВ"
    [ip_prompt]="IP-адрес ТВ (например 192.168.0.100): " [bad_ip]="Неверный IP-адрес" [port_prompt]="Порт [Enter = %s]: " [bad_port]="Неверный порт"
    [connecting_to]="Подключение к %s … (если на ТВ появится окно — разрешите отладку)" [no_answer]="Нет ответа"
    [pair_hint_after]="Для Android 11+ с «Беспроводной отладкой» сначала выполните сопряжение (пункт p)."
    [pair_title]="Сопряжение (Беспроводная отладка, Android 11+)" [pair_info]="На ТВ: Для разработчиков → Беспроводная отладка → «Подключить по коду»."
    [pair_hp]="IP:ПОРТ из окна сопряжения (например 192.168.0.100:37123): " [pair_code]="Код сопряжения (6 цифр): "
    [pair_done]="Теперь подключитесь (пункт m) по IP:ПОРТ с экрана «Беспроводная отладка» (не из окна кода)."
    [card_connected]="Подключено: %s  •  %s" [lbl_ip]="IP:" [lbl_port]="Порт:" [lbl_cpu]="CPU:" [lbl_folder]="Папка APK:"
    [sel_examples]="Выбор: 2  •  1 3 5  •  1-4  •  a — все  •  Backspace — назад" [what_install]="Что установить: " [nothing_sel]="Ничего не выбрано"
    [xfer]="Передача" [inst]="Установка" [done]="Готово" [total]="Всего" [xfer_fail]="Не удалось передать файл на ТВ"
    [need_unzip]="Для %s нужен unzip:  sudo apt install unzip" [no_apk_in_zip]="Внутри архива нет APK" [bundle_inst]="Установка пакета из %s частей…"
    [e_abi]="APK для другого процессора. Нужна версия под %s (или universal)." [e_sdk]="Приложение требует более новый Android, чем на этом ТВ."
    [e_sig]="Подпись отличается от установленной версии — удалите старую (меню «Приложения») и повторите." [e_down]="На ТВ уже стоит более новая версия."
    [e_space]="Мало места на ТВ — удалите ненужные приложения." [e_parse]="Файл повреждён или это не APK — скачайте заново."
    [inst_title]="Установка: %s файл(ов) → %s" [summary]="Итог: %s успешно, %s с ошибкой  •  общее время %s"
    [folder_missing]="Папка не найдена: %s" [folder_change_hint]="Смените её в меню «Папка APK»." [no_apks]="В папке %s нет файлов .apk/.apks/.apkm/.xapk"
    [apk_list_title]="APK в папке %s  (сначала новые)" [folder_title]="Папка с APK  (сейчас: %s)"
    [f_desktop]="Рабочий стол" [f_own]="Отдельная папка" [f_own_note]="(создать, если нет)" [f_dl]="Загрузки" [f_custom]="Указать свой путь"
    [choice]="Выбор: " [folder_ready]="Папка готова: %s — складывайте туда APK" [path_prompt]="Путь к папке: " [folder_set]="Папка APK: %s" [folder_nx]="Папка не существует: %s"
    [launch_ok]="Открыто на ТВ: %s" [launch_no]="У этого приложения нет экрана для запуска (это фоновая служба)"
    [app_pkg]="Пакет:" [app_ver]="Версия:" [app_type]="Тип:" [app_state]="Состояние:" [t_sys]="системное" [t_user]="стороннее" [s_disabled]="отключено" [s_enabled]="включено"
    [a_open]="▶ Открыть на ТВ" [a_stop]="■ Остановить (закрыть)" [a_enable]="Включить" [a_disable]="Отключить" [a_disable_note]="(можно включить обратно)"
    [a_uninst_user]="Удалить для пользователя" [a_uninst_note]="(вернуть можно в меню «Сервисы Google» или install-existing)" [a_uninst]="Удалить" [stopped]="Остановлено"
    [warn_sys_disable]="Отключение системного приложения может сломать функции ТВ (пульт, HDMI, звук)."
    [q_disable]="Отключить %s? [y/N]: " [q_uninstall]="Удалить %s? [y/N]: " [q_uninst_user]="Удалить %s для пользователя? [y/N]: "
    [warn_sys_uninst]="Удаление системного приложения может сломать функции ТВ. Вернуть: adb shell cmd package install-existing %s"
    [apps_user]="Сторонние приложения" [apps_sys]="Системные приложения" [search_lbl]="поиск" [nothing_found]="Ничего не найдено"
    [apps_hint]="номер — открыть / действия  •  s — %s  •  /текст — поиск  •  / — сбросить  •  Backspace — назад"
    [show_sys]="показать системные" [show_user]="показать сторонние" [bad_input]="Неверный ввод"
    [launcher_title]="Главный экран (лаунчер)" [fallback]="(запасной системный)" [current_home]="● сейчас главный"
    [launcher_prompt]="Номер лаунчера, который сделать главным: " [bad_num]="Неверный номер" [home_ok]="Главный экран: %s" [home_fail]="Не удалось назначить. Сейчас: %s"
    [info_title]="Сведения об устройстве" [i_maker]="Производитель" [i_model]="Модель" [i_android]="Android" [i_build]="Сборка" [i_platform]="Платформа"
    [i_screen]="Экран" [i_mem]="Память" [i_storage]="Хранилище" [i_uptime]="Работает" [i_launcher]="Лаунчер" [i_apps]="Приложений"
    [i_patch]="патч" [i_mem_fmt]="свободно %s МБ из %s МБ" [i_storage_fmt]="свободно %s из %s" [i_apps_fmt]="сторонних %s, отключённых %s, всего %s"
    [lost]="Связь с %s потеряна" [menu_title]="Меню"
    [m1]="Установить APK — выбрать из папки" [m2]="Установить ВСЕ APK из папки за один раз" [m3]="Папка APK (рабочий стол / своя папка)"
    [m4]="Приложения: открыть, версии, удалить (+ системные)" [m5]="Сервисы Google: найти, удалить выборочно или вернуть" [m6]="Главный экран (лаунчер)"
    [m7]="Сведения об устройстве" [m8]="Веб-панель Aerial (порт %s)" [m9]="Перезагрузить ТВ" [back_hint]="Backspace — назад" [quit]="Выход"
    [q_reboot]="Перезагрузить %s? [y/N]: " [rebooting]="ТВ перезагружается" [actions]="Действия"
    [a_pick]="выбрать ТВ по номеру" [a_scan]="повторить поиск в сети" [a_manual]="подключить вручную (IP + порт)" [a_pair]="сопряжение Android 11+"
    [a_disc]="отключить все сетевые ТВ" [a_refresh]="обновить список" [a_ports]="порты поиска (сейчас: %s)" [a_web]="веб-панель Aerial (IP + порт)"
    [a_lang]="язык / language / idioma" [a_about]="о программе"
    [disc_done]="Все сетевые подключения закрыты" [ports_prompt]="Порты через пробел [Enter = 5555]: "
    [need_confirm]="Подтвердите на экране ТВ «Разрешить отладку» (отметьте «Всегда») и нажмите r." [unavailable]="Устройство недоступно (%s). Повторите поиск (s)."
    [adb_missing]="adb не найден. Установите его командой:" [press_key]="Нажмите любую клавишу…"
    [web_title]="Веб-панель Aerial" [web_found]="Найдены ТВ с веб-панелью Aerial:" [web_none]="Панель Aerial автоматически не найдена — введите IP вручную."
    [web_prompt]="Номер из списка или IP-адрес ТВ: " [web_port]="Порт [Enter = %s]: " [web_opening]="Открываю %s в браузере…"
    [web_note]="Если страница попросит код или адрес — используйте адрес, который показывает Aerial на экране ТВ."
    [web_noopen]="Не удалось открыть браузер. Откройте адрес вручную: %s" [web_closed]="Порт %s на %s закрыт — Aerial не запущен или не установлен."
    [about_title]="О программе" [about_desc]="Управление Android TV по ADB из Linux: поиск ТВ в сети, установка APK, приложения, лаунчер, сервисы Google."
    [lang_title]="Язык / Language / Idioma" [lang_saved]="Язык: русский"
    [g_title]="Сервисы Google на %s" [g_restore_title]="Удалённые сервисы Google — можно вернуть"
    [g_col_name]="Название" [g_col_pkg]="Пакет" [g_col_risk]="Риск" [g_col_state]="Состояние"
    [r_safe]="✔ безопасно" [r_caution]="⚠ осторожно" [r_critical]="⛔ не трогать"
    [g_installed]="установлен" [g_disabled]="отключён" [g_removed]="удалён"
    [g_summary]="Найдено: %s  •  безопасно удалить: %s  •  осторожно: %s  •  не трогать: %s"
    [g_hint]="Выбор: 3  •  1 4 7  •  1-7  •  a — все безопасные  •  r — вернуть удалённые  •  Backspace — назад"
    [g_hint_restore]="Выбор: 2  •  1-5  •  a — вернуть все  •  r — к списку установленных  •  Backspace — назад"
    [g_none]="Сервисы Google не найдены" [g_none_removed]="Удалённых сервисов Google нет — возвращать нечего"
    [g_confirm_rm]="Будут удалены (%s):" [g_confirm_rs]="Будут возвращены (%s):" [g_q]="Продолжить? [y/N]: "
    [g_crit_warn]="Среди выбранных есть критичные пакеты (⛔). Без них может пропасть пульт, клавиатура или ТВ не загрузится."
    [g_crit_q]="Точно удалить и их? Напишите YES: " [g_crit_skip]="Критичные пакеты пропущены"
    [g_home_skip]="%s — это текущий главный экран, пропускаю (сначала выберите другой лаунчер)"
    [g_rm_lbl]="Удаление" [g_rs_lbl]="Возврат" [g_result]="Итог: %s успешно, %s с ошибкой" [g_reboot_hint]="Рекомендуется перезагрузить ТВ (пункт 9)."
  ) ;;
  es) T=(
    [subtitle]="Buscar, conectar e instalar aplicaciones" [by]="Autor: Eduard Nagaev  •  Licencia MIT"
    [no_nets]="No se encontraron redes locales para buscar" [scan_title]="Buscando en la red %s  (puertos ADB: %s)" [scan_lbl]="Búsqueda"
    [scan_extra]="%s/%s direcciones  •  en línea: %s  •  con ADB: %s" [connecting]="Conectando por ADB a %s direcciones… (si el TV muestra una ventana, permítala)"
    [yes]="✔ sí" [no]="✖ no"
    [net_title]="Dispositivos en la red por IP: %s con servidores de control  (otros dispositivos: %s)" [net_none]="No se encontraron TV con servicios abiertos. Pulse s para buscar de nuevo."
    [col_ip]="Dirección IP" [col_host]="Nombre en red" [col_adb]="ADB" [col_cast]="Cast" [col_rc]="Control" [col_aerial]="Aerial" [col_ctrl]="Control con este programa"
    [net_adb_off]="ADB apagado — active la «Depuración» en el TV" [net_adb_auth]="hay servidor ADB — confirme en el TV"
    [net_connected]="✔ conectado — es el TV n.º %s" [net_confirm]="⚠ confirme en el TV (n.º %s)"
    [net_legend]="ADB — control con el programa (puerto %s) • Cast — transmisión (8009) • Control — Android TV Remote (6466) • Aerial — panel web (%s)"
    [st_ready]="✔ listo" [st_unauth]="⚠ confirme en el TV" [st_offline]="✖ sin conexión"
    [dev_title]="Conectados por ADB (se pueden controlar): %s   (Android TV: %s)" [dev_none]="No se encontraron dispositivos."
    [dev_hint]="Compruebe: «Depuración USB / por red» activada en el TV, y TV y PC en la misma red."
    [col_no]="N.º" [col_name]="Nombre" [col_model]="Modelo" [col_android]="Android" [col_port]="Puerto" [col_conn]="Enlace" [col_state]="Estado"
    [conn_net]="Red" [conn_usb]="USB" [conn_wifi]="Wi-Fi" [unknown]="desconocido"
    [ports_title]="Puertos ADB estándar" [port_5555]="ADB por red — puerto estándar de casi todos los Android TV"
    [port_extra]="Puertos ADB adicionales (raro: cajas, emuladores)" [port_wireless]="«Depuración inalámbrica» Android 11+ — el puerto aparece en el TV"
    [ip_prompt]="Dirección IP del TV (p. ej. 192.168.0.100): " [bad_ip]="Dirección IP no válida" [port_prompt]="Puerto [Enter = %s]: " [bad_port]="Puerto no válido"
    [connecting_to]="Conectando a %s … (si el TV muestra una ventana, permita la depuración)" [no_answer]="Sin respuesta"
    [pair_hint_after]="Para Android 11+ con «Depuración inalámbrica», vincule primero (opción p)."
    [pair_title]="Vinculación (Depuración inalámbrica, Android 11+)" [pair_info]="En el TV: Opciones para desarrolladores → Depuración inalámbrica → «Vincular con código»."
    [pair_hp]="IP:PUERTO de la ventana de vinculación (p. ej. 192.168.0.100:37123): " [pair_code]="Código de vinculación (6 dígitos): "
    [pair_done]="Ahora conéctese (opción m) con la IP:PUERTO de la pantalla «Depuración inalámbrica» (no la del código)."
    [card_connected]="Conectado: %s  •  %s" [lbl_ip]="IP:" [lbl_port]="Puerto:" [lbl_cpu]="CPU:" [lbl_folder]="Carpeta APK:"
    [sel_examples]="Elegir: 2  •  1 3 5  •  1-4  •  a — todos  •  Backspace — atrás" [what_install]="Qué instalar: " [nothing_sel]="No se eligió nada"
    [xfer]="Enviando" [inst]="Instalando" [done]="Listo" [total]="Total" [xfer_fail]="No se pudo enviar el archivo al TV"
    [need_unzip]="%s necesita unzip:  sudo apt install unzip" [no_apk_in_zip]="No hay APK dentro del archivo" [bundle_inst]="Instalando paquete de %s partes…"
    [e_abi]="APK para otro procesador. Necesita la versión para %s (o universal)." [e_sdk]="La app requiere un Android más nuevo que el de este TV."
    [e_sig]="La firma no coincide con la versión instalada — desinstale la anterior (menú «Aplicaciones») y repita." [e_down]="En el TV ya hay una versión más nueva."
    [e_space]="Poco espacio en el TV — elimine apps innecesarias." [e_parse]="El archivo está dañado o no es un APK — descárguelo de nuevo."
    [inst_title]="Instalación: %s archivo(s) → %s" [summary]="Resultado: %s correctos, %s con error  •  tiempo total %s"
    [folder_missing]="Carpeta no encontrada: %s" [folder_change_hint]="Cámbiela en el menú «Carpeta APK»." [no_apks]="No hay archivos .apk/.apks/.apkm/.xapk en %s"
    [apk_list_title]="APK en %s  (más recientes primero)" [folder_title]="Carpeta de APK  (actual: %s)"
    [f_desktop]="Escritorio" [f_own]="Carpeta propia" [f_own_note]="(se crea si no existe)" [f_dl]="Descargas" [f_custom]="Indicar otra ruta"
    [choice]="Opción: " [folder_ready]="Carpeta lista: %s — ponga ahí los APK" [path_prompt]="Ruta de la carpeta: " [folder_set]="Carpeta APK: %s" [folder_nx]="La carpeta no existe: %s"
    [launch_ok]="Abierto en el TV: %s" [launch_no]="Esta app no tiene pantalla para abrir (es un servicio en segundo plano)"
    [app_pkg]="Paquete:" [app_ver]="Versión:" [app_type]="Tipo:" [app_state]="Estado:" [t_sys]="del sistema" [t_user]="de terceros" [s_disabled]="desactivada" [s_enabled]="activada"
    [a_open]="▶ Abrir en el TV" [a_stop]="■ Detener (cerrar)" [a_enable]="Activar" [a_disable]="Desactivar" [a_disable_note]="(se puede volver a activar)"
    [a_uninst_user]="Desinstalar para el usuario" [a_uninst_note]="(se recupera en «Servicios de Google» o con install-existing)" [a_uninst]="Desinstalar" [stopped]="Detenida"
    [warn_sys_disable]="Desactivar una app del sistema puede romper funciones del TV (control, HDMI, sonido)."
    [q_disable]="¿Desactivar %s? [y/N]: " [q_uninstall]="¿Desinstalar %s? [y/N]: " [q_uninst_user]="¿Desinstalar %s para el usuario? [y/N]: "
    [warn_sys_uninst]="Quitar una app del sistema puede romper funciones del TV. Recuperar: adb shell cmd package install-existing %s"
    [apps_user]="Apps de terceros" [apps_sys]="Apps del sistema" [search_lbl]="búsqueda" [nothing_found]="No se encontró nada"
    [apps_hint]="número — abrir / acciones  •  s — %s  •  /texto — buscar  •  / — limpiar  •  Backspace — atrás"
    [show_sys]="ver las del sistema" [show_user]="ver las de terceros" [bad_input]="Entrada no válida"
    [launcher_title]="Pantalla de inicio (launcher)" [fallback]="(respaldo del sistema)" [current_home]="● inicio actual"
    [launcher_prompt]="Número del launcher a usar como inicio: " [bad_num]="Número no válido" [home_ok]="Pantalla de inicio: %s" [home_fail]="No se pudo asignar. Actual: %s"
    [info_title]="Información del dispositivo" [i_maker]="Fabricante" [i_model]="Modelo" [i_android]="Android" [i_build]="Compilación" [i_platform]="Plataforma"
    [i_screen]="Pantalla" [i_mem]="Memoria" [i_storage]="Almacenamiento" [i_uptime]="Encendido" [i_launcher]="Launcher" [i_apps]="Aplicaciones"
    [i_patch]="parche" [i_mem_fmt]="%s MB libres de %s MB" [i_storage_fmt]="%s libres de %s" [i_apps_fmt]="de terceros %s, desactivadas %s, total %s"
    [lost]="Se perdió la conexión con %s" [menu_title]="Menú"
    [m1]="Instalar APK — elegir de la carpeta" [m2]="Instalar TODOS los APK de la carpeta" [m3]="Carpeta APK (escritorio / propia)"
    [m4]="Aplicaciones: abrir, versiones, desinstalar (+ sistema)" [m5]="Servicios de Google: buscar, quitar o recuperar" [m6]="Pantalla de inicio (launcher)"
    [m7]="Información del dispositivo" [m8]="Panel web de Aerial (puerto %s)" [m9]="Reiniciar el TV" [back_hint]="Backspace — atrás" [quit]="Salir"
    [q_reboot]="¿Reiniciar %s? [y/N]: " [rebooting]="El TV se está reiniciando" [actions]="Acciones"
    [a_pick]="elegir TV por número" [a_scan]="buscar en la red de nuevo" [a_manual]="conectar manualmente (IP + puerto)" [a_pair]="vincular Android 11+"
    [a_disc]="desconectar todos los TV de red" [a_refresh]="actualizar la lista" [a_ports]="puertos de búsqueda (ahora: %s)" [a_web]="panel web de Aerial (IP + puerto)"
    [a_lang]="idioma / language / язык" [a_about]="acerca de"
    [disc_done]="Se cerraron todas las conexiones de red" [ports_prompt]="Puertos separados por espacios [Enter = 5555]: "
    [need_confirm]="Confirme en el TV «Permitir depuración» (marque «Siempre») y pulse r." [unavailable]="Dispositivo no disponible (%s). Busque de nuevo (s)."
    [adb_missing]="No se encontró adb. Instálelo con:" [press_key]="Pulse cualquier tecla…"
    [web_title]="Panel web de Aerial" [web_found]="TV con panel web de Aerial encontrados:" [web_none]="No se encontró el panel de Aerial — escriba la IP manualmente."
    [web_prompt]="Número de la lista o IP del TV: " [web_port]="Puerto [Enter = %s]: " [web_opening]="Abriendo %s en el navegador…"
    [web_note]="Si la página pide un código o dirección, use la dirección que muestra Aerial en el TV."
    [web_noopen]="No se pudo abrir el navegador. Abra la dirección manualmente: %s" [web_closed]="El puerto %s en %s está cerrado — Aerial no está abierto o no está instalado."
    [about_title]="Acerca de" [about_desc]="Control de Android TV por ADB desde Linux: búsqueda en la red, instalación de APK, apps, launcher, servicios de Google."
    [lang_title]="Idioma / Language / Язык" [lang_saved]="Idioma: español"
    [g_title]="Servicios de Google en %s" [g_restore_title]="Servicios de Google eliminados — se pueden recuperar"
    [g_col_name]="Nombre" [g_col_pkg]="Paquete" [g_col_risk]="Riesgo" [g_col_state]="Estado"
    [r_safe]="✔ seguro" [r_caution]="⚠ cuidado" [r_critical]="⛔ no tocar"
    [g_installed]="instalado" [g_disabled]="desactivado" [g_removed]="eliminado"
    [g_summary]="Encontrados: %s  •  seguros de quitar: %s  •  con cuidado: %s  •  no tocar: %s"
    [g_hint]="Elegir: 3  •  1 4 7  •  1-7  •  a — todos los seguros  •  r — recuperar eliminados  •  Backspace — atrás"
    [g_hint_restore]="Elegir: 2  •  1-5  •  a — recuperar todos  •  r — volver a instalados  •  Backspace — atrás"
    [g_none]="No se encontraron servicios de Google" [g_none_removed]="No hay servicios de Google eliminados — nada que recuperar"
    [g_confirm_rm]="Se eliminarán (%s):" [g_confirm_rs]="Se recuperarán (%s):" [g_q]="¿Continuar? [y/N]: "
    [g_crit_warn]="Hay paquetes críticos (⛔) en la selección. Sin ellos puede fallar el control, el teclado o el arranque del TV."
    [g_crit_q]="¿Eliminarlos también? Escriba YES: " [g_crit_skip]="Paquetes críticos omitidos"
    [g_home_skip]="%s es la pantalla de inicio actual, se omite (elija antes otro launcher)"
    [g_rm_lbl]="Quitando" [g_rs_lbl]="Recuperando" [g_result]="Resultado: %s correctos, %s con error" [g_reboot_hint]="Se recomienda reiniciar el TV (opción 9)."
  ) ;;
  *) T=(
    [subtitle]="Find, connect and install apps" [by]="Author: Eduard Nagaev  •  MIT License"
    [no_nets]="No local networks found to scan" [scan_title]="Scanning network %s  (ADB ports: %s)" [scan_lbl]="Scan"
    [scan_extra]="%s/%s addresses  •  online: %s  •  with ADB: %s" [connecting]="Connecting via ADB to %s addresses… (allow it if the TV shows a prompt)"
    [yes]="✔ yes" [no]="✖ no"
    [net_title]="Devices on the network by IP: %s with control servers  (other devices: %s)" [net_none]="No TVs with open services found. Press s to scan again."
    [col_ip]="IP address" [col_host]="Network name" [col_adb]="ADB" [col_cast]="Cast" [col_rc]="Remote" [col_aerial]="Aerial" [col_ctrl]="Control via this program"
    [net_adb_off]="ADB off — enable “Debugging” on the TV" [net_adb_auth]="ADB server found — confirm on the TV"
    [net_connected]="✔ connected — this is TV #%s" [net_confirm]="⚠ confirm on the TV (#%s)"
    [net_legend]="ADB — control by this program (port %s) • Cast — casting (8009) • Remote — Android TV Remote (6466) • Aerial — web panel (%s)"
    [st_ready]="✔ ready" [st_unauth]="⚠ confirm on TV" [st_offline]="✖ offline"
    [dev_title]="Connected via ADB (controllable): %s   (Android TV: %s)" [dev_none]="No devices found."
    [dev_hint]="Check: “USB / network debugging” is on, and the TV and PC are on the same network."
    [col_no]="#" [col_name]="Name" [col_model]="Model" [col_android]="Android" [col_port]="Port" [col_conn]="Link" [col_state]="State"
    [conn_net]="LAN" [conn_usb]="USB" [conn_wifi]="Wi-Fi" [unknown]="unknown"
    [ports_title]="Standard ADB ports" [port_5555]="ADB over network — the standard port on almost every Android TV"
    [port_extra]="Extra ADB ports (rare: boxes, emulators)" [port_wireless]="“Wireless debugging” Android 11+ — the port is shown on the TV"
    [ip_prompt]="TV IP address (e.g. 192.168.0.100): " [bad_ip]="Invalid IP address" [port_prompt]="Port [Enter = %s]: " [bad_port]="Invalid port"
    [connecting_to]="Connecting to %s … (allow debugging if the TV shows a prompt)" [no_answer]="No response"
    [pair_hint_after]="For Android 11+ with “Wireless debugging”, pair first (option p)."
    [pair_title]="Pairing (Wireless debugging, Android 11+)" [pair_info]="On the TV: Developer options → Wireless debugging → “Pair with code”."
    [pair_hp]="IP:PORT from the pairing window (e.g. 192.168.0.100:37123): " [pair_code]="Pairing code (6 digits): "
    [pair_done]="Now connect (option m) using the IP:PORT on the “Wireless debugging” screen (not the code window)."
    [card_connected]="Connected: %s  •  %s" [lbl_ip]="IP:" [lbl_port]="Port:" [lbl_cpu]="CPU:" [lbl_folder]="APK folder:"
    [sel_examples]="Select: 2  •  1 3 5  •  1-4  •  a — all  •  Backspace — back" [what_install]="What to install: " [nothing_sel]="Nothing selected"
    [xfer]="Sending" [inst]="Installing" [done]="Done" [total]="Total" [xfer_fail]="Could not send the file to the TV"
    [need_unzip]="%s needs unzip:  sudo apt install unzip" [no_apk_in_zip]="No APK inside the archive" [bundle_inst]="Installing a package of %s parts…"
    [e_abi]="APK for a different CPU. You need a build for %s (or universal)." [e_sdk]="The app needs a newer Android than this TV has."
    [e_sig]="Signature differs from the installed version — uninstall the old one (Apps menu) and retry." [e_down]="A newer version is already installed on the TV."
    [e_space]="Not enough storage on the TV — remove unused apps." [e_parse]="The file is damaged or not an APK — download it again."
    [inst_title]="Installing: %s file(s) → %s" [summary]="Result: %s succeeded, %s failed  •  total time %s"
    [folder_missing]="Folder not found: %s" [folder_change_hint]="Change it in the “APK folder” menu." [no_apks]="No .apk/.apks/.apkm/.xapk files in %s"
    [apk_list_title]="APKs in %s  (newest first)" [folder_title]="APK folder  (current: %s)"
    [f_desktop]="Desktop" [f_own]="Separate folder" [f_own_note]="(created if missing)" [f_dl]="Downloads" [f_custom]="Custom path"
    [choice]="Choice: " [folder_ready]="Folder ready: %s — put your APKs there" [path_prompt]="Folder path: " [folder_set]="APK folder: %s" [folder_nx]="Folder does not exist: %s"
    [launch_ok]="Opened on TV: %s" [launch_no]="This app has no screen to open (it is a background service)"
    [app_pkg]="Package:" [app_ver]="Version:" [app_type]="Type:" [app_state]="State:" [t_sys]="system" [t_user]="third-party" [s_disabled]="disabled" [s_enabled]="enabled"
    [a_open]="▶ Open on TV" [a_stop]="■ Stop (close)" [a_enable]="Enable" [a_disable]="Disable" [a_disable_note]="(can be re-enabled)"
    [a_uninst_user]="Uninstall for user" [a_uninst_note]="(restore in “Google services” or with install-existing)" [a_uninst]="Uninstall" [stopped]="Stopped"
    [warn_sys_disable]="Disabling a system app may break TV functions (remote, HDMI, sound)."
    [q_disable]="Disable %s? [y/N]: " [q_uninstall]="Uninstall %s? [y/N]: " [q_uninst_user]="Uninstall %s for the user? [y/N]: "
    [warn_sys_uninst]="Removing a system app may break TV functions. Restore: adb shell cmd package install-existing %s"
    [apps_user]="Third-party apps" [apps_sys]="System apps" [search_lbl]="search" [nothing_found]="Nothing found"
    [apps_hint]="number — open / actions  •  s — %s  •  /text — search  •  / — clear  •  Backspace — back"
    [show_sys]="show system" [show_user]="show third-party" [bad_input]="Invalid input"
    [launcher_title]="Home screen (launcher)" [fallback]="(system fallback)" [current_home]="● current home"
    [launcher_prompt]="Number of the launcher to make home: " [bad_num]="Invalid number" [home_ok]="Home screen: %s" [home_fail]="Could not set it. Current: %s"
    [info_title]="Device information" [i_maker]="Manufacturer" [i_model]="Model" [i_android]="Android" [i_build]="Build" [i_platform]="Platform"
    [i_screen]="Screen" [i_mem]="Memory" [i_storage]="Storage" [i_uptime]="Uptime" [i_launcher]="Launcher" [i_apps]="Apps"
    [i_patch]="patch" [i_mem_fmt]="%s MB free of %s MB" [i_storage_fmt]="%s free of %s" [i_apps_fmt]="third-party %s, disabled %s, total %s"
    [lost]="Connection to %s lost" [menu_title]="Menu"
    [m1]="Install APK — choose from folder" [m2]="Install ALL APKs from the folder at once" [m3]="APK folder (Desktop / custom)"
    [m4]="Apps: open, versions, uninstall (+ system)" [m5]="Google services: find, remove selectively or restore" [m6]="Home screen (launcher)"
    [m7]="Device information" [m8]="Aerial web panel (port %s)" [m9]="Restart TV" [back_hint]="Backspace — back" [quit]="Quit"
    [q_reboot]="Restart %s? [y/N]: " [rebooting]="The TV is restarting" [actions]="Actions"
    [a_pick]="select a TV by number" [a_scan]="scan the network again" [a_manual]="connect manually (IP + port)" [a_pair]="pair Android 11+"
    [a_disc]="disconnect all network TVs" [a_refresh]="refresh the list" [a_ports]="scan ports (now: %s)" [a_web]="Aerial web panel (IP + port)"
    [a_lang]="language / idioma / язык" [a_about]="about"
    [disc_done]="All network connections closed" [ports_prompt]="Ports separated by spaces [Enter = 5555]: "
    [need_confirm]="Confirm “Allow debugging” on the TV (tick “Always”) and press r." [unavailable]="Device unavailable (%s). Scan again (s)."
    [adb_missing]="adb not found. Install it with:" [press_key]="Press any key…"
    [web_title]="Aerial web panel" [web_found]="TVs with the Aerial web panel:" [web_none]="No Aerial panel found automatically — enter the IP manually."
    [web_prompt]="Number from the list or TV IP address: " [web_port]="Port [Enter = %s]: " [web_opening]="Opening %s in the browser…"
    [web_note]="If the page asks for a code or address, use the address Aerial shows on the TV."
    [web_noopen]="Could not open a browser. Open this address manually: %s" [web_closed]="Port %s on %s is closed — Aerial is not running or not installed."
    [about_title]="About" [about_desc]="Control Android TV over ADB from Linux: network discovery, APK install, apps, launcher, Google services."
    [lang_title]="Language / Idioma / Язык" [lang_saved]="Language: English"
    [g_title]="Google services on %s" [g_restore_title]="Removed Google services — can be restored"
    [g_col_name]="Name" [g_col_pkg]="Package" [g_col_risk]="Risk" [g_col_state]="State"
    [r_safe]="✔ safe" [r_caution]="⚠ caution" [r_critical]="⛔ keep"
    [g_installed]="installed" [g_disabled]="disabled" [g_removed]="removed"
    [g_summary]="Found: %s  •  safe to remove: %s  •  caution: %s  •  keep: %s"
    [g_hint]="Select: 3  •  1 4 7  •  1-7  •  a — all safe ones  •  r — restore removed  •  Backspace — back"
    [g_hint_restore]="Select: 2  •  1-5  •  a — restore all  •  r — back to installed  •  Backspace — back"
    [g_none]="No Google services found" [g_none_removed]="No removed Google services — nothing to restore"
    [g_confirm_rm]="Will be removed (%s):" [g_confirm_rs]="Will be restored (%s):" [g_q]="Continue? [y/N]: "
    [g_crit_warn]="The selection includes critical packages (⛔). Without them the remote, keyboard or boot may break."
    [g_crit_q]="Remove them too? Type YES: " [g_crit_skip]="Critical packages skipped"
    [g_home_skip]="%s is the current home screen, skipping (choose another launcher first)"
    [g_rm_lbl]="Removing" [g_rs_lbl]="Restoring" [g_result]="Result: %s succeeded, %s failed" [g_reboot_hint]="Restarting the TV is recommended (option 9)."
  ) ;;
  esac
}
tf() { local k="$1"; shift; printf -- "${T[$k]}" "$@"; }

# ════════════════════════ Look & feel ════════════════════════
if [[ -t 1 ]]; then
  R=$'\e[0m'; BOLD=$'\e[1m'; DIM=$'\e[2m'
  RED=$'\e[31m'; GRN=$'\e[32m'; YEL=$'\e[33m'; MAG=$'\e[35m'; CYN=$'\e[36m'; WHT=$'\e[97m'
else
  R=; BOLD=; DIM=; RED=; GRN=; YEL=; MAG=; CYN=; WHT=
fi
export LC_ALL="${LC_ALL:-C.UTF-8}"

cols() { local c; c=$(tput cols 2>/dev/null || echo 80); (( c > 120 )) && c=120; (( c < 60 )) && c=60; echo "$c"; }
rep()  { local s="$1" n="$2" out=""; while (( n-- > 0 )); do out+="$s"; done; printf '%s' "$out"; }
pad()  { local s="$1" w="$2" n; n=${#s}; if (( n > w )); then s="${s:0:w-1}…"; n=$w; fi; printf '%s%*s' "$s" $((w-n)) ''; }
line() { printf '%s%s%s\n' "$DIM" "$(rep '─' "$(cols)")" "$R"; }
cursor_off() { [[ -t 1 ]] && tput civis 2>/dev/null; }
cursor_on()  { [[ -t 1 ]] && tput cnorm 2>/dev/null; }
trap 'cursor_on; echo; exit 130' INT
trap 'cursor_on' EXIT

banner() {
  local w inner; w=$(cols); inner=$((w-2))
  clear 2>/dev/null
  printf '%s╭%s╮%s\n' "$CYN" "$(rep '─' "$inner")" "$R"
  printf '%s│%s %s %s│%s\n' "$CYN" "$R$BOLD$WHT" "$(pad "📺  $APP_TITLE $VERSION" $((inner-3)))" "$R$CYN" "$R"
  printf '%s│%s %s %s│%s\n' "$CYN" "$R$DIM" "$(pad "${1:-${T[subtitle]}}" $((inner-2)))" "$R$CYN" "$R"
  printf '%s╰%s╯%s\n' "$CYN" "$(rep '─' "$inner")" "$R"
}
title() { echo; printf '%s%s▌ %s%s\n' "$BOLD" "$MAG" "$1" "$R"; line; }
ok()    { printf '  %s✔%s %s\n' "$GRN" "$R" "$*"; }
warn()  { printf '  %s⚠%s %s\n' "$YEL" "$R" "$*"; }
err()   { printf '  %s✖%s %s\n' "$RED" "$R" "$*"; }
info()  { printf '  %s•%s %s\n' "$CYN" "$R" "$*"; }
key()   { printf '  %s%s%s %s\n' "$BOLD$YEL" "$(pad "$1" "${3:-3}")" "$R" "$2"; }
fmt_time() { printf '%02d:%02d' $(( $1 / 60 )) $(( $1 % 60 )); }
human() { awk -v b="$1" 'BEGIN{ split("B KB MB GB",u," "); i=1; while (b>=1024 && i<4){b/=1024;i++}; printf (i==1?"%d %s":"%.1f %s"), b, u[i] }'; }
is_yes() { [[ $1 =~ ^[yYsSдД]$ ]]; }

# Line input: Backspace on an empty line = back (returns 1)
ASK_BACK=0
ask() {
  local __v="$1" __p="$2" __empty="${3:-0}" __buf="" __k __rest
  ASK_BACK=0
  printf '\n  %s›%s %s' "$BOLD$CYN" "$R" "$__p"
  while true; do
    IFS= read -rsn1 __k || { echo; exit 0; }
    case "$__k" in
      "")  if [[ -z $__buf && $__empty != 1 ]]; then continue; fi
           echo; printf -v "$__v" '%s' "$__buf"; return 0 ;;
      $'\x7f'|$'\b')
           if [[ -z $__buf ]]; then ASK_BACK=1; printf -v "$__v" '%s' ""; echo; return 1; fi
           __buf=${__buf%?}; printf '\b \b' ;;
      $'\e') IFS= read -rsn2 -t 0.02 __rest; IFS= read -rsn1 -t 0.01 __rest ;;
      *)   [[ $__k == [[:print:]] ]] || continue
           __buf+=$__k; printf '%s' "$__k" ;;
    esac
  done
}
pause() { printf '\n  %s%s%s' "$DIM" "${T[press_key]}" "$R"; IFS= read -rsn1 _ || exit 0; echo; }

# Progress bar: draw_bar <percent> <label> [extra]
draw_bar() {
  local pct=$1 label="$2" extra="${3:-}" w=30 fill col
  (( pct < 0 )) && pct=0; (( pct > 100 )) && pct=100
  fill=$(( pct * w / 100 )); col=$CYN; (( pct == 100 )) && col=$GRN
  printf '\r\e[K  %s%s%s%s%s %3d%%  %s%s%s' "$col" "$(rep '█' "$fill")" "$DIM" "$(rep '░' $((w-fill)))" "$R" "$pct" "$BOLD" "$(pad "$label" 12)" "$R"
  [[ -n $extra ]] && printf '  %s%s%s' "$DIM" "$extra" "$R"
}

# ════════════════════════ Config ════════════════════════
load_conf() {
  mkdir -p "$CONF_DIR"; touch "$HIST"
  # shellcheck disable=SC1090
  [[ -f $CONF ]] && source "$CONF"
}
save_conf() { printf 'APK_DIR=%q\nSCAN_PORTS=%q\nUI_LANG=%q\n' "$APK_DIR" "$SCAN_PORTS" "$UI_LANG" > "$CONF"; }
remember() { grep -qxF "$1" "$HIST" 2>/dev/null || echo "$1" >> "$HIST"; }

choose_lang() {
  set_lang "${UI_LANG:-en}"
  banner "${T[lang_title]}"; title "${T[lang_title]}"
  key 1 "English  ${DIM}(default)${R}"; key 2 "Español"; key 3 "Русский"
  local c; ask c "1 / 2 / 3 [Enter = 1]: " 1
  case "$c" in 2) UI_LANG=es ;; 3) UI_LANG=ru ;; ""|1) UI_LANG=${UI_LANG:-en}; [[ $c == 1 ]] && UI_LANG=en ;; *) UI_LANG=${UI_LANG:-en} ;; esac
  set_lang "$UI_LANG"; save_conf; ok "${T[lang_saved]}"; sleep 0.6
}

need_adb() {
  if ! command -v adb >/dev/null; then err "${T[adb_missing]}"; echo; echo "    sudo apt install adb"; echo; exit 1; fi
  adb start-server >/dev/null 2>&1
}

# ════════════════════════ Network discovery ════════════════════════
local_bases() {
  # override: CTV_BASES="192.168.1 192.168.0" ./control-tv.sh
  [[ -n ${CTV_BASES:-} ]] && { tr ' ' '\n' <<< "$CTV_BASES"; return; }
  ip -o -4 addr show scope global 2>/dev/null \
    | awk '$2 !~ /^(docker|br-|veth|virbr|lxc|tun|tap|wg|zt|tailscale)/ {split($4,a,"/"); print a[1]}' \
    | while read -r a; do echo "${a%.*}"; done | sort -u
}
# 0 = open, 1 = host up / port closed, 124 = no answer
probe() { timeout "${3:-0.7}" bash -c "exec 3<>/dev/tcp/$1/$2" 2>/dev/null; }

NET_IP=(); NET_HOST=(); NET_ADB=(); NET_CAST=(); NET_RC=(); NET_AER=(); NET_OTHER=0

scan_network() {
  local bases ports base i n=0 total wd own
  mapfile -t bases < <(local_bases)
  read -r -a ports <<< "$SCAN_PORTS"
  NET_IP=(); NET_HOST=(); NET_ADB=(); NET_CAST=(); NET_RC=(); NET_AER=(); NET_OTHER=0
  if (( ${#bases[@]} == 0 )); then warn "${T[no_nets]}"; return; fi
  wd=$(mktemp -d); : > "$wd/alive"; : > "$wd/adb"
  own=" $(ip -o -4 addr show 2>/dev/null | awk '{split($4,a,"/"); printf "%s ", a[1]}')"
  total=$(( ${#bases[@]} * 254 ))
  title "$(tf scan_title "${bases[*]/%/.0/24}" "$SCAN_PORTS")"
  cursor_off
  for base in "${bases[@]}"; do
    for i in $(seq 1 254); do
      [[ $own == *" $base.$i "* ]] && { ((n++)); continue; }
      (
        ip="$base.$i" alive=0
        for p in "${ports[@]}"; do
          probe "$ip" "$p"; rc=$?
          if (( rc == 0 )); then echo "$ip:$p" >> "$wd/adb"; alive=1; elif (( rc == 1 )); then alive=1; fi
        done
        (( alive )) && echo "$ip" >> "$wd/alive"
      ) &
      (( ++n % 128 == 0 )) && { wait; draw_bar $(( n * 100 / total )) "${T[scan_lbl]}" "$(tf scan_extra "$n" "$total" "$(wc -l < "$wd/alive")" "$(wc -l < "$wd/adb")")"; }
    done
  done
  wait
  draw_bar 100 "${T[scan_lbl]}" "$(tf scan_extra "$total" "$total" "$(wc -l < "$wd/alive")" "$(wc -l < "$wd/adb")")"; echo
  ip neigh 2>/dev/null | awk '/lladdr/ && !/FAILED|INCOMPLETE/ {print $1}' | grep -E '^[0-9]+(\.[0-9]+){3}$' \
    | while read -r a; do [[ " ${bases[*]} " == *" ${a%.*} "* && $own != *" $a "* ]] && echo "$a"; done >> "$wd/alive"
  local -a alive; mapfile -t alive < <(sort -u -t. -k1,1n -k2,2n -k3,3n -k4,4n "$wd/alive")
  mkdir -p "$wd/svc"; n=0
  for ip in "${alive[@]}"; do
    (
      a=0; c=0; r=0; w=0
      grep -q "^$ip:" "$wd/adb" && a=1
      probe "$ip" 8009 1 && c=1
      probe "$ip" 6466 1 && r=1
      probe "$ip" "$AERIAL_PORT" 1 && w=1
      h=$(timeout 1.5 getent hosts "$ip" 2>/dev/null | awk '{print $2}' | head -1)
      echo "$ip|$h|$a|$c|$r|$w" > "$wd/svc/$ip"
    ) &
    (( ++n % 64 == 0 )) && wait
  done
  wait
  local f ipx h a c r w
  for ip in "${alive[@]}"; do
    f="$wd/svc/$ip"; [[ -s $f ]] || continue
    IFS='|' read -r ipx h a c r w < "$f"
    if (( a || c || r || w )); then NET_IP+=("$ipx"); NET_HOST+=("$h"); NET_ADB+=("$a"); NET_CAST+=("$c"); NET_RC+=("$r"); NET_AER+=("$w")
    else ((NET_OTHER++)); fi
  done
  cursor_on
  local targets
  mapfile -t targets < <(sort -u "$wd/adb" "$HIST" | grep .)
  rm -rf "$wd"
  if (( ${#targets[@]} )); then
    info "$(tf connecting "${#targets[@]}")"
    for t in "${targets[@]}"; do ( timeout 6 adb connect "$t" >/dev/null 2>&1 ) & done
    wait
  fi
}

DEV_SERIAL=(); DEV_STATE=(); DEV_NAME=(); DEV_MODEL=(); DEV_ANDROID=(); DEV_IP=(); DEV_PORT=(); DEV_CONN=(); DEV_TV=(); DEV_ABI=()

collect_devices() {
  DEV_SERIAL=(); DEV_STATE=(); DEV_NAME=(); DEV_MODEL=(); DEV_ANDROID=(); DEV_IP=(); DEV_PORT=(); DEV_CONN=(); DEV_TV=(); DEV_ABI=()
  local serial state tmpd idx=0
  tmpd=$(mktemp -d)
  while read -r serial state _; do
    [[ -z $serial || $serial == List || $serial == emulator-* ]] && continue
    DEV_SERIAL+=("$serial"); DEV_STATE+=("$state")
    if [[ $state == device ]]; then
      ( timeout 8 adb -s "$serial" shell '
          n=$(settings get global device_name 2>/dev/null); [ "$n" = null ] && n=""
          ipa=$(ip -o -4 addr show 2>/dev/null | grep -v " lo " | awk "{print \$4}" | cut -d/ -f1 | head -1)
          tv=$(pm list features 2>/dev/null | grep -c -e leanback -e android.hardware.type.television)
          echo "$n|$(getprop ro.product.manufacturer)|$(getprop ro.product.model)|$(getprop ro.build.version.release)|$(getprop ro.build.version.sdk)|$ipa|$tv|$(getprop ro.product.cpu.abi)"
        ' 2>/dev/null | tr -d '\r' > "$tmpd/$idx" ) &
    fi
    ((idx++))
  done < <(adb devices 2>/dev/null | tail -n +2)
  wait
  local i f n man mod rel sdk ipa tv abi
  for i in "${!DEV_SERIAL[@]}"; do
    f="$tmpd/$i"; n=; man=; mod=; rel=; sdk=; ipa=; tv=0; abi=
    [[ -s $f ]] && IFS='|' read -r n man mod rel sdk ipa tv abi < "$f"
    serial=${DEV_SERIAL[$i]}
    if [[ $serial =~ ^([0-9.]+):([0-9]+)$ ]]; then DEV_IP+=("${BASH_REMATCH[1]}"); DEV_PORT+=("${BASH_REMATCH[2]}"); DEV_CONN+=("${T[conn_net]}")
    elif [[ $serial == *_adb-tls-connect* ]]; then DEV_IP+=("${ipa:-—}"); DEV_PORT+=("TLS"); DEV_CONN+=("${T[conn_wifi]}")
    else DEV_IP+=("${ipa:-—}"); DEV_PORT+=("—"); DEV_CONN+=("${T[conn_usb]}"); fi
    [[ -z $n ]] && n="${mod:-${T[unknown]}}"
    DEV_NAME+=("$n"); DEV_MODEL+=("$(echo "$man $mod" | xargs)"); DEV_ANDROID+=("${rel:+$rel (API $sdk)}")
    DEV_TV+=("${tv:-0}"); DEV_ABI+=("$abi")
  done
  rm -rf "$tmpd"
}

state_label() {
  case "$1" in
    device)       printf '%s%s%s' "$GRN" "${T[st_ready]}" "$R" ;;
    unauthorized) printf '%s%s%s' "$YEL" "${T[st_unauth]}" "$R" ;;
    offline)      printf '%s%s%s' "$RED" "${T[st_offline]}" "$R" ;;
    *)            printf '%s%s%s' "$DIM" "$1" "$R" ;;
  esac
}

show_devices() {
  local i tvc=0 total=${#DEV_SERIAL[@]}
  for i in "${!DEV_SERIAL[@]}"; do (( DEV_TV[i] > 0 )) && ((tvc++)); done
  title "$(tf dev_title "$total" "$tvc")"
  if (( total == 0 )); then warn "${T[dev_none]}"; info "${T[dev_hint]}"; return; fi
  printf '  %s%s %s %s %s %s %s %s %s%s\n' "$BOLD$DIM" "$(pad "${T[col_no]}" 3)" "$(pad "${T[col_name]}" 20)" "$(pad "${T[col_model]}" 22)" \
    "$(pad "${T[col_android]}" 13)" "$(pad "${T[col_ip]}" 15)" "$(pad "${T[col_port]}" 6)" "$(pad "${T[col_conn]}" 6)" "${T[col_state]}" "$R"
  for i in "${!DEV_SERIAL[@]}"; do
    local tag="  "; (( DEV_TV[i] > 0 )) && tag="${CYN}TV${R}"
    printf '  %s%s%s %s %s %s %s %s %s %s %s\n' "$BOLD$YEL" "$(pad "$((i+1))" 3)" "$R" \
      "$BOLD$(pad "${DEV_NAME[$i]}" 20)$R" "$(pad "${DEV_MODEL[$i]:-—}" 22)" "$(pad "${DEV_ANDROID[$i]:-—}" 13)" \
      "$(pad "${DEV_IP[$i]}" 15)" "$(pad "${DEV_PORT[$i]}" 6)" "$(pad "${DEV_CONN[$i]}" 6)" "$(state_label "${DEV_STATE[$i]}")" "$tag"
  done
}

yesno() { if (( $1 )); then printf '%s%s%s' "$GRN" "$(pad "${T[yes]}" "$2")" "$R"; else printf '%s%s%s' "$DIM" "$(pad "${T[no]}" "$2")" "$R"; fi; }

show_network() {
  (( ${#NET_IP[@]} + NET_OTHER == 0 )) && return
  title "$(tf net_title "${#NET_IP[@]}" "$NET_OTHER")"
  (( ${#NET_IP[@]} )) || { info "${T[net_none]}"; return; }
  printf '  %s%s %s %s %s %s %s %s%s\n' "$BOLD$DIM" "$(pad "${T[col_ip]}" 15)" "$(pad "${T[col_host]}" 20)" "$(pad "${T[col_adb]}" 7)" \
    "$(pad "${T[col_cast]}" 7)" "$(pad "${T[col_rc]}" 8)" "$(pad "${T[col_aerial]}" 7)" "${T[col_ctrl]}" "$R"
  local i j st
  for i in "${!NET_IP[@]}"; do
    st="${YEL}${T[net_adb_off]}${R}"
    if (( NET_ADB[i] )); then
      st="${YEL}${T[net_adb_auth]}${R}"
      for j in "${!DEV_IP[@]}"; do
        [[ ${DEV_IP[$j]} == "${NET_IP[$i]}" ]] || continue
        case "${DEV_STATE[$j]}" in
          device) st="${GRN}$(tf net_connected $((j+1)))${R}" ;;
          unauthorized) st="${YEL}$(tf net_confirm $((j+1)))${R}" ;;
        esac
      done
    fi
    printf '  %s %s %s %s %s %s %s\n' "$(pad "${NET_IP[$i]}" 15)" "$(pad "${NET_HOST[$i]:-—}" 20)" \
      "$(yesno "${NET_ADB[$i]}" 7)" "$(yesno "${NET_CAST[$i]}" 7)" "$(yesno "${NET_RC[$i]}" 8)" "$(yesno "${NET_AER[$i]}" 7)" "$st"
  done
  printf '  %s%s%s\n' "$DIM" "$(tf net_legend "$SCAN_PORTS" "$AERIAL_PORT")" "$R"
}

show_ports() {
  title "${T[ports_title]}"
  key "5555" "${T[port_5555]}" 12
  key "5556-5585" "${T[port_extra]}" 12
  key "30000-49999" "${T[port_wireless]}" 12
}

manual_connect() {
  show_ports
  local ipaddr port out
  ask ipaddr "${T[ip_prompt]}" || return
  [[ $ipaddr =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || { err "${T[bad_ip]}"; pause; return; }
  ask port "$(tf port_prompt 5555)" 1 || return; port=${port:-5555}
  [[ $port =~ ^[0-9]+$ ]] && (( port > 0 && port < 65536 )) || { err "${T[bad_port]}"; pause; return; }
  info "$(tf connecting_to "$ipaddr:$port")"
  out=$(timeout 15 adb connect "$ipaddr:$port" 2>&1)
  if [[ $out == *connected* && $out != *failed* && $out != *cannot* ]]; then ok "$out"; remember "$ipaddr:$port"
  else err "${out:-${T[no_answer]}}"; info "${T[pair_hint_after]}"; fi
  pause
}

pair_device() {
  title "${T[pair_title]}"; info "${T[pair_info]}"
  local hp code
  ask hp "${T[pair_hp]}" || return
  ask code "${T[pair_code]}" || return
  timeout 20 adb pair "$hp" "$code" 2>&1 | sed 's/^/  /'
  info "${T[pair_done]}"; pause
}

# ════════════════════════ Aerial web panel ════════════════════════
open_url() {
  local url="$1"
  info "$(tf web_opening "$url")"
  if command -v xdg-open >/dev/null; then (xdg-open "$url" >/dev/null 2>&1 &) ; else warn "$(tf web_noopen "$url")"; fi
  info "${T[web_note]}"
}

aerial_web() {
  local preset_ip="${1:-}" ipaddr port i sel
  local -a cands=()
  title "${T[web_title]}"
  if [[ -n $preset_ip ]]; then
    ipaddr=$preset_ip
  else
    for i in "${!NET_IP[@]}"; do (( NET_AER[i] )) && cands+=("${NET_IP[$i]}|${NET_HOST[$i]}"); done
    if (( ${#cands[@]} )); then
      info "${T[web_found]}"
      for i in "${!cands[@]}"; do key "$((i+1))" "$(pad "${cands[$i]%%|*}" 16) ${DIM}${cands[$i]#*|}${R}"; done
    else warn "${T[web_none]}"; fi
    ask sel "${T[web_prompt]}" || return
    if [[ $sel =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#cands[@]} )); then ipaddr=${cands[$((sel-1))]%%|*}; else ipaddr=$sel; fi
  fi
  [[ $ipaddr =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || { err "${T[bad_ip]}"; pause; return; }
  ask port "$(tf web_port "$AERIAL_PORT")" 1 || return; port=${port:-$AERIAL_PORT}
  [[ $port =~ ^[0-9]+$ ]] && (( port > 0 && port < 65536 )) || { err "${T[bad_port]}"; pause; return; }
  if probe "$ipaddr" "$port" 2; then open_url "http://$ipaddr:$port/"; else err "$(tf web_closed "$port" "$ipaddr")"; fi
  pause
}

# ════════════════════════ Selected TV ════════════════════════
S=""; S_IDX=0
A()  { adb -s "$S" "$@"; }
SH() { adb -s "$S" shell "$@" 2>/dev/null | tr -d '\r'; }

device_card() {
  local i=$S_IDX
  banner "$(tf card_connected "${DEV_NAME[$i]}" "${DEV_MODEL[$i]}")"
  printf '  %s%s%s %s   %s%s%s %s   %sAndroid:%s %s   %s%s%s %s   %s%s%s %s\n' \
    "$DIM" "${T[lbl_ip]}" "$R" "${DEV_IP[$i]}" "$DIM" "${T[lbl_port]}" "$R" "${DEV_PORT[$i]}" "$DIM" "$R" "${DEV_ANDROID[$i]:-—}" \
    "$DIM" "${T[lbl_cpu]}" "$R" "${DEV_ABI[$i]:-—}" "$DIM" "${T[lbl_folder]}" "$R" "$APK_DIR"
}

list_apks() {
  find "$1" -maxdepth 1 -type f \( -iname '*.apk' -o -iname '*.apks' -o -iname '*.apkm' -o -iname '*.xapk' \) \
    -printf '%T@\t%p\n' 2>/dev/null | sort -rn | cut -f2-
}

# "1 3 5", "2-4", "a" = all
parse_selection() {
  local input="$1" max="$2" tok a b k; local -a out=()
  [[ $input =~ ^[aA]$|^all$ ]] && { seq 1 "$max"; return; }
  for tok in ${input//,/ }; do
    if [[ $tok =~ ^([0-9]+)-([0-9]+)$ ]]; then a=${BASH_REMATCH[1]}; b=${BASH_REMATCH[2]}
      for ((k=a; k<=b; k++)); do (( k>=1 && k<=max )) && out+=("$k"); done
    elif [[ $tok =~ ^[0-9]+$ ]] && (( tok>=1 && tok<=max )); then out+=("$tok"); fi
  done
  (( ${#out[@]} )) && printf '%s\n' "${out[@]}" | awk '!seen[$0]++'
}

explain_error() {
  case "$1" in
    *NO_MATCHING_ABIS*)     info "$(tf e_abi "${DEV_ABI[$S_IDX]:-CPU}")" ;;
    *OLDER_SDK*)            info "${T[e_sdk]}" ;;
    *UPDATE_INCOMPATIBLE*)  info "${T[e_sig]}" ;;
    *VERSION_DOWNGRADE*)    info "${T[e_down]}" ;;
    *INSUFFICIENT_STORAGE*) info "${T[e_space]}" ;;
    *INVALID_APK*|*PARSE*)  info "${T[e_parse]}" ;;
  esac
}

# Sending (0–90 %) + installing (90–100 %)
install_one_apk() {
  local f="$1" size tmp="/data/local/tmp/ctv_$$_$RANDOM.apk" start cur pct pid res el
  size=$(stat -c %s "$f"); (( size == 0 )) && size=1
  start=$SECONDS
  A push "$f" "$tmp" >/dev/null 2>&1 & pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    cur=$(SH stat -c %s "$tmp"); [[ $cur =~ ^[0-9]+$ ]] || cur=0
    pct=$(( cur * 90 / size ))
    draw_bar "$pct" "${T[xfer]}" "$(human "$cur") / $(human "$size")   ⏱ $(fmt_time $((SECONDS-start)))"
    sleep 0.3
  done
  if ! wait "$pid"; then echo; err "${T[xfer_fail]}"; SH rm -f "$tmp"; return 1; fi
  res=$(mktemp)
  SH pm install -r -t "$tmp" > "$res" 2>&1 & pid=$!
  pct=90
  while kill -0 "$pid" 2>/dev/null; do
    (( pct < 99 )) && ((pct++))
    draw_bar "$pct" "${T[inst]}" "$(human "$size")   ⏱ $(fmt_time $((SECONDS-start)))"
    sleep 0.5
  done
  wait "$pid"; SH rm -f "$tmp"; el=$((SECONDS-start)); LAST_TIME=$el
  if grep -q '^Success' "$res"; then draw_bar 100 "${T[done]}" "$(human "$size")   ⏱ $(fmt_time "$el")"; echo; rm -f "$res"; return 0; fi
  echo; err "$(grep -m1 -E 'Failure|Error|Exception' "$res" || head -1 "$res")"; explain_error "$(cat "$res")"; rm -f "$res"; return 1
}

install_bundle() {
  local f="$1" d start pid res el
  command -v unzip >/dev/null || { err "$(tf need_unzip "$(basename "$f")")"; return 1; }
  d=$(mktemp -d); start=$SECONDS
  unzip -qo "$f" '*.apk' -d "$d" 2>/dev/null
  local -a parts; mapfile -t parts < <(find "$d" -type f -name '*.apk')
  (( ${#parts[@]} )) || { err "${T[no_apk_in_zip]}"; rm -rf "$d"; return 1; }
  res=$(mktemp)
  A install-multiple -r "${parts[@]}" > "$res" 2>&1 & pid=$!
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' k=0
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r\e[K  %s%s%s %s  %s⏱ %s%s' "$CYN" "${spin:k++%10:1}" "$R" "$(tf bundle_inst "${#parts[@]}")" "$DIM" "$(fmt_time $((SECONDS-start)))" "$R"
    sleep 0.15
  done
  wait "$pid"; el=$((SECONDS-start)); LAST_TIME=$el; rm -rf "$d"
  if grep -q 'Success' "$res"; then draw_bar 100 "${T[done]}" "⏱ $(fmt_time "$el")"; echo; rm -f "$res"; return 0; fi
  echo; err "$(grep -m1 -E 'Failure|Error' "$res" || head -1 "$res")"; explain_error "$(cat "$res")"; rm -f "$res"; return 1
}

install_files() {
  local -a files=("$@") summary=(); local n=${#files[@]} i f ok_n=0 bad_n=0 tstart=$SECONDS
  title "$(tf inst_title "$n" "${DEV_NAME[$S_IDX]}")"
  cursor_off
  for i in "${!files[@]}"; do
    f=${files[$i]}; LAST_TIME=0
    printf '\n  %s[%d/%d]%s %s%s%s  %s(%s)%s\n' "$BOLD$YEL" $((i+1)) "$n" "$R" "$BOLD" "$(basename "$f")" "$R" "$DIM" "$(human "$(stat -c %s "$f")")" "$R"
    case "${f,,}" in *.apk) install_one_apk "$f" ;; *) install_bundle "$f" ;; esac
    if (( $? == 0 )); then ((ok_n++)); summary+=("${GRN}✔${R} $(pad "$(basename "$f")" 48) $(fmt_time "$LAST_TIME")")
    else ((bad_n++)); summary+=("${RED}✖${R} $(pad "$(basename "$f")" 48) $(fmt_time "$LAST_TIME")"); fi
    draw_bar $(( (i+1) * 100 / n )) "${T[total]}" "$((i+1))/$n   ⏱ $(fmt_time $((SECONDS-tstart)))"; echo
  done
  cursor_on
  title "$(tf summary "${GRN}$ok_n${R}" "${RED}$bad_n${R}" "$(fmt_time $((SECONDS-tstart)))")"
  printf '  %s\n' "${summary[@]}"
  pause
}

menu_install() {
  local all_mode="$1" files sel i; local -a picks=()
  [[ -d $APK_DIR ]] || { err "$(tf folder_missing "$APK_DIR")"; info "${T[folder_change_hint]}"; pause; return; }
  mapfile -t files < <(list_apks "$APK_DIR")
  (( ${#files[@]} )) || { warn "$(tf no_apks "$APK_DIR")"; pause; return; }
  [[ $all_mode == all ]] && { install_files "${files[@]}"; return; }
  title "$(tf apk_list_title "$APK_DIR")"
  for i in "${!files[@]}"; do
    printf '  %s%s%s %s %s%s  %s%s\n' "$BOLD$YEL" "$(pad "$((i+1))" 3)" "$R" "$(pad "$(basename "${files[$i]}")" 52)" \
      "$DIM" "$(pad "$(human "$(stat -c %s "${files[$i]}")")" 9)" "$(date -r "${files[$i]}" '+%d.%m.%Y %H:%M')" "$R"
  done
  echo; info "${T[sel_examples]}"
  ask sel "${T[what_install]}" || return
  while read -r i; do [[ -n $i ]] && picks+=("${files[$((i-1))]}"); done < <(parse_selection "$sel" "${#files[@]}")
  (( ${#picks[@]} )) || { err "${T[nothing_sel]}"; pause; return; }
  install_files "${picks[@]}"
}

menu_folder() {
  title "$(tf folder_title "$APK_DIR")"
  local dl desk; dl=$(xdg-user-dir DOWNLOAD 2>/dev/null || echo "$HOME/Downloads"); desk=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
  key 1 "$(pad "${T[f_desktop]}" 18) ${DIM}$desk${R}"
  key 2 "$(pad "${T[f_own]}" 18) ${DIM}$HOME/TV-APK  ${T[f_own_note]}${R}"
  key 3 "$(pad "${T[f_dl]}" 18) ${DIM}$dl${R}"
  key 4 "${T[f_custom]}"
  printf '  %s%s%s\n' "$DIM" "${T[back_hint]}" "$R"
  local c p
  ask c "${T[choice]}" || return
  case "$c" in
    1) p="$desk" ;;
    2) p="$HOME/TV-APK"; mkdir -p "$p" && ok "$(tf folder_ready "$p")" ;;
    3) p="$dl" ;;
    4) ask p "${T[path_prompt]}" || return; p="${p/#\~/$HOME}" ;;
    *) return ;;
  esac
  if [[ -d $p ]]; then APK_DIR="$p"; save_conf; ok "$(tf folder_set "$APK_DIR")"; else err "$(tf folder_nx "$p")"; fi
  pause
}

# ════════════════════════ Apps ════════════════════════
declare -A APP_NAME=(
  [org.smarttube.stable]="SmartTube" [org.smarttube.beta]="SmartTube Beta" [com.google.android.youtube.tv]="YouTube"
  [com.netflix.ninja]="Netflix" [org.xbmc.kodi]="Kodi" [org.videolan.vlc]="VLC" [org.localsend.localsend_app]="LocalSend"
  [app.orchard.tv]="Aerial" [com.neilturner.aerialviews]="Aerial Views" [com.recisio.kfandroid]="KaraFun"
  [ru.rutube.app]="RuTube" [com.maertsno.tv]="OnStream" [cm.aptoidetv.pt]="Aptoide TV" [com.tiktok.tv]="TikTok"
  [com.android.vending]="Google Play Store" [com.google.android.gms]="Google Play Services" [com.google.android.gsf]="Google Services Framework"
  [com.amazon.amazonvideo.livingroom]="Prime Video" [com.disney.disneyplus]="Disney+" [com.spotify.tv.android]="Spotify"
  [com.android.tv.settings]="Settings" [com.yablio.sendfilestotv]="Send Files to TV" [com.overdevs.at4k]="AT4K Launcher"
  [com.spocky.projengmenu]="Projectivy" [com.tv.browser.joyen]="Joyen Browser" [com.cltv.hybrid]="MediaTek TV inputs"
  [com.tcl.tvweishi]="TCL TV Protection" [com.google.android.apps.mediashell]="Chromecast built-in"
  [com.google.android.tv.remote.service]="Remote service" [com.google.android.tv.googletvremotepairer]="Remote pairing"
  [com.google.android.inputmethod.latin]="Gboard keyboard" [com.google.android.webview]="Android WebView"
  [com.google.android.tvlauncher]="Google TV Home" [com.google.android.apps.tv.launcherx]="Google TV Home (new)"
  [com.google.android.leanbacklauncher]="Android TV Home" [com.google.android.leanbacklauncher.recommendations]="Home recommendations"
  [com.google.android.leanbacklauncher.partnercustomizer]="Home partner customizer" [com.google.android.leanbacklauncher.partnerwidget]="Home partner widget"
  [com.google.android.tvrecommendations]="TV recommendations" [com.google.android.katniss]="Google voice search"
  [com.google.android.tungsten.setupwraith]="Setup wizard" [com.google.android.backdrop]="Ambient screensaver"
  [com.google.android.apps.tv.dreamx]="Google screensaver" [com.google.android.videos]="Google Play Movies"
  [com.google.android.music]="Google Play Music" [com.google.android.play.games]="Google Play Games"
  [com.google.android.youtube.tvmusic]="YouTube Music" [com.google.android.feedback]="Google Feedback"
  [com.google.android.tv.bugreportsender]="Bug report sender" [com.google.android.marvin.talkback]="TalkBack"
  [com.google.android.partnersetup]="Partner setup" [com.google.android.onetimeinitializer]="One-time initializer"
  [com.google.android.syncadapters.calendar]="Calendar sync" [com.google.android.syncadapters.contacts]="Contacts sync"
  [com.google.android.tvtutorials]="TV tutorials" [com.google.android.backuptransport]="Backup transport"
  [com.google.android.speech.pumpkin]="Speech recognition" [com.google.android.tts]="Google Text-to-speech"
  [com.google.android.sss.authbridge]="Sign-in bridge" [com.google.android.configupdater]="Config updater"
  [com.google.android.ext.services]="Android ext services" [com.google.android.ext.shared]="Android ext shared"
  [com.google.android.packageinstaller]="Package installer" [com.google.android.permissioncontroller]="Permission controller"
  [com.google.android.tv.frameworkpackagestubs]="Framework stubs" [com.google.android.tv.inputplayer]="TV input player"
  [android.autoinstalls.config.google.gtvpai]="Auto-install config"
)

launch_app() {
  local pkg="$1" act out
  act=$(SH cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.LEANBACK_LAUNCHER "$pkg" | tail -1 | xargs)
  [[ $act == */* ]] || act=$(SH cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER "$pkg" | tail -1 | xargs)
  if [[ $act == */* ]]; then
    out=$(SH am start -n "$act")
    [[ $out == *Error* ]] && { err "$out"; return 1; }
    ok "$(tf launch_ok "${APP_NAME[$pkg]:-$pkg}")"; return 0
  fi
  out=$(SH monkey -p "$pkg" 1)
  if [[ $out == *"Events injected: 1"* ]]; then ok "$(tf launch_ok "${APP_NAME[$pkg]:-$pkg}")"; else err "${T[launch_no]}"; return 1; fi
}

app_actions() {
  local pkg="$1" mode="$2" ver dis c yn nm
  nm="${APP_NAME[$pkg]:-$pkg}"
  while true; do
    device_card
    ver=$(SH dumpsys package "$pkg" | grep -m1 versionName | cut -d= -f2)
    dis=$(SH pm list packages -d | grep -cx "package:$pkg")
    title "$nm"
    printf '  %s%s%s %s   %s%s%s %s   %s%s%s %s   %s%s%s %s\n' "$DIM" "${T[app_pkg]}" "$R" "$pkg" "$DIM" "${T[app_ver]}" "$R" "${ver:-—}" \
      "$DIM" "${T[app_type]}" "$R" "$([[ $mode == sys ]] && echo "${T[t_sys]}" || echo "${T[t_user]}")" \
      "$DIM" "${T[app_state]}" "$R" "$( (( dis )) && echo "${RED}${T[s_disabled]}${R}" || echo "${GRN}${T[s_enabled]}${R}")"
    echo
    key 1 "${T[a_open]}"; key 2 "${T[a_stop]}"
    if [[ $mode == sys ]]; then
      if (( dis )); then key 3 "${T[a_enable]}"; else key 3 "${T[a_disable]} ${DIM}${T[a_disable_note]}${R}"; fi
      key 4 "${RED}${T[a_uninst_user]}${R} ${DIM}${T[a_uninst_note]}${R}"
    else
      key 3 "${RED}${T[a_uninst]}${R}"
    fi
    printf '  %s%s%s\n' "$DIM" "${T[back_hint]}" "$R"
    ask c "${T[choice]}" || return
    case "$c" in
      1) launch_app "$pkg"; pause ;;
      2) SH am force-stop "$pkg"; ok "${T[stopped]}"; pause ;;
      3) if [[ $mode == sys ]]; then
           if (( dis )); then SH pm enable "$pkg" | sed 's/^/  /'
           else warn "${T[warn_sys_disable]}"; ask yn "$(tf q_disable "$nm")" 1; is_yes "$yn" && SH pm disable-user --user 0 "$pkg" | sed 's/^/  /'; fi
           pause
         else
           ask yn "$(tf q_uninstall "$nm")" 1
           is_yes "$yn" && { A uninstall "$pkg" 2>&1 | sed 's/^/  /'; pause; return; }
         fi ;;
      4) [[ $mode == sys ]] || continue
         warn "$(tf warn_sys_uninst "$pkg")"; ask yn "$(tf q_uninst_user "$nm")" 1
         is_yes "$yn" && { SH pm uninstall --user 0 "$pkg" | sed 's/^/  /'; pause; return; } ;;
    esac
  done
}

menu_apps() {
  local mode=user filter=""
  while true; do
    device_card
    local -a rows=() shown=(); local -A disabled=(); local i pkg ver sel name label
    while read -r pkg; do [[ -n $pkg ]] && disabled[$pkg]=1; done < <(SH pm list packages -d | cut -d: -f2)
    if [[ $mode == user ]]; then
      label="${T[apps_user]}"
      mapfile -t rows < <(SH 'for p in $(pm list packages -3 | cut -d: -f2 | sort); do v=$(dumpsys package $p | grep -m1 versionName | cut -d= -f2); echo "$p|$v"; done')
    else
      label="${T[apps_sys]}"
      mapfile -t rows < <(SH pm list packages -s | cut -d: -f2 | sort | sed 's/$/|/')
    fi
    for i in "${!rows[@]}"; do
      pkg=${rows[$i]%%|*}; name=${APP_NAME[$pkg]:-}
      [[ -z $filter || ${pkg,,} == *"${filter,,}"* || ${name,,} == *"${filter,,}"* ]] && shown+=("${rows[$i]}")
    done
    title "$label: ${#shown[@]}${filter:+  (${T[search_lbl]}: «$filter»)}"
    for i in "${!shown[@]}"; do
      pkg=${shown[$i]%%|*}; ver=${shown[$i]#*|}; name=${APP_NAME[$pkg]:-}
      printf '  %s%s%s %s %s %s%s%s %s\n' "$BOLD$YEL" "$(pad "$((i+1))" 4)" "$R" "$BOLD$(pad "${name:-·}" 24)$R" "$(pad "$pkg" 46)" \
        "$DIM" "$ver" "$R" "$([[ -n ${disabled[$pkg]:-} ]] && echo "${RED}[${T[s_disabled]}]${R}")"
    done
    (( ${#shown[@]} )) || warn "${T[nothing_found]}"
    echo; info "$(tf apps_hint "$([[ $mode == user ]] && echo "${T[show_sys]}" || echo "${T[show_user]}")")"
    ask sel "${T[choice]}" || return
    case "$sel" in
      s|S) [[ $mode == user ]] && mode=sys || mode=user; filter="" ;;
      /*) filter="${sel#/}" ;;
      *) if [[ $sel =~ ^[0-9]+$ ]] && (( sel>=1 && sel<=${#shown[@]} )); then app_actions "${shown[$((sel-1))]%%|*}" "$mode"
         else err "${T[bad_input]}"; pause; fi ;;
    esac
  done
}

# ════════════════════════ Google services ════════════════════════
# critical = keep (remote, keyboard, boot, system); caution = useful (YouTube, Play, Cast…); everything else = safe
google_risk() {
  case "$1" in
    com.google.android.tv.remote.service|com.google.android.tv.googletvremotepairer|com.google.android.tungsten.setupwraith|\
    com.google.android.webview|com.google.android.ext.services|com.google.android.ext.shared|com.google.android.packageinstaller|\
    com.google.android.permissioncontroller|com.google.android.modulemetadata|com.google.android.inputmethod.latin|\
    com.google.android.tv.frameworkpackagestubs|com.google.android.overlay.*|com.google.android.safetycenter.*|com.google.android.networkstack*|\
    com.google.android.documentsui|com.google.android.captiveportallogin|com.google.android.tvsetup|com.google.android.cellbroadcast*|\
    com.google.android.providers.*|com.google.android.adservices*|com.google.android.wifi.*|com.google.android.tethering*|\
    com.google.android.resolv|com.google.android.media*|com.google.android.os.statsd|com.google.android.sdksandbox|\
    com.google.android.connectivity.*|com.google.android.ondevicepersonalization*|com.google.android.healthconnect*|\
    com.google.android.appsearch*|com.google.android.federatedcompute*|com.google.android.rkpdapp|com.google.android.uwb*|\
    com.google.android.art|com.google.android.conscrypt|com.google.android.ipsec|com.google.android.extservices|\
    com.google.android.tzdata*|com.google.android.neuralnetworks|com.google.android.btservices|com.google.android.virt)
      echo critical ;;
    com.android.vending|com.google.android.gms|com.google.android.gsf|com.google.android.gsf.login|com.google.android.youtube.tv|\
    com.google.android.apps.mediashell|com.google.android.katniss|com.google.android.tts|com.google.android.sss.authbridge|\
    com.google.android.configupdater|com.google.android.tv.inputplayer|com.google.android.gms.*)
      echo caution ;;
    *) echo safe ;;
  esac
}

risk_label() {
  case "$1" in
    safe)     printf '%s%s%s' "$GRN" "$(pad "${T[r_safe]}" 14)" "$R" ;;
    caution)  printf '%s%s%s' "$YEL" "$(pad "${T[r_caution]}" 14)" "$R" ;;
    critical) printf '%s%s%s' "$RED" "$(pad "${T[r_critical]}" 13)" "$R" ;;  # ⛔ is double-width
  esac
}

menu_google() {
  local mode=remove
  while true; do
    device_card
    local -a all inst dis rows=() picks=(); local -A is_inst=() is_dis=(); local p st rk i sel stl ns=0 nc=0 nk=0
    mapfile -t all  < <(SH pm list packages -u | cut -d: -f2 | grep -E 'google|^com\.android\.vending$' | sort -u)
    mapfile -t inst < <(SH pm list packages    | cut -d: -f2)
    mapfile -t dis  < <(SH pm list packages -d | cut -d: -f2)
    for p in "${inst[@]}"; do [[ -n $p ]] && is_inst[$p]=1; done
    for p in "${dis[@]}";  do [[ -n $p ]] && is_dis[$p]=1; done
    for p in "${all[@]}"; do
      [[ -z $p ]] && continue
      if [[ -n ${is_inst[$p]:-} ]]; then st=installed; [[ -n ${is_dis[$p]:-} ]] && st=disabled; else st=removed; fi
      rk=$(google_risk "$p")
      if [[ $mode == remove && $st != removed ]] || [[ $mode == restore && $st != installed ]]; then
        rows+=("$p|$st|$rk")
        case "$rk" in safe) ((ns++)) ;; caution) ((nc++)) ;; critical) ((nk++)) ;; esac
      fi
    done
    if [[ $mode == remove ]]; then title "$(tf g_title "${DEV_NAME[$S_IDX]}")"; else title "${T[g_restore_title]}"; fi
    if (( ${#rows[@]} == 0 )); then
      if [[ $mode == remove ]]; then warn "${T[g_none]}"; else warn "${T[g_none_removed]}"; fi
    else
      printf '  %s%s %s %s %s %s%s\n' "$BOLD$DIM" "$(pad "${T[col_no]}" 4)" "$(pad "${T[g_col_name]}" 26)" "$(pad "${T[g_col_pkg]}" 48)" "$(pad "${T[g_col_risk]}" 14)" "${T[g_col_state]}" "$R"
      for i in "${!rows[@]}"; do
        IFS='|' read -r p st rk <<< "${rows[$i]}"
        case "$st" in installed) stl="${GRN}${T[g_installed]}${R}" ;; disabled) stl="${YEL}${T[g_disabled]}${R}" ;; *) stl="${DIM}${T[g_removed]}${R}" ;; esac
        printf '  %s%s%s %s %s %s %s\n' "$BOLD$YEL" "$(pad "$((i+1))" 4)" "$R" "$(pad "${APP_NAME[$p]:-·}" 26)" "$(pad "$p" 48)" "$(risk_label "$rk")" "$stl"
      done
      [[ $mode == remove ]] && { echo; info "$(tf g_summary "${#rows[@]}" "$ns" "$nc" "$nk")"; }
    fi
    if [[ $mode == remove ]]; then info "${T[g_hint]}"; else info "${T[g_hint_restore]}"; fi
    ask sel "${T[choice]}" || return
    if [[ $sel == r || $sel == R ]]; then if [[ $mode == remove ]]; then mode=restore; else mode=remove; fi; continue; fi
    (( ${#rows[@]} )) || continue
    if [[ $sel =~ ^[aA]$ ]]; then
      for i in "${!rows[@]}"; do IFS='|' read -r p st rk <<< "${rows[$i]}"; if [[ $mode == restore || $rk == safe ]]; then picks+=("${rows[$i]}"); fi; done
    else
      while read -r i; do [[ -n $i ]] && picks+=("${rows[$((i-1))]}"); done < <(parse_selection "$sel" "${#rows[@]}")
    fi
    (( ${#picks[@]} )) || { err "${T[nothing_sel]}"; pause; continue; }
    google_apply "$mode" "${picks[@]}"
  done
}

google_apply() {
  local mode="$1"; shift
  local -a picks=("$@") final=() res=(); local p st rk yn home has_crit=0 n i ok_n=0 bad_n=0 out e
  home=$(SH cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1 | xargs); home=${home%%/*}
  if [[ $mode == remove ]]; then
    for e in "${picks[@]}"; do [[ ${e##*|} == critical ]] && has_crit=1; done
    if (( has_crit )); then
      warn "${T[g_crit_warn]}"; ask yn "${T[g_crit_q]}" 1
      if [[ $yn != YES ]]; then
        local -a keep=(); for e in "${picks[@]}"; do [[ ${e##*|} == critical ]] || keep+=("$e"); done
        picks=("${keep[@]}"); info "${T[g_crit_skip]}"
      fi
    fi
    for e in "${picks[@]}"; do p=${e%%|*}; if [[ $p == "$home" ]]; then warn "$(tf g_home_skip "$p")"; else final+=("$e"); fi; done
    (( ${#final[@]} )) || { err "${T[nothing_sel]}"; pause; return; }
    title "$(tf g_confirm_rm "${#final[@]}")"
  else
    final=("${picks[@]}"); title "$(tf g_confirm_rs "${#final[@]}")"
  fi
  for e in "${final[@]}"; do p=${e%%|*}; printf '  • %s %s%s%s\n' "$(pad "${APP_NAME[$p]:-$p}" 28)" "$DIM" "$p" "$R"; done
  ask yn "${T[g_q]}" 1 || return; is_yes "$yn" || return
  echo; n=${#final[@]}
  cursor_off
  for i in "${!final[@]}"; do
    IFS='|' read -r p st rk <<< "${final[$i]}"
    draw_bar $(( i * 100 / n )) "$([[ $mode == remove ]] && echo "${T[g_rm_lbl]}" || echo "${T[g_rs_lbl]}")" "$((i+1))/$n  $p"
    if [[ $mode == remove ]]; then
      out=$(SH pm uninstall --user 0 "$p")
    elif [[ $st == disabled ]]; then
      out=$(SH pm enable "$p"); [[ $out == *enabled* ]] && out=Success
    else
      out=$(SH cmd package install-existing "$p"); [[ $out == *installed* || $out == *Success* ]] && out=Success
    fi
    if [[ $out == *Success* ]]; then ((ok_n++)); res+=("${GRN}✔${R} $p"); else ((bad_n++)); res+=("${RED}✖${R} $p  ${DIM}$(echo "$out" | head -1)${R}"); fi
  done
  draw_bar 100 "${T[done]}" "$n/$n"; echo
  cursor_on
  title "$(tf g_result "${GRN}$ok_n${R}" "${RED}$bad_n${R}")"
  printf '  %s\n' "${res[@]}"
  info "${T[g_reboot_hint]}"
  pause
}

# ════════════════════════ Launcher & info ════════════════════════
menu_launcher() {
  device_card; title "${T[launcher_title]}"
  local cur i sel note; local -a acts
  cur=$(SH cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1 | xargs)
  mapfile -t acts < <(SH cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME | grep / | xargs -n1)
  for i in "${!acts[@]}"; do
    note=""; [[ ${acts[$i]} == *FallbackHome* ]] && note="${DIM}${T[fallback]}${R}"
    [[ ${acts[$i]} == "$cur" ]] && note="${GRN}${T[current_home]}${R}"
    key "$((i+1))" "$(pad "${acts[$i]}" 60) $note"
  done
  printf '  %s%s%s\n' "$DIM" "${T[back_hint]}" "$R"
  ask sel "${T[launcher_prompt]}" || return
  [[ $sel =~ ^[0-9]+$ ]] && (( sel>=1 && sel<=${#acts[@]} )) || { err "${T[bad_num]}"; pause; return; }
  SH cmd package set-home-activity "${acts[$((sel-1))]}" >/dev/null
  SH input keyevent KEYCODE_HOME
  cur=$(SH cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1 | xargs)
  if [[ $cur == "${acts[$((sel-1))]}" ]]; then ok "$(tf home_ok "$cur")"; else err "$(tf home_fail "$cur")"; fi
  pause
}

menu_info() {
  device_card; title "${T[info_title]}"
  local raw man brand model dev rel sdk patch build plat abi wsize dens mt ma sav ssz up home n3 nd na
  raw=$(SH '
    mt=$(awk "/MemTotal/{print \$2}" /proc/meminfo); ma=$(awk "/MemAvailable/{print \$2}" /proc/meminfo)
    set -- $(df -h /data 2>/dev/null | tail -1)
    echo "INFO|$(getprop ro.product.manufacturer)|$(getprop ro.product.brand)|$(getprop ro.product.model)|$(getprop ro.product.device)|$(getprop ro.build.version.release)|$(getprop ro.build.version.sdk)|$(getprop ro.build.version.security_patch)|$(getprop ro.build.display.id)|$(getprop ro.board.platform)|$(getprop ro.product.cpu.abi)|$(wm size | tail -1 | cut -d: -f2)|$(wm density | tail -1 | cut -d: -f2)|$mt|$ma|$4|$2|$(uptime | sed "s/.*up *//;s/,  *[0-9]* user.*//;s/,  *load.*//")|$(cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1)|$(pm list packages -3 | wc -l)|$(pm list packages -d | wc -l)|$(pm list packages | wc -l)"
  ' | grep '^INFO|' | tail -1)
  IFS='|' read -r _ man brand model dev rel sdk patch build plat abi wsize dens mt ma sav ssz up home n3 nd na <<< "$raw"
  [[ $mt =~ ^[0-9]+$ ]] || mt=0; [[ $ma =~ ^[0-9]+$ ]] || ma=0
  local -a kv=(
    "${T[i_maker]}|$man $brand" "${T[i_model]}|$model ($dev)" "${T[i_android]}|$rel (API $sdk), ${T[i_patch]} $patch"
    "${T[i_build]}|$build" "${T[i_platform]}|$plat / $abi" "${T[i_screen]}|$(echo "$wsize" | xargs), $(echo "$dens" | xargs) dpi"
    "${T[i_mem]}|$(tf i_mem_fmt $(( ma / 1024 )) $(( mt / 1024 )))" "${T[i_storage]}|$(tf i_storage_fmt "$sav" "$ssz")"
    "${T[i_uptime]}|$up" "${T[i_launcher]}|$home" "${T[i_apps]}|$(tf i_apps_fmt "$n3" "$nd" "$na")"
  )
  local e; for e in "${kv[@]}"; do printf '  %s%s%s %s\n' "$DIM" "$(pad "${e%%|*}" 16)" "$R" "$(echo "${e#*|}" | xargs)"; done
  pause
}

# ════════════════════════ Menus ════════════════════════
device_menu() {
  while true; do
    if [[ $(adb -s "$S" get-state 2>/dev/null) != device ]]; then err "$(tf lost "$S")"; pause; return; fi
    device_card; title "${T[menu_title]}"
    key 1 "${T[m1]}"; key 2 "${T[m2]}"; key 3 "${T[m3]}"; key 4 "${T[m4]}"; key 5 "${T[m5]}"
    key 6 "${T[m6]}"; key 7 "${T[m7]}"; key 8 "$(tf m8 "$AERIAL_PORT")"; key 9 "${T[m9]}"
    printf '  %s%s  •  q — %s%s\n' "$DIM" "${T[back_hint]}" "${T[quit]}" "$R"
    local c yn; ask c "${T[choice]}" || return
    case "$c" in
      1) menu_install pick ;;
      2) menu_install all ;;
      3) menu_folder ;;
      4) menu_apps ;;
      5) menu_google ;;
      6) menu_launcher ;;
      7) menu_info ;;
      8) if [[ ${DEV_IP[$S_IDX]} =~ ^[0-9.]+$ ]]; then aerial_web "${DEV_IP[$S_IDX]}"; else aerial_web; fi ;;
      9) ask yn "$(tf q_reboot "${DEV_NAME[$S_IDX]}")" 1; is_yes "$yn" && { A reboot; ok "${T[rebooting]}"; pause; return; } ;;
      q|Q) exit 0 ;;
    esac
  done
}

about() {
  banner "${T[about_title]}"; title "${T[about_title]}"
  printf '  %s%s %s%s\n' "$BOLD" "$APP_TITLE" "$VERSION" "$R"
  info "${T[about_desc]}"
  echo
  printf '  %s%s%s %s\n' "$DIM" "$(pad "Author" 10)" "$R" "$AUTHOR"
  printf '  %s%s%s %s\n' "$DIM" "$(pad "License" 10)" "$R" "$LICENSE_NAME"
  pause
}

main_keys() {
  printf '  %s%s%s %s %s%s%s %s\n' "$BOLD$YEL" "$(pad "$1" 5)" "$R" "$(pad "$2" 36)" "$BOLD$YEL" "$(pad "$3" 2)" "$R" "$4"
}

main() {
  load_conf
  if [[ -z $UI_LANG ]]; then choose_lang; else set_lang "$UI_LANG"; fi
  need_adb
  banner; scan_network; collect_devices
  while true; do
    banner; show_devices; show_network
    title "${T[actions]}"
    (( ${#DEV_SERIAL[@]} )) && key "1-${#DEV_SERIAL[@]}" "${T[a_pick]}" 5
    main_keys s "${T[a_scan]}"    m "${T[a_manual]}"
    main_keys p "${T[a_pair]}"    d "${T[a_disc]}"
    main_keys r "${T[a_refresh]}" o "$(tf a_ports "$SCAN_PORTS")"
    main_keys w "${T[a_web]}"     l "${T[a_lang]}"
    main_keys i "${T[a_about]}"   q "${T[quit]}"
    printf '\n  %s%s %s  •  %s%s\n' "$DIM" "$APP_TITLE" "$VERSION" "${T[by]}" "$R"
    local c np
    ask c "${T[choice]}" || continue
    case "$c" in
      s|S) banner; scan_network; collect_devices ;;
      r|R) collect_devices ;;
      m|M) manual_connect; collect_devices ;;
      p|P) pair_device ;;
      d|D) adb disconnect >/dev/null 2>&1; ok "${T[disc_done]}"; sleep 1; collect_devices ;;
      o|O) show_ports; ask np "${T[ports_prompt]}" 1 || continue; SCAN_PORTS="${np:-5555}"; save_conf ;;
      w|W) aerial_web ;;
      l|L) choose_lang; collect_devices ;;
      i|I) about ;;
      q|Q) exit 0 ;;
      *)
        if [[ $c =~ ^[0-9]+$ ]] && (( c >= 1 && c <= ${#DEV_SERIAL[@]} )); then
          S_IDX=$((c-1)); S=${DEV_SERIAL[$S_IDX]}
          case "${DEV_STATE[$S_IDX]}" in
            device) [[ $S =~ ^[0-9.]+:[0-9]+$ ]] && remember "$S"; device_menu; collect_devices ;;
            unauthorized) warn "${T[need_confirm]}"; pause ;;
            *) err "$(tf unavailable "$S")"; pause ;;
          esac
        fi ;;
    esac
  done
}

main "$@"
