TEMPLATE = app

QT += qml quick sql svg xml

SOURCES += main.cpp \
    sqlquerymodel.cpp \
    gestionnairedaffectations.cpp \
    settings.cpp \
    plansvgimageprovider.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

OTHER_FILES += \
    nouvelevenement.qml \
    corbeille.png \
    marqueur.qml \
    rouge.png \
    marqueurs/rouge_brillant.png

HEADERS += \
    sqlquerymodel.h \
    gestionnairedaffectations.h \
    settings.h \
    plansvgimageprovider.h
