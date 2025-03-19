# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)
project(cuteatum LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 DBus Mqtt)
find_package(qatemcontrol)

find_library(ATEM_LIBRARY qatemcontrol HINTS ${ATEM_LIBRARY})
if( ${ATEM_LIBRARY} STREQUAL "ATEM_LIBRARY-NOTFOUND")
    message("Please set ATEM_LIBRARY variable to location of libced")
endif()

qt_standard_project_setup(REQUIRES 6.6)

qt_add_executable(cuteatum
    src/main.cpp
    src/cutemqttclient.cpp src/cutemqttclient.h
    src/servicediscovery.cpp src/servicediscovery.h
    src/settings.cpp src/settings.h
    src/animationcurve.h src/animationcurve.cpp

    src/libcutegenericmodel/abstractobjectmodel.h
    src/libcutegenericmodel/abstractobjectmodel.cpp

    src/ssboxes.h src/ssboxes.cpp
    src/ssboxesmodel.h src/ssboxesmodel.cpp
)

qt_add_qml_module(cuteatum
    URI ca
    VERSION 1.0
    QML_FILES qml/main.qml
    QML_FILES qml/components/BlinkButton.qml
    QML_FILES qml/components/DownstreamKeyBaseControls.qml
    QML_FILES qml/components/DragBox.qml
    QML_FILES qml/components/InputButtonGroup.qml
    QML_FILES qml/components/InputButton.qml
    QML_FILES qml/components/InputButtonRepeater.qml
    QML_FILES qml/components/InputMenuItem.qml
    QML_FILES qml/components/MediaPlayerBaseControls.qml
    QML_FILES qml/components/OutputButtonGroup.qml
    QML_FILES qml/components/OutputMenuItem.qml
    QML_FILES qml/components/SliderTBar.qml
    QML_FILES qml/components/SnapToGrid.qml
    QML_FILES qml/components/SuperSourceBox.qml
    QML_FILES qml/components/TimelineBoxProxy.qml
    QML_FILES qml/components/ToggleButton.qml
    QML_FILES qml/components/UpstreamKeyBaseControls.qml
    QML_FILES qml/components/Vector4dAnimation.qml
    QML_FILES qml/dialogs/ConnectDialog.qml
    QML_FILES qml/drawers/DownstreamKeyDrawer.qml
    QML_FILES qml/drawers/KeySourceDrawer.qml
    QML_FILES qml/drawers/MacroDrawer.qml
    QML_FILES qml/drawers/UpstreamKeyDrawer.qml
    QML_FILES qml/models/ListModelEasing.qml
    QML_FILES qml/models/ListModelKeyType.qml
    QML_FILES qml/models/ListModelSuperSourceBoxes.qml
    QML_FILES qml/models/ListModelTransitions.qml
    QML_FILES qml/pages/PageMain.qml
    QML_FILES qml/pages/PageSettings.qml
    QML_FILES qml/pages/PageSuperSource.qml    
)

set_target_properties(cuteatum PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(cuteatum PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Quick
    Qt::QuickControls2
    Qt::Mqtt
    Qt::DBus
    ${ATEM_LIBRARY}
)

include(GNUInstallDirs)
install(TARGETS cuteatum
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
