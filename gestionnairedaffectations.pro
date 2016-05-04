TEMPLATE = app

QT += qml quick sql svg xml

SOURCES += main.cpp \
    sqlquerymodel.cpp \
    gestionnairedaffectations.cpp \
    settings.cpp \
    plansvgimageprovider.cpp \
    abstracttablemodel.cpp \
    toursparpostemodel.cpp \
    sortfilterproxymodel.cpp \
    modeledelalistedespostesdelevenementparheure.cpp \
    sqltablemodel.cpp

RESOURCES += \
    gestionnairedaffectations.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    sqlquerymodel.h \
    gestionnairedaffectations.h \
    settings.h \
    plansvgimageprovider.h \
    abstracttablemodel.h \
    toursparpostemodel.h \
    sortfilterproxymodel.h \
    modeledelalistedespostesdelevenementparheure.h \
    sqltablemodel.h

TRANSLATIONS = \
    traductions/gestionnairedaffectations_eu.ts

lupdate_only {
SOURCES += \
    *.qml \
    *.js
}

DISTFILES += \
    PlanDeLEvenement.qml
