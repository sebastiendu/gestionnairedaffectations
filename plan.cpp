#include "plan.h"
#include <QSqlQuery>

Plan::Plan()
{

    QSqlQuery query;
    query.prepare("select * from poste where id=?"); // On séléctionne la liste des évenements
    query.exec();
    model = new SqlQueryModel;
    model->setQuery(query);


}
