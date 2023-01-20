#include "notifications.h"

Notifications::Notifications(QObject *parent)
    : QObject(parent)
    , m_iface("com.yoyo.Notification",
              "/Notification",
              "com.yoyo.Notification", QDBusConnection::sessionBus())
{
    m_doNotDisturb = m_iface.property("doNotDisturb").toBool();

    QDBusConnection::sessionBus().connect("com.yoyo.Notification",
                                          "/Notification",
                                          "com.yoyo.Notification",
                                          "doNotDisturbChanged", this, SLOT(onDBusDoNotDisturbChanged()));
}

bool Notifications::doNotDisturb() const
{
    return m_doNotDisturb;
}

void Notifications::setDoNotDisturb(bool enabled)
{
    m_doNotDisturb = enabled;

    QDBusInterface iface("com.yoyo.Notification",
                         "/Notification",
                         "com.yoyo.Notification", QDBusConnection::sessionBus());

    if (iface.isValid()) {
        iface.asyncCall("setDoNotDisturb", enabled);
    }

    emit doNotDisturbChanged();
}

void Notifications::onDBusDoNotDisturbChanged()
{
    m_doNotDisturb = m_iface.property("doNotDisturb").toBool();
    emit doNotDisturbChanged();
}
