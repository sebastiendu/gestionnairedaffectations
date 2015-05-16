#include "plansvgimageprovider.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QSvgRenderer>
#include <QPainter>
#include <QtDebug>

PlanSVGImageProvider::PlanSVGImageProvider() :
    QQuickImageProvider(QQuickImageProvider::Image)
{

}

QImage PlanSVGImageProvider::requestImage(const QString & id, QSize * size, const QSize & requestedSize) {
    size->setHeight(requestedSize.height() > 0 ? requestedSize.height() : 100);
    size->setWidth(requestedSize.width() > 0 ? requestedSize.width() : 100);
    QImage image(*size,QImage::Format_ARGB32_Premultiplied);
    QSqlQuery query;
    query.prepare("select plan from evenement where id=?");
    query.addBindValue(id.toInt());
    if (query.exec()) {
        if (query.next()) {
            const QByteArray content = query.value(0).toByteArray();
            QSvgRenderer renderer(content);
            QPainter painter(&image);
            renderer.render(&painter);
        } else {
            qDebug() << "Aucun evenement n'a id = " << id;
        }
    } else {
        qDebug() << "Echec d'execution de la requète SQL de récupération du plan SVG de l'évènement numéro" << id << " : " << query.lastError();
    }
    return image;
}
