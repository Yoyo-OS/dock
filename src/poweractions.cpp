#include "poweractions.h"
#include <QCommandLineParser>
#include <QDBusInterface>
#include <QApplication>
#include <QProcess>

const static QString s_dbusName = "com.yoyo.Session";
const static QString s_pathName = "/Session";
const static QString s_interfaceName = "com.yoyo.Session";

PowerActions::PowerActions(QObject *parent)
    : QObject(parent)
{

}

void PowerActions::shutdown()
{
    QDBusInterface iface(s_dbusName, s_pathName, s_interfaceName, QDBusConnection::sessionBus());
    if (iface.isValid()) {
        iface.call("powerOff");
    }
}

void PowerActions::logout()
{
    QDBusInterface iface(s_dbusName, s_pathName, s_interfaceName, QDBusConnection::sessionBus());
    if (iface.isValid()) {
        iface.call("logout");
    }
}

void PowerActions::reboot()
{
    QDBusInterface iface(s_dbusName, s_pathName, s_interfaceName, QDBusConnection::sessionBus());
    if (iface.isValid()) {
        iface.call("reboot");
    }
}

void PowerActions::lockScreen()
{
    QProcess::startDetached("yoyo-screenlocker", QStringList());
}

void PowerActions::suspend()
{
    QDBusInterface iface(s_dbusName, s_pathName, s_interfaceName, QDBusConnection::sessionBus());

    if (iface.isValid()) {
        iface.call("suspend");
    }
}
