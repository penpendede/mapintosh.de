# Visualization of all stolpersteins

My first attempt at putting the data into an sqlite3 database turned out to be way too slow to be
practical. However, as you may know, SQLite has PRAGMA settings that control how the database behaves: if
it uses a journal file, uses synchronous access, etc.

Mass-adding large amounts of datasets can be considerably sped up changing certain PRAGMA settings to
values some of which are **deprecated** for any **live** database as they may yield a corrupt database. For
the particular use at hand that does not play a role, in the worst case you remove the database and give
the script another shot. So here we are:

```SQL
PRAGMA JOURNAL_MODE=OFF
PRAGMA LOCKING_MODE=EXCLUSIVE
PRAGMA SYNCHRONOUS=OFF
PRAGMA TEMP_STORE=MEMORY
```

Allow me to provide a short description of what these options do:

* **JOURNAL_MODE=OFF** makes SQLite use no log which makes transaction rollback impossible; a crash may
  corrupt the database.
* **LOCKING_MODE=EXCLUSIVE** turns the database into highlander mode there can only be one (RIP, Sir Sean
  Connery)
* **SYNCHRONOUS=OFF** disables database synchronization; significantly increases performance but a crash
* again may corrupt the database
* **TEMP_STORE=MEMORY** causes temporary objects to be stored in memory

For more details and PRAGMA settings that may cause additional but minor performance improvements see
[https://blog.devart.com/increasing-sqlite-performance.html](https://blog.devart.com/increasing-sqlite-performance.html)

With these optimizations and putting all database writes into a single transaction the
[node script](stolpersteine/tools/buildDb.js) takes about 35 seconds for the conversion when run on a
Raspberry Pi 4. You can live with that but by simply
[using what plain Python holds in store](stolpersteine/tools/buildDb.py) you can reduce the runtime to
about 20 seconds. The gain in speed exclusively comes from the optimized access to the SQLite database
while processing the OSM (XML) file file takes the same amount of time as before. The advantage of this
script is that it works as long as you have Python available.

For even higher speed I [replaced ElementTree by lxml](stolpersteine/tools/buildDb-lxml.py) which takes the
runtime of down to about 11 seconds. The drawback is that installing lxml may not be possible as it needs
certain XML libraries to be provided by the operating system. With 23,000 stolpersteins that means
processing about 2000 stolpersteins and generating 24,000 data rows per second (each stolperstein comes
with an average of 10 key-value pairs).

While 11 seconds is not too shabby for a scripting language I managed to cut that time into half by
[using C](stolpersteine/tools/buildDb.c) this of course requires using a C compiler and having libxml2 and
SQLite3 C bindings at your disposal (to avoid using even more libraries this version is using a different
hash function).
