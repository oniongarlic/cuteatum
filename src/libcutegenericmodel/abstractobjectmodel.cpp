#include "abstractobjectmodel.h"

#include <QDebug>
#include <QMetaProperty>
#include <QTime>
#include <QDateTime>
#include <QVector2D>
#include <QVector3D>
#include <QVector4D>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

using namespace Cute;

AbstractObjectModel::AbstractObjectModel(const QByteArray name, QObject *parent)
    : QAbstractListModel(parent),
    m_metaname(name),
    m_has_key(false),
    m_key_name(nullptr),
    m_has_id(false),
    m_meta(nullptr)
{    
    resolveProperties();
}

void AbstractObjectModel::resolveProperties()
{
    auto type=QMetaType::fromName(m_metaname);
    if (!type.isValid()) {
        qFatal() << "Type" << m_metaname << "is not valid!";
        return;
    }
    m_meta=type.metaObject();
    Q_ASSERT(m_meta);
    
    for (int i=0;i<m_meta->propertyCount();i++) {
        QMetaProperty p=m_meta->property(i);
        
        qDebug() << i << p.name() << p.isReadable() << p.isWritable() << p.typeName() << p.isEnumType() << p.isStored() << p.hasNotifySignal();
        
        m_properties.insert(Qt::UserRole+i, p.name());
        if (QString(p.name())=="id" && p.metaType().id()==QMetaType::Int) {
            m_has_id=true;
        }
    }
}

void AbstractObjectModel::createKeyIndex()
{
    if (!m_has_key || !m_key_name)
        return;
    
    m_index.clear();
    
    for (int i=0;i<m_data.size();i++) {
        QObject *o=m_data.at(i);
        const QString key=o->property(m_key_name).toString();
        
        m_index.insert(key, i);
    }
}

int AbstractObjectModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    
    return m_needle.isNull() ? m_data.size() : m_filter_index.size();
}

QVariant AbstractObjectModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(m_meta);
    
    if (!index.isValid())
        return QVariant();
    
    int pid=role-Qt::UserRole;
    
    const QMetaProperty p=m_meta->property(pid);
    
    if (!p.isValid()) {
        qWarning() << "Invalid role for property requested" << role << pid;
        return QVariant();
    }
    
    const QObject *o=m_data.at(mapIndex(index.row()));
    
    if (!o)
        return QVariant();
    
    return formatProperty(o, &p);
}

QObject *AbstractObjectModel::getKey(const QString key) const
{
    if (m_has_key==false) {
        qWarning("Key indexing not enabled for model");
        return nullptr;
    }
    
    return getObject(m_index.value(key, -1));
}

QObject *AbstractObjectModel::getId(int id)
{
    if (m_has_id==false) {
        qWarning("ID not enabled for model");
        return nullptr;
    }
    
    for (int i = 0; i < m_data.size(); ++i) {
        QObject *o=m_data.at(i);
        int oid=o->property("id").toInt();
        if (oid==id)
            return o;
    }
    return nullptr;
}

QObject *AbstractObjectModel::operator [](qsizetype index) const
{
    return getObject(index);
}

QHash<int, QByteArray> AbstractObjectModel::roleNames() const
{
    return m_properties;
}

bool AbstractObjectModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    bool r=false;
    
    if (!m_iswritable)
        return r;
    
    if (!index.isValid())
        return r;
    
    int row=mapIndex(index.row());
    
    if (row>m_data.size() || row<0)
        return r;
    
    int rid=role-Qt::UserRole;
    
    QObject *o=m_data.at(row);
    Q_ASSERT(o);
    
    QMetaProperty p=m_meta->property(rid);
    if (p.isWritable()) {
        const QVector<int>roles={ role };
        r=p.write(o, value);
        emit dataChanged(index, index, roles);
    }
    
    return r;
}

int AbstractObjectModel::mapIndex(int index) const
{
    if (m_needle.isNull())
        return index;
    
    return m_filter_index.at(index);
}

/**
 * @brief AbstractObjectModel::get
 * @param index
 * @return
 */
QVariantMap AbstractObjectModel::get(int index) const
{
    QVariantMap vm;
    
    if (m_needle.isNull()) {
        if (index>m_data.size() || index<0)
            return vm;
    } else {
        if (index>m_filter_index.size())
            return vm;
    }
    
    const QObject *o=m_data.at(mapIndex(index));
    
    for (int i=0;i<m_meta->propertyCount();i++) {
        QMetaProperty p=m_meta->property(i);
        if (!p.isReadable())
            continue;
        
        vm.insert(p.name(), p.read(o));
    }
    
    return vm;
}

/**
 * @brief AbstractObjectModel::getObject
 * @param index
 * @return
 */
QObject *AbstractObjectModel::getObject(int index) const
{
    if (index>m_data.size() || index<0)
        return nullptr;
    
    return m_data.at(mapIndex(index));
}

/**
 * @brief AbstractObjectModel::findKey
 * @param key
 * @return
 */
QVariantMap AbstractObjectModel::findKey(const QString key) const
{
    return get(m_index.value(key, -1));
}

/**
 * @brief AbstractObjectModel::indexKey
 * @param key
 * @return
 */
int AbstractObjectModel::indexKey(const QString key) const
{
    return m_index.value(key, -1);
}

void AbstractObjectModel::listenToObjectProperties(QObject *item)
{
    const QMetaObject* metaObject = item->metaObject();
    QStringList properties;
    for(int i = metaObject->propertyOffset(); i < metaObject->propertyCount(); ++i) {
        QMetaProperty p=metaObject->property(i);
        
        if (p.hasNotifySignal()) {
            const QMetaMethod s = p.notifySignal();
            connect(item, "2"+s.methodSignature() , this, SLOT(onItemPropertyChanged()));
        }
        
        properties << QString::fromLatin1(p.name());
    }
}

void AbstractObjectModel::refreshProperty(int index, int property)
{
    Q_UNUSED(property)
    QModelIndex i=createIndex(index, 0);
    
    if (!i.isValid())
        return;
    
    emit dataChanged(i, i);
}

bool AbstractObjectModel::append(QObject *item)
{
    if (m_data.contains(item)) {
        qWarning("Duplicates are not supported in model");
        return false;
    }
    
    int p=m_data.size();
    beginInsertRows(QModelIndex(), p, p);
    m_data.append(item);
    if (m_has_key && m_key_name) {
        const QString key=item->property(m_key_name).toString();
        m_index.insert(key, m_data.size()-1);
    }
    endInsertRows();
    
    listenToObjectProperties(item);
    
    emit countChanged(m_data.size());
    
    return true;
}

bool AbstractObjectModel::prepend(QObject *item)
{
    if (m_data.contains(item)) {
        qWarning("Duplicates are not supported in model");
        return false;
    }
    
    beginInsertRows(QModelIndex(), 0, 0);
    m_data.prepend(item);
    createKeyIndex();
    endInsertRows();
    
    listenToObjectProperties(item);
    
    emit countChanged(m_data.size());
    
    return true;
}

bool AbstractObjectModel::contains(QObject *item)
{
    return m_data.contains(item);
}

bool AbstractObjectModel::containsKey(const QString key) const
{
    return m_index.contains(key);
}

bool AbstractObjectModel::remove(int index)
{
    if (index>m_data.size() || index<0)
        return false;
    
    beginRemoveRows(QModelIndex(), index, index);
    QObject *o=m_data.at(index);
    if (o->parent()==this)
        o->deleteLater();
    else
        emit itemRemoved(o);
    m_data.removeAt(index);
    endRemoveRows();
    
    createKeyIndex();
    
    emit countChanged(m_data.size());
    
    return true;
}

void AbstractObjectModel::clear()
{
    beginResetModel();
    
    for (int i=0;i<m_data.size();i++) {
        QObject *o=m_data.at(i);
        if (o->parent()==this)
            o->deleteLater();
        else
            emit itemRemoved(o);
    }
    m_data.clear();
    m_index.clear();
    m_filter_index.clear();
    m_needle.clear();
    
    endResetModel();
    
    emit countChanged(m_data.size());
}

int AbstractObjectModel::count() const
{
    return m_needle.isNull() ? m_data.size() : m_filter_index.size();
}

bool AbstractObjectModel::compareProperty(QObject *v1, QObject *v2)
{
    auto v1v=v1->property(m_sort_property.toLocal8Bit().constData());
    auto v2v=v2->property(m_sort_property.toLocal8Bit().constData());
    
    switch (v1v.typeId()) {
    case QMetaType::Int:
        return v1v.toInt() < v2v.toInt();
        break;
    case QMetaType::UInt:
        return v1v.toUInt() < v2v.toUInt();
        break;
    case QMetaType::Double:
        return v1v.toDouble() < v2v.toDouble();
        break;
    case QMetaType::Float:
        return v1v.toFloat() < v2v.toFloat();
        break;
    case QMetaType::QString:
        return v1v.toString() < v2v.toString();
        break;
    case QMetaType::QTime:
        return v1v.toTime() < v2v.toTime();
        break;
    case QMetaType::QDateTime:
        return v1v.toDateTime() < v2v.toDateTime();
        break;
    default:        
        return v1v.toByteArray() < v2v.toByteArray();
    }
}

QVariant AbstractObjectModel::formatProperty(const QObject *data, const QMetaProperty *meta) const
{
    return meta->read(data);
}

QObject *AbstractObjectModel::fromVariantMap(const QVariantMap &map)
{
    Q_UNUSED(map);
    return nullptr;
}

bool AbstractObjectModel::formatToJson(const QString &key, const QVariant &value, QJsonValue &jvalue) const
{
    Q_UNUSED(key)
    Q_UNUSED(value)
    Q_UNUSED(jvalue)
    
    return false;
}

void AbstractObjectModel::onItemPropertyChanged()
{
    QObject* o=sender();
    
    int i=m_data.indexOf(o);
    if (i==-1) {
        qWarning() << "Unknown item sent a property change signal";
        return;
    }
    
    refreshProperty(i, 0);
}

void AbstractObjectModel::sortByProperty(const QString property, SortDirection by)
{
    m_sort_property=property;
    m_sort_dir=by;
    
    sortRefresh();
    searchRefresh();
}

void AbstractObjectModel::sortRefresh()
{
    beginResetModel();
    if (m_sort_dir==SortAsc)
        std::sort(m_data.begin(), m_data.end(), [this](QObject *v1, QObject *v2){ return compareProperty(v1,v2); });
    else
        std::sort(m_data.begin(), m_data.end(), [this](QObject *v1, QObject *v2){ return compareProperty(v2,v1); });
    endResetModel();
}

bool AbstractObjectModel::search(const QString property, const QVariant needle)
{
    m_needle=needle;
    m_haystack=property;
    
    return searchRefresh();
}

void AbstractObjectModel::clearSearch()
{
    clearFilter();
}

bool AbstractObjectModel::searchRefresh()
{
    if (m_needle.isNull()) {
        clearFilter();
        return false;
    }
    if (!m_needle.isValid()) {
        clearFilter();
        return false;
    }
    
    //bool isNumeric=false;
    //int num=m_needle.toInt(&isNumeric, 10);
    
    beginResetModel();
    
    m_filter_index.clear();
    
    for (int i=0;i<m_data.size();i++) {
        QObject *item=m_data.at(i);
        QVariant hs=item->property(m_haystack.toUtf8());
        if (!hs.isValid() || hs.isNull())
            continue;
        
        // XXX: Handle more types and comparision modes?
        switch ((QMetaType::Type)hs.typeId()) {
        case QMetaType::QString:
            if (hs.toString().contains(m_needle.toString().simplified(), Qt::CaseInsensitive)) {
                m_filter_index.append(i);
            }
            break;
        case QMetaType::Int:
            if (hs.toInt()==m_needle.toInt()) {
                m_filter_index.append(i);
            }
            break;
        case QMetaType::Float:
            if (hs.toFloat()==m_needle.toFloat()) { // xxx
                m_filter_index.append(i);
            }
            break;
        case QMetaType::Bool:
            if (hs.toBool()==m_needle.toBool()) {
                m_filter_index.append(i);
            }
            break;
        default:;
        }
    }
    
    endResetModel();
    emit countChanged(m_filter_index.size());
    
    return m_filter_index.size()>0 ? true : false;
}

void AbstractObjectModel::clearFilter()
{
    beginResetModel();
    m_filter_index.clear();
    m_needle.clear();
    m_haystack.clear();
    endResetModel();
    emit countChanged(m_data.size());
    return;
}

bool AbstractObjectModel::refresh(int index)
{
    QModelIndex i=createIndex(index, 0);
    
    if (!i.isValid())
        return false;
    
    emit dataChanged(i, i);
    
    return true;
}

QString AbstractObjectModel::toJson()
{
    QJsonArray a;
    
    for (int i=0;i<m_data.size();i++) {
        QJsonObject jo;
        QObject *item=m_data.at(i);
        
        for (auto i = m_properties.cbegin(), end = m_properties.cend(); i != end; ++i) {
            QVariantMap m;
            QString key=i.value();
            QVariant hs=item->property(i.value());
            if (!hs.isValid() || hs.isNull())
                continue;
            
            int t=hs.typeId();
            
            if (t>QMetaType::User) {
                
            }
            
            switch ((QMetaType::Type)t) {
            case QMetaType::QString:
                jo.insert(key, hs.toString());
                break;
            case QMetaType::Bool:
                jo.insert(key, hs.toBool());
                break;
            case QMetaType::Int:
                jo.insert(key, hs.toInt());
                break;
            case QMetaType::UInt:
                jo.insert(key, hs.toLongLong());
                break;
            case QMetaType::Long:
            case QMetaType::LongLong:
                jo.insert(key, hs.toLongLong());
                break;
            case QMetaType::Double:
                jo.insert(key, hs.toDouble());
                break;
            case QMetaType::Float:
                jo.insert(key, hs.toFloat());
                break;
            case QMetaType::QDateTime:
            case QMetaType::QDate:
            case QMetaType::QTime:
                jo.insert(key, hs.toString());
                break;
            case QMetaType::QVector2D: {
                QVector2D v=hs.value<QVector2D>();
                m.insert("x", v.x());
                m.insert("y", v.y());
                jo.insert(key, QJsonObject::fromVariantMap(m));
            }
                break;
            case QMetaType::QVector3D: {
                QVector3D v=hs.value<QVector3D>();
                m.insert("x", v.x());
                m.insert("y", v.y());
                m.insert("z", v.z());
                jo.insert(key, QJsonObject::fromVariantMap(m));
            }
                break;
            case QMetaType::QVector4D: {
                QVector4D v=hs.value<QVector4D>();
                m.insert("x", v.x());
                m.insert("y", v.y());
                m.insert("z", v.z());
                m.insert("w", v.w());
                jo.insert(key, QJsonObject::fromVariantMap(m));
            }
                break;
            case QMetaType::QStringList:
                jo.insert(key, QJsonArray::fromStringList(hs.toStringList()));
                break;
            default: {
                QVariant cj;
                QJsonValue jv;
                if (formatToJson(key, hs, jv)==false) {
                    qWarning() << "No json type handler for key " << key << " type id " << (QMetaType::Type)hs.typeId();
                } else {
                    jo.insert(key, jv);
                }
            }
                break;
            }
        }
        
        a.append(jo);
    }
    
    QJsonDocument d(a);
    
    return d.toJson();
}

bool AbstractObjectModel::fromJson(const QByteArray json)
{
    QJsonDocument d=QJsonDocument::fromJson(json);
    if (d.isEmpty()) {
        qWarning() << "fromJson: Empty document" << json;
        return false;
    }
    if (!d.isArray()) {
        qWarning() << "fromJson: Not an array"  << json;
        return false;
    }
    
    const QJsonArray a=d.array();
    
    qDebug() << "fromJson: " << a;
    
    for (qsizetype i=0;i<a.count();i++) {
        auto item=a.at(i).toObject();
        if (item.isEmpty())
            continue;
        auto vm=item.toVariantMap();
        auto o=fromVariantMap(vm);
        if (o!=nullptr) {
            o->setParent(this);
            append(o);
        }
    }
    
    return true;
}

void AbstractObjectModel::setList(QObjectList data)
{
    if (!m_data.empty())
        clear();
    beginResetModel();
    m_data=data;
    createKeyIndex();
    endResetModel();
    emit countChanged(m_data.size());
    
}
