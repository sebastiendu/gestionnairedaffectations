#include "plansvgimageprovider.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QSvgRenderer>
#include <QPainter>

PlanSVGImageProvider::PlanSVGImageProvider() :
    QQuickImageProvider(QQuickImageProvider::Image)
{

}

QImage PlanSVGImageProvider::requestImage(const QString & id, QSize * size, const QSize & requestedSize) {
    if (requestedSize.isValid()) {
        size->setHeight(requestedSize.height());
        size->setWidth(requestedSize.width());
    } else {
        size->setHeight(100);
        size->setWidth(100);
    }
    QImage image(*size,QImage::Format_ARGB32_Premultiplied);
    image.fill(Qt::transparent);
    QPainter painter(&image);
    QSqlQuery query;
    if (query.prepare("select plan from evenement where id=?")) {
        query.addBindValue(id.toInt());
        if (query.exec()) {
            if (query.next()) {
                const QByteArray content = query.value(0).toByteArray();
                if (!content.isEmpty()) {
                    QSvgRenderer renderer(content);
                    if (renderer.isValid()) {
                        renderer.render(&painter);
                        if (renderer.defaultSize().width() != renderer.defaultSize().height()) {
                            painter.drawText(image.rect(), Qt::AlignCenter, "Le plan n'est pas carré");
                        }
                    } else {
                        painter.drawText(image.rect(), Qt::AlignCenter, "Le plan fourni n'est pas un document SVG valide");
                    }
                } else {
                    painter.drawText(image.rect(), Qt::AlignCenter, "Le plan n'a pas été fourni");
                }
            } else {
                painter.drawText(image.rect(), Qt::AlignCenter, "Aucun evenement n'a id = " + id);
            }
        } else {
            painter.drawText(image.rect(), Qt::AlignCenter, "Echec d'execution de la requète SQL de récupération du plan SVG de l'évènement numéro" + id + " : " + query.lastError().text());
        }
    } else {
        painter.drawText(image.rect(), Qt::AlignCenter, "Echec de préparation de la requète SQL de récupération du plan SVG de l'évènement : " + query.lastError().text());
    }
    return image;
}
