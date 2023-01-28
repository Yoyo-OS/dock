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
    data1->setIconColor(QColor("#8585FC"));
    data1->setIconSource("qrc:/dock/images/sidebar/dock.svg");
    data1->setPage("qrc:/dock/qml/main.qml");
    data1->setCategory("Display and appearance");
    dataList.append(data1);
    return dataList;
}

void DockPlugin::initialize()
{
    // QML
    const char *uri = "Yoyo.Settings";
    qmlRegisterType<Dock>(uri, 1, 0, "Dock");
}
