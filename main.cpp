#include "gestionnairedaffectations.h"
#include "plansvgimageprovider.h"
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTranslator>

int main(int argc, char *argv[])
{
    GestionnaireDAffectations app(argc, argv); // Notre application est un objet GestionnaireDAffectations

    QTranslator translator;
    if (translator.load(QLocale(), "gestionnairedaffectations", "_", ":/traductions")) {
        app.installTranslator(&translator);
    }

    QQmlApplicationEngine engine;  // On declare le moteur de l'application, qui permettra de charger l'interface QML
    engine.rootContext()->setContextProperty("app", &app); // On fait correspondre la variable "app" utilisée dans le .qml avec notre application crée en C++

    engine.addImageProvider(QLatin1String("plan"), new PlanSVGImageProvider);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml"))); // On charge l'interface à partir du .qml

    return app.exec(); // On execute l'application
}
