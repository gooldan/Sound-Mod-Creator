
var ruHelp = 'Эта программа для модифицирования звука и эффектов в игре World of Warships. \

Вы можете заменить любые звуки игры на свои собственные или отключить их.\
Чтобы начать работу нажмите "Файл" - "Создать новый проект", выберите рабочую папку и название вашего мода.\


Далее, в левой части экрана вы увидите все события, которые можно модифицировать. Также доступны вкладки "Voice", "SFX" и "Loop".\

Нажмите на любое событие левой кнопкой мыши и вы увидите что оно содержит в центральной части. Событие без модификаций всегда содержит стандартное состояние ("По умолчанию (*)"), \
оно будет проигрываться по умолчанию при возникновении данного события, \
и вы можете изменить как его, так и добавить свои собственные условия. Для этого нажмите кнопку ">>" и в списке доступных состояний для данного события вы\
можете выбрать любое.

Для модификации выбраной цепочки состояний выберите цепочку и нажмите на кнопку "Добавить путь". В таблицу добавится выбранная вами цепочка состояний.\
К этой цепочке состояний вы можете добавить один или несколько звуков в формате MP3 и WAV. Для этого нажмите кнопку "..." и в открывшемся окне кнопку "Выберите файлы".
Для сохранения выбранных файлов нажмите кнопку "ОК".


После внесенных модификаций вы можете сохранить проект через "Файл" - "Сохранить проект", и сгенирировать модификацию. Для генерации нажмите кнопку "Сгенерировать"\
Далее в открывшемся окне "Сгенерировать". Генерация мода началась, откиньтесь на спинку стула и подождите пока генерация мода не завершится. Далее нажмите кнопку "Готово".

Готово! Ваш мод доступен к использованию и находится в папке с игрой.'

var enHelp = 'This is a tool for modding sounds in World of Warships. You can change any outcouming sound from the game to the your own.\
To start modding sound press "File" - "Create new project", select working directory and type in name of your mod.\


Then, you will see all moddable events of the game in left tab, with tabs "Voice", "SFX" and "Loop".\
Press any event and you will see its content in the middle tab. Empty event always has a default sound at start, but you can change it. \

Firstly, you will see "Default (*)". This sound will play on all occurences of selected event. To change some conditions and add states, press\
">>" button. You will see list of available states for this event. Press on preferable state and it will add new state to the middle list.


Then you can select some state\'s content and press the "Add path" button. Selected chain of states will be added to the table below list.\

In this list you will see selected chain and you can add sounds to it. Press "..." button and in the new windows press "Choose files".\


After choosing files, it will be associated with this chain of states. After all tweaks you can choose "File" - "Generate" and press "Generate button".
Now mod is generating, wait and you can go for a cup of tea/coffee. When generation is completed press the button "Done" and your mod will be in the game directory.\
'
function incompatibleVersion(lang,errorVersion,currentVersion)
{
    return lang == 0 ? "This project was created in Sound Mod Cretor version: '" + errorVersion + "' which\
 is incompatible with the current version: '" + currentVersion +"'.\
\n Consider 'Import project' option with '*.rve' file of this project \
or ask mod's author." :
                                              "Данный проект был создан в Sound Mod Cretor версии: '" + errorVersion + "', которая \
несовместима с текущей версией: '" + currentVersion +"'.\
\nВоспользуйтесь фунцкией 'Импорт проекта' с файлом расширения '*.rve' этого проекта \
или обратитесь к создателю мода."
}
