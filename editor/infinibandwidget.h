/*
    Copyright 2013 Lukas Tinkl <ltinkl@redhat.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef PLASMA_NM_INFINIBAND_WIDGET_H
#define PLASMA_NM_INFINIBAND_WIDGET_H

#include <QtGui/QWidget>

#include <NetworkManagerQt/settings/setting.h>

#include "settingwidget.h"

namespace Ui
{
class InfinibandWidget;
}

class InfinibandWidget : public SettingWidget
{
    Q_OBJECT
public:
    explicit InfinibandWidget(const NetworkManager::Settings::Setting::Ptr &setting = NetworkManager::Settings::Setting::Ptr(), QWidget* parent = 0, Qt::WindowFlags f = 0);
    virtual ~InfinibandWidget();

    void loadConfig(const NetworkManager::Settings::Setting::Ptr &setting);

    QVariantMap setting(bool agentOwned = false) const;

private:
    Ui::InfinibandWidget * m_ui;
};

#endif // PLASMA_NM_INFI_WIDGET_H