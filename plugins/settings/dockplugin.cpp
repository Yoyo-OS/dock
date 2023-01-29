#include "dockplugin.h"
#include "dock.h"
DockPlugin::DockPlugin(QObject *parent)
    : QObject{parent}
{

}

QList<QObject*> DockPlugin::dataList()
{
    QList<QObject*> dataList;
    DataObject *data1 = new DataObject(this);
    data1->setName("dock");
    data1->setTitle(tr("Dock"));
    data1->setIconId("\ueb9b");
    data1->setPage("qrc:/dock/qml/main.qml");
    data1->setCategory(DISPLAYANDAPPEARANCE);
    dataList.append(data1);
    return dataList;
}

void DockPlugin::initialize()
{
    // QML
    const char *uri = "Yoyo.Settings";
    qmlRegisterType<Dock>(uri, 1, 0, "Dock");
}
