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

#ifndef PLASMA_NM_PASSWORDDIALOG_H
#define PLASMA_NM_PASSWORDDIALOG_H

#include <QtNetworkManager/settings/connection.h>

#include <KDialog>

#include <kdemacros.h>

namespace Ui {
class PasswordDialog;
}

class KDE_EXPORT PasswordDialog : public KDialog
{
    Q_OBJECT
public:
    explicit PasswordDialog(const NetworkManager::Settings::Setting::Ptr &setting, const QStringList & neededSecrets,
                            const QString & ssid = QString(), QWidget *parent = 0);
    ~PasswordDialog();
    QVariantMap secrets() const;

private slots:
    void showPassword(bool show);

private:
    Ui::PasswordDialog *ui;
    QStringList m_neededSecrets;
};

#endif // PLASMA_NM_PASSWORDDIALOG_H