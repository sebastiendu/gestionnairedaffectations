#ifndef PLANSVGIMAGEPROVIDER_H
#define PLANSVGIMAGEPROVIDER_H

#include <QQuickImageProvider>

class PlanSVGImageProvider : public QQuickImageProvider
{
public:
    explicit PlanSVGImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // PLANSVGIMAGEPROVIDER_H
