import QtQuick 2.0

ListModel {
    id: nestedModel
    ListElement {
        categoryName: "Application description"
        collapsed: true
        subItems: [
            ListElement {
                itemName: "This is a tool for sound and effects modding in World of Warships.\
\nYou can replace any sound for your custom audio files or turn sound off."
            },
            ListElement{
                itemName:"You may familiarize yourself with this program in the next sections below."
            },
            ListElement{
                itemName:"In this manual screenshots and shorts videos are being used. \
It will be marked as link following way: <a href=\"../screens/en/test.png\">click to view screenshot example</a>, <a href=\"../screens/en/example.gif\">click to view video example</a>."
            }

        ]
    }

    ListElement {
        categoryName: "Preparations before mod creation"
        collapsed: true
        subItems: [
            ListElement {
                itemName: "You need to tune in the app for proper working process. \
Go to \"Options\" -> \"Settings\". <a href=\"../screens/en/options_en.gif\">Video</a>."
            },
            ListElement {
                itemName: "Then you need to specify paths for the game, WWISE and WWISE project."
            },
            ListElement {
                itemName: "Path for the game needs to be specified as this: <a href=\"../screens/en/game_dir_en.png\">screenshot</a>."
            },
            ListElement {
                itemName: "Path for WWISE directory needs to be specified as this:<a href=\"../screens/en/wwise_dir_en.png\">screenshot</a>.\
 If the path was specified correctly, <a href=\"../screens/en/wwise_not_found_en.png\">label</a> \"Can not find wwise-cli!\" will disappear. \
Please pay attention to WWISE version, it should be 2016.2.1.5995."
            },
            ListElement {
                itemName: "Path for WWISE project file needs to be specified as this: <a href=\"../screens/en/wwise_proj_en.png\">screenshot</a>.\
 If the path was specified correctly, <a href=\"../screens/en/wwiseproj_not_found_en.png\">label</a> \"Wwise project is not set!\" will disappear. "
            },
            ListElement {
                itemName: "Path for mod.xml file needs to be specified as this: <a href=\"../screens/en/en_mod_xml_path.png\">screenshot</a>.\
 If the path was specified correctly, <a href=\"../screens/en/сfg_not_found_en.png\">label</a> \"Can not find config file!\" will disappear."
            }
        ]
    }

    ListElement {
        categoryName: "Mod creation"
        collapsed: true
        subItems: [
            ListElement {
                itemName: "To create a modification, you need to configure the application. \
If the application is configured, you must select \"File \" -> \"New Project \". Further it is necessary \
select the working folder and the name of the mod. <a href=\"../screens/en/new_proj_en.gif\">Video</a>. Note: the \"Copy files\" option copies all \
audio files in the working folder of the project. Recommended for inclusion."
            },
            ListElement {
                itemName: "After creating a new project, the application will show the game events available for modification on the left side of the screen. \
<a href=\"../screens/en/available_to_mod.png\"> screenshot </a>. To sound an event, click on it with the left mouse button. \
To quickly navigate through the events, there is the ability to search by name, to do this, right-click on the list of events. \
<a href=\"../screens/en/event_list_op_en.gif\"> Video </a>."
            },
            ListElement {
                itemName: "After selecting an event, the voice acting of which you are going to modify, you can start editing it. \
In the central part of the screen, the working area of ​​the so-called \"chains \" of conditions (or refinements), in which this or that sound will be played. \
The initial refinement is called \"Default (*) \", this condition is always satisfied. However, you can add other different refinements to it, for example \
 the specific name of the ship. Consider the event \"The Battle Begins!\". Modify it in such a way that on the ship Graf Zeppelin \
instead of \"The battle begins!\" will sound a German anthem."
            },
            ListElement {
                itemName: "To do this, add a clarification - Ship Name, and in it to find the ship Graf_Zeppelin. Clicking on the \" >> \"button \
will show the conditions available for this event. (note: in each column \
refinements are also available for searching by clicking the right mouse button). Further for modification it is necessary to choose at least one \
in each column. Select the desired chain and add it for modification by pressing the \
\"Add path \". <a href=\"../screens/en/graf_zeppelin_en.gif\"> Video </a>."
            },
            ListElement {
                itemName: "Suppose that, in addition to Graf_Zeppelin, we want to add our voice-over-the-scenes to the battle for the ships Bismarck and Tirpitz. \
Find them by searching and add both at the same time with the ctrl button. (it's also possible to use the shift button to highlight \
  of the entire list of German ships). Further, similarly to the previous item, we add the chain and add the resulting path. \
  <a href=\"../screens/en/event_list_op_ctrl_en.gif\"> Video </a>."
            }
        ]
    }
    ListElement {
        categoryName: "Working with files and generating a mod"
        collapsed: true
        subItems: [
            ListElement {
                itemName: "To add your audio files you need to select the desired chain and click on the \"... \" button. You will be taken to \
the window for selecting files for a given conversation. You can add files here either by dragging the mouse or using the \"Select files \" button. After\
select the files, click the \"OK \" button and you will see that the files have been added to the path table. The formats * .mp3 and * .wav are supported. <a href=\"../screens/en/nemez_gimn_op_ctrl_en.gif\"> Video </a>. \
(note: here you can also see that if the \"Copy files\" option is turned on, then the files are immediately copied to the project folder)"
            },
            ListElement {
                itemName: "After adding files, this event is marked as modified (in white color). Let's proceed to generate the mod. \
To do this, choose \"File \" -> \"Generate Mode \". We'll get to the mod generation window. "
            },
            ListElement {
                itemName: "In the window of the mode generation there is a conclusion of the debugging information WWISE and the load strip of the creation process of the modification. \
 To generate a mod, you need to click the \"Generate\" button. Your audio files will automatically be generated in a format supported by the game - \". Wem \" and a configuration file for the modification will be created.\
 To avoid errors and malfunction of the game, the configuration file is not recommended to be edited directly. \
For these purposes - creating and editing modifications - and designed by Sound Mod Creator. \
 After the generation, the modification is immediately copied to the game folder and will be \
Available in the game since its next launch. Also after generation, the path will be displayed, where the modification came. <a href=\"../screens/en/nemez_gen.gif\"> Video </a>."
            }
        ]
    }
    ListElement {
        categoryName: "Additional functions of Sound Mod Creator. \n Export and import of projects."
        collapsed: true
        subItems: [
            ListElement {
                itemName: "In order to share modifications with someone, there are functions of importing and exporting the project in this program. \
  For example, if someone wants to make changes to your modification, then you can share this project with your project by exporting it."
            },
            ListElement {
                itemName: "To export, you must click \"File \" -> \"Export Project \". In the window that opens, you can specify a different modification name, if necessary. \
Next, click the \"Generate\" button and wait for the generation process to finish. After that, the folder% name_name% _EXPORT appears in the folder of your project. It is necessary and \
transfer to others who wish to edit or use your mod. In this folder will be the folder Audio, which contains your audio files \
Also there will be a file with the name of your modification and the extension .rve. This format is suitable for import into Sound Mod Creator on any other system. <a href=\"../screens/en/german_mod_export.gif\"> Video </a>."
            },
            ListElement {
                itemName: "You can import the project only from a file with the extension \". Rve \". To do this, select \"File \" -> \"Import Project \", and in the window that opens, select \
  extension file \"*. rve \". After that, in the folder where this file was selected, a full-fledged project based on the imported version will be created. The AudioExport folder and the .rve file can now be deleted. \
<a href=\"../screens/en/german_mod_import.gif\"> Video </a>."
            }
        ]
    }
//    ListElement {
//        categoryName: "Additional functions of Sound Mod Creator. \n Possible errors."
//        collapsed: true
//        subItems: [
//            ListElement {
//                itemName: "In the process of working on the mod, there can be any problems, such as - missing files from the directory, conversion error WWISE, error converting mp3 files to wav, \
//  and others."
//            },
//            ListElement {
//                itemName: "Error converting files: When adding a sound file, the file can be marked with a red border and to it will be added the inscription \"Error: file not found \". This can happen \
//  in case ffmpeg.exe is not in the same directory as Sound Mod Creator.exe. <a href=\"../screens/ru/error_not_found.gif\"> Video </a>."
//            },
//            ListElement {
//                itemName: "Error of missing files: After clicking the \"Generate mod \" button the dialog - \"Error, missing files for the following paths: \" may appear. Then the list \
//  all events and chains of refinements for which files were not found. Eliminate these errors by deleting files from the chain, or move the missing files back to the Audio folder. <a href=\"../screens/ru/missing_file.gif\"> Video </a>."
//            }
//        ]
//    }
}
