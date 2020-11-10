#include <libxml/parser.h>
#include <libxml/tree.h>
#include <sqlite3.h>
#include <stdio.h>
#include <string.h>

/*
 * To compile this file using gcc you can type
 * gcc -O3 -lsqlite3 $(xml2-config --cflags --libs) -o buildDb buildDb.c
 */

#ifdef LIBXML_TREE_ENABLED

void terminate (char *text) {
    xmlCleanupParser();
    fputs(text, stderr);
    exit(1);
}

unsigned long djb2hash(unsigned char *str) {
    unsigned long hash = 5381;
    int c;

    while (c = *str++) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

int main(int argc, char **argv) {
    const char *const fileNames[] = {
        "./stolperstein-world/stolperstein-europe.osm",
        "./stolperstein-world/stolperstein-russia.osm"
    };
    const char *const initialCommand[8] = { 
        "PRAGMA JOURNAL_MODE=OFF",
        "PRAGMA SYNCHRONOUS=OFF",
        "PRAGMA LOCKING_MODE=EXCLUSIVE",
        "PRAGMA TEMP_STORE=MEMORY",
        "DROP TABLE IF EXISTS stein",
        "DROP TABLE IF EXISTS kv",
        "CREATE TABLE stein ("
            "id INTEGER NOT NULL PRIMARY KEY,"
            "geometry TEXT,"
            "version INTEGER,"
            "timestamp TEXT"
        ")",
        "CREATE TABLE kv ("
            "hash TEXT PRIMARY KEY,"
            "nodeid INTEGER,"
            "key TEXT,"
            "value TEXT,"
            "FOREIGN KEY(nodeid) REFERENCES stein(id)"
        ")"
    };

    int i;
    int steinCount = 0;
    int kvCount = 0;
    char error[255] = "";

    xmlDoc *doc = NULL;
    xmlNode *rootElement = NULL;
    xmlNode *cur = NULL;
    xmlNode *curChild = NULL;
    xmlChar *prop;
    
    sqlite3 *db;
    sqlite3_stmt *res;
    sqlite3_stmt *resKv;
    int rc;
    char * errMsg;

    long long id;
    char geometry[57];
    char timestamp[21];
    char key[255];
    char value[10240];
    char hash[25];

    LIBXML_TEST_VERSION

    rc = sqlite3_open("./stolpersteine/db.sqlite3", &db);
    if (rc != SQLITE_OK) {
        snprintf(error, 255, "Cannot open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        terminate(error);
    }
    for (i = 0; i < 8; i++) {
        rc = sqlite3_exec(db, initialCommand[i], NULL, NULL, &errMsg);
        if (rc != SQLITE_OK) {
            snprintf(error, 255, "SQL error %s", errMsg);
            sqlite3_free(errMsg);
            sqlite3_close(db);
            terminate(error);
        }
    }
    rc = sqlite3_exec(db, "BEGIN TRANSACTION", NULL, NULL, &errMsg);
    if (rc != SQLITE_OK) {
        snprintf(error, 255, "BEGIN TRANSACTION failed: %s\n", &errMsg);
        sqlite3_close(db);
        terminate(error);
    }

    rc = sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO stein VALUES (?,?,?,?)", -1, &res, NULL);
    if (rc != SQLITE_OK) {
        snprintf(error, 255, "Prepare statement (stein table) failed: %s\n", &errMsg);
        sqlite3_close(db);
        terminate(error);
    }

    rc = sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO kv VALUES (?,?,?,?)", -1, &resKv, NULL);
    if (rc != SQLITE_OK) {
        snprintf(error, 255, "Prepare statement (key-value table) failed: %s\n", &errMsg);
        sqlite3_close(db);
        terminate(error);
    }

    for (i = 0; i < 2; i++) {
        doc = xmlReadFile(fileNames[i], NULL, 0); // TODO: replace 1 (one) by i (India)
        if (doc == NULL) {
            snprintf(error, 255, "error: could not parse file %s", fileNames[i]);
            terminate(error);
        }
        rootElement = xmlDocGetRootElement(doc);
        if (rootElement->type != XML_ELEMENT_NODE) {
            snprintf(error, 255, "error: illegal root element in file %s", fileNames[i]);
            terminate(error);
        }
        if (strcmp(rootElement->name, "osm")) {
            snprintf(error, 255, "error: no root element 'osm' in file %s", fileNames[i]);
            terminate(error);
        }
        for (cur = rootElement->children; cur; cur = cur->next) {
            if (cur->type == XML_ELEMENT_NODE && !strcmp(cur->name, "node")) {
                id = atoll(xmlGetProp(cur, "id"));
                snprintf(geometry, 57, "{\"type\":\"Point\",\"coordinates\":[%11s,%11s]}", xmlGetProp(cur, "lon"), xmlGetProp(cur, "lat"));
                snprintf(timestamp, 21, "%s", xmlGetProp(cur, "timestamp"));
                sqlite3_bind_int64(res, 1, id);
                sqlite3_bind_text(res, 2, geometry, 56, NULL);
                sqlite3_bind_int(res, 3, atoi(xmlGetProp(cur, "version")));
                sqlite3_bind_text(res, 4, timestamp, 20, NULL);
                sqlite3_step(res);
                sqlite3_reset(res);
                for (curChild = cur->children; curChild; curChild = curChild->next) {
                    if (curChild->type == XML_ELEMENT_NODE) {
                        snprintf(key, 255, "%s", xmlGetProp(curChild, "k"));
                        snprintf(value, 10240, "%s", xmlGetProp(curChild, "v"));
                        snprintf(hash, 25, "%0.8llx%0.8lx%0.8lx", id, djb2hash(key), djb2hash(value));
                        sqlite3_bind_text(resKv, 1, hash, 25, NULL);
                        sqlite3_bind_int64(resKv, 2, id);
                        sqlite3_bind_text(resKv, 3, key, strlen(key), NULL);
                        sqlite3_bind_text(resKv, 4, value, strlen(value), NULL);
                        sqlite3_step(resKv);
                        sqlite3_reset(resKv);
                    }
                }
            }
        }      
        xmlFreeDoc(doc);
    }
    xmlCleanupParser();
    
    rc = sqlite3_exec(db, "COMMIT TRANSACTION", NULL, NULL, &errMsg);
    if (rc != SQLITE_OK) {
        snprintf(error, 255, "COMMIT TRANSACTION failed: %s\n", &errMsg);
        sqlite3_close(db);
        terminate(error);
    }
    sqlite3_close(db);

    return 0;
}
#else
int main(void) {
    fprintf(stderr, "Tree support not compiled in\n");
    exit(1);
}
#endif