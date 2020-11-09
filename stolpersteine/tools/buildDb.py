import xml.etree.ElementTree as ET
import sqlite3
import murmurhash.mrmr
import ctypes

def gethash(value):
    return "{0:08x}".format(ctypes.c_ulong(murmurhash.mrmr.hash(value)).value)

def gethex(value):
    return "{0:09x}".format(value)

def getid(id, k, v):
    return gethex(id) + gethash(k) + gethash(v) 

fileNames = [
    './stolperstein-world/stolperstein-europe.osm',
    './stolperstein-world/stolperstein-russia.osm'
]

conn = sqlite3.connect('./stolpersteine/db.sqlite3')
c = conn.cursor()

c.execute('PRAGMA JOURNAL_MODE=OFF')
c.execute('PRAGMA SYNCHRONOUS=OFF')
c.execute('PRAGMA LOCKING_MODE=EXCLUSIVE')
c.execute('PRAGMA TEMP_STORE=MEMORY')
c.execute('DROP TABLE IF EXISTS stein')
c.execute('DROP TABLE IF EXISTS kv')
c.execute('''
    CREATE TABLE stein (
        id INTEGER NOT NULL PRIMARY KEY,
        geometry TEXT,
        version INTEGER,
        timestamp TEXT
    )''')
c.execute('''
    CREATE TABLE kv (
        hash TEXT PRIMARY KEY,
        nodeid INTEGER,
        key TEXT,
        value TEXT,
        FOREIGN KEY(nodeid) REFERENCES stein(nodeid)
    )''')
c.execute('BEGIN TRANSACTION')

steinData = []
kvData = []
for fileName in fileNames:
    tree = ET.parse(fileName)
    root = tree.getroot()
    for child in root:
        if child.tag == 'node':
            steinData.append(
                (
                    int(child.attrib['id']),
                    '{type: "Point",coordinates:[' + child.attrib['lon'] + ',' + child.attrib['lat'] + ']}',
                    int(child.attrib['version']),
                    child.attrib['timestamp']
                )
            )
            for grandchild in child:
                if grandchild.tag == 'tag':
                    k = grandchild.attrib['k']
                    v = grandchild.attrib['v']
                    if k:
                        kvData.append(
                            (
                                getid (int(child.attrib['id']), k, v),
                                int(child.attrib['id']),
                                k,
                                v
                            )
                        )#getId(id, k, v)
c.executemany('INSERT OR REPLACE INTO stein VALUES (?,?,?,?)', steinData)
c.executemany('INSERT OR REPLACE INTO kv VALUES (?,?,?,?)', kvData)
conn.commit()