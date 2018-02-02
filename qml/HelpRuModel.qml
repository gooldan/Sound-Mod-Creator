import QtQuick 2.0

ListModel {
    id: nestedModel
    ListElement {
        categoryName: "Описание программы"
        collapsed: true
        subItems: [
            ListElement {
                itemName: "Эта программа для модифицирования звука и эффектов в игре World of Warships.\
\nВы можете заменить любые звуки игры на свои собственные или отключить их."
            },
            ListElement{
                itemName:"Ознакомиться с инструкцией по использованию программы можно в следующих секциях."
            },
            ListElement{
                itemName:"В настоящей инструкции используются скриншоты и записи действий на экране. \
Скриншоты будут обозначены следующим образом: <a href=\"../screens/ru/test.png\">пример скриншота</a>, <a href=\"../screens/ru/example.gif\">пример записи</a>."
            }

        ]
    }

    ListElement {
        categoryName: "Подготовка к началу работы"
        collapsed: true
        subItems: [
            ListElement {
                itemName: "Для корректной работы программы её необходимо предварительно настроить. \
Для этого необходимо зайти в \"Опции\" -> \"Настройки\". <a href=\"../screens/ru/options_ru.gif\">Видео</a>."
            },
            ListElement {
                itemName: "Далее необходимо указать пути до папки с игрой, папки WWISE и путь к проекту WWISE."
            },
            ListElement {
                itemName: "Путь к папке с игрой должен выглядеть следующим образом: <a href=\"../screens/ru/game_dir_ru.png\">скриншот</a>."
            },
            ListElement {
                itemName: "Путь к папке WWISE должен выглядеть следующим образом: <a href=\"../screens/ru/wwise_dir_ru.png\">скриншот</a>.\
 При правильном указании пути, <a href=\"../screens/ru/wwise_not_found_ru.png\">надпись</a> \"Не могу найти wwise-cli!\" должна исчезнуть. \
Обратите внимание на версию WWISE, она должна быть равна 2016.2.1.5995."
            },
            ListElement {
                itemName: "Путь к файлу проекта WWISE должен выглядеть следующим образом: <a href=\"../screens/ru/wwise_proj_ru.png\">скриншот</a>.\
 При правильном указании пути, <a href=\"../screens/ru/wwiseproj_not_found_ru.png\">надпись</a> \"Файл проекта WWISE не выбран!\" должна исчезнуть."
            },
            ListElement {
                itemName: "Путь к файлу mod.xml должен выглядеть следующим образом: <a href=\"../screens/ru/ru_mod_xml_path.png\">скриншот</a>.\
При правильном указании пути, <a href=\"../screens/ru/сfg_not_found_ru.png\">надпись</a> \"Конфигурационный файл не найден!\" должна исчезнуть."
            }

        ]
    }

    ListElement {
        categoryName: "Создание модификации"
        collapsed: true
        subItems: [
            ListElement {
                itemName: "Для создания модификации необходимо выполнить настройку приложения. \
Если приложение настроено, то необходимо выбрать \"Файл\"-> \"Новый проект\". Далее необходимо \
выбрать рабочую папку и название мода. <a href=\"../screens/ru/new_proj_ru.gif\">Видео</a>. Примечание: опция \"Скопировать файлы\" копирует все \
аудиофайлы в рабочую папку проекта. Рекомендуется к включению."
            },
            ListElement {
                itemName: "После создания нового проекта, приложение покажет доступные для модификации игровые события в левой части экрана. \
<a href=\"../screens/ru/available_to_mod.png\">Скриншот</a>. Для звуковой модификации какого-либо события, нажмите на него левой кнопкой мыши. \
Для быстрой навигации по событиям, есть возможность поиска по названию, для этого нажмите правую кнопку мыши на списке событий. \
<a href=\"../screens/ru/event_list_op_ru.gif\">Видео</a>."
            },
            ListElement {
                itemName: "После выбора события, озвучку которого вы собираетесь модифицировать, можно приступать к его редактированию. \
В центральной части экрана появится рабочая зона т.н. \"цепочек\" условий(или уточнений), при котором будет проигрываться тот или иной звук. \
Начальное уточнение называется \"По умолчанию (*)\", это условие всегда выполняется. Однако к нему можно добавить другие различные уточнения, к примеру\
 определенное название корабля. Рассмотрим событие \"Бой начинается!\". Модифицируем его таким образом, что на корабле Graf Zeppelin \
вместо \"Бой начинается!\" будет звучать немецкий гимн."
            },
            ListElement {
                itemName: "Для этого необходимо добавить уточнение - Ship Name, и в нем найти корабль Graf_Zeppelin. Нажатие на кнопку \">>\" \
покажет доступные для этого события условия. (примечание: в каждой колонке \
уточнений также доступен поиск по нажатию правой кнопки мыши). Далее для модификации необходимо выбрать как минимум по одному\
 уточнению в каждой колонке. Выберем желаемую цепочку и добавим ее для модификации нажатием кнопки\
 \"Добавить путь\". <a href=\"../screens/ru/graf_zeppelin_ru.gif\">Видео</a>."
            },
            ListElement {
                itemName: "Предположим, что кроме Graf_Zeppelin мы хотим добавить свою озвучку начала боя еще для кораблей Bismarck и Tirpitz. \
Найдем их при помощи поиска и добавим оба одновременно с помощью кнопки ctrl. (примчание: также возможно использовать кнопку shift для выделения\
 всего списка немецких кораблей) Далее аналогично предыдущему пункту дополняем цепочку и добавляем полученный путь.\
 <a href=\"../screens/ru/event_list_op_ctrl_ru.gif\">Видео</a>."
            }
        ]
    }
    ListElement {
        categoryName: "Работа с файлами и генерация мода"
        collapsed: true
        subItems: [
            ListElement {
                itemName: "Для добавления своих аудиофайлов необходимо выбрать желаемую цепочку и нажать на кнопку \"...\". Вы попадете на\
 окно выбора файлов для данной цепочки. Сюда можно добавлять файлы как перетаскиванием мыши, так и с помощью кнопки \"Выберите файлы\". После\
 выбора файлов нажмите кнопку \"OK\" и вы увидите что файлы добавились в таблицу путей. Поддерживаются форматы *.mp3 и *.wav. <a href=\"../screens/ru/nemez_gimn_op_ctrl_ru.gif\">Видео</a>. \
(примечание: здесь также можно заметить, что если опция \"Копировать файлы\" включена то файлы сразу копируются в папку проекта)"
            },
            ListElement {
                itemName: "После добавления файлов данное событие пометится как модифицированное (белым цветом). Приступим к генерации мода.\
Для этого выберем \"Файл\" -> \"Сгенерировать мод\". Мы попадем на окно генерации мода. "
            },
            ListElement {
                itemName: "В окне генерации мода есть вывод отладочной информации WWISE и полосы загрузки процесса создания модификации.\
 Для генерации мода необходимо нажать кнопку \"Сгенерировать\". Ваши звуковые файлы автоматически сгенерируются в формат, поддерживаемый игрой - \".wem\" и создастся конфигурационный файл модификации. \
Во избежание ошибок и неправильной работы игры, конфигурационный файл не рекомендуется редактировать напрямую. \
Для этих целей - создания и редактирования модификаций - и предназначен Sound Mod Creator.\
 После генерации модификация сразу же скопируется в папку игры и будет \
доступна в игре с момента ее следующего запуска. Также после генерации будет выведен путь, куда попала модификация. <a href=\"../screens/ru/nemez_gen.gif\">Видео</a>."
            }
        ]
    }
    ListElement {
        categoryName: "Дополнительные функции Sound Mod Creator.\n Экспорт и импорт проектов."
        collapsed: true
        subItems: [
            ListElement {
                itemName: "Для того, чтобы поделиться с кем-либо проектом модификации, в настоящей программе существуют функции импорта и экспорта проекта.\
 Например, если кто-нибудь захочет внести изменения в вашу модификацию, то вы можете поделиться с этим человеком своим проектом с помощью экспорта проекта."
            },
            ListElement {
                itemName: "Для экспорта необходимо нажать \"Файл\" -> \"Экспорт проекта\". В открывшемся окне вы можете задать другое имя модификации, если это необходимо. \
Далее нажмите кнопку \"Сгенерировать\" и подождите окончания процесса генерации. После этого в папке вашего проекта появится папка %название_мода%_EXPORT. Ее и необходимо \
передавать другим желающим редактировать или использовать ваш мод. В этой папке будет папка Audio, в которой находятся ваши аудиофайлы \
Также там появится файл с названием вашей модификации и расширением .rve. Этот формат пригоден для импорта в Sound Mod Creator на любой другой системе. <a href=\"../screens/ru/german_mod_export.gif\">Видео</a>."
            },
            ListElement {
                itemName: "Импорт проекта можно осуществить только из файла с расширением \".rve\". Для этого выберите \"Файл\" -> \"Импорт проекта\", и в открывшемся окне выберите \
 файл расширения \"*.rve\". После этого в папке, где был выбран этот файл создастся полноценный проект на основе импортированной версии. Папку AudioExport и файл .rve теперь можно удалить. \
<a href=\"../screens/ru/german_mod_import.gif\">Видео</a>."
            }
        ]
    }
    ListElement {
        categoryName: "Дополнительные функции Sound Mod Creator.\n Возможные ошибки."
        collapsed: true
        subItems: [
            ListElement {
                itemName: "В процессе работы над модом, могут возникнуть какие-либо проблемы, такие как - пропажа файлов из каталога, ошибка конвертации WWISE, ошибка конвертации mp3 файлов в wav,\
 и другие."
            },
            ListElement {
                itemName: "Ошибка конвертации файлов: При добавлении звукового файла, файл может пометиться красной рамкой и к нему будет добавлена надпись \"Ошибка: файл не найден\". Это может произойти\
 в случае, если ffmpeg.exe не находится в том же каталоге, что и Sound Mod Creator.exe. <a href=\"../screens/ru/error_not_found.gif\">Видео</a>."
            },
            ListElement {
                itemName: "Ошибка пропавших файлов: После нажатия кнопки \"Сгенерировать мод\" может появиться диалог - \"Ошибка, отсутствуют файлы для следующий путей:\". Далее будет перечислен список\
 всех событий и цепочек уточнений для которых файлы не были найдены. Устраните эти ошибки путем удаления файлов из цепочки, либо переместите пропавшие файлы обратно в папку Audio. <a href=\"../screens/ru/missing_file.gif\">Видео</a>."
            }
        ]
    }
}
