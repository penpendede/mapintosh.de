# Visualization of all stolpersteins

## Obtaining the stolperstein data

Stolperstein data extracted from the OSM database are available at
[https://github.com/penpendede/stolperstein-world](https://github.com/penpendede/stolperstein-world) where
you can also find a desription how to extract them yourself.

## Preparing the database

Once you have the stolperstein data in OSM format import them into an SQLite database.

### node approach

My first attempt at putting the data into such a database using node turned out to be way too slow to be
practical. However, as you may know, SQLite has PRAGMA settings that control how the database behaves: if
it uses a journal file, uses synchronous access, etc.

Mass-adding large amounts of datasets can be considerably sped up by changing certain PRAGMA settings to
values some of which are **deprecated** for any **live** database as they may yield a corrupt database. For
the particular use at hand that does not play a role, in the worst case you remove the database and give
the import another shot. So here we are:

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
Raspberry Pi 4.

### Enter python

If you  [use what plain Python holds in store](stolpersteine/tools/buildDb.py) you can reduce the runtime to
about 20 seconds. The gain in speed exclusively comes from the optimized access to the SQLite database
while processing the OSM (XML) file takes the same amount of time as before. The advantage of this script
is that it works as long as you have Python available.

For even higher speed I [replaced ElementTree by lxml](stolpersteine/tools/buildDb-lxml.py) which takes the
runtime of down to about 11 seconds. The drawback is that installing lxml may not be possible as it needs
certain XML libraries to be provided by the operating system. With 23,000 stolpersteins that means
processing about 2000 stolpersteins and generating 24,000 data rows per second (each stolperstein comes
with an average of 10 key-value pairs).

### Good ol' C

While 11 seconds is not too shabby for a scripting language I managed to cut that time into half by
[using C](stolpersteine/tools/buildDb.c) this of course requires using a C compiler and having libxml2 and
SQLite3 C bindings at your disposal.

To avoid using even more libraries the C version uses a different hash function. As the only reason for
using the hash function is ensuring distinct key value pairs the acutal hash has little influence. Just
don't mix C and node/python.

## Introducing the fgru file format

I didn't find any file format for storing the stolperstein data in a format with little overhead so I
invented a file format of my own. It has strong similarities with CSV but uses four ASCII characters that
have almost been forgotten. This is sad as they were specifically designed for encoding plain text datasets.

|Abbreviation|Name                      | description                |
|------------|--------------------------|----------------------------|
|FS          |File separator character  |separates logical records   |
|GS          |Group separator character |separates fields            |
|RS          |Record separator character|separates repeated subfields|
|US          |Unit separator character  |separates information items |

In an fgru file, FS is used where a CSV file would use a line break - it separates table rows so to say.
GS is used where CSV would use a comma (or semicolon, tab, or the like) - it separates table columns so to
say. The use of RS adds a third dimension to the picture which means that each table cell can contain a
list of values. Finally, using US allows each of the list elements to be made up of a list. Another way of
viewing this is that each table cell can itself contain a table.

Let us view this from a more practical angle: In an ordinary CSV file you would represent the stolpersteins
like this:

```text
lat1, lng1, JSON1
lat2, lng2, JSON2
lat3, lng3, JSON3
:     :     :
```

with JSON data representing the key-value pairs. In a fgru file you can do the same (the line breaks are
only for readability):

```text
lat1 GS lng1 GS JSON1 FS
lat2 GS lng2 GS JSON2 FS
lat3 GS lng3 GS JSON3 FS
:       :       :
```

However, the fgru format allows you to use

```text
lat1 GS lng1 GS key1a US val1a RS key1b US val1b RS key1c US val1c RS ... FS
lat2 GS lng2 GS key2a US val2a RS key2b US val2b RS key2c US val2c RS ... FS
lat3 GS lng3 GS key3a US val3a RS key3b US val3b RS key3c US val3c RS ... FS
:       :       :
```

Actually that's not the final word as lat and lng belong together. So I actually use is

```text
lat1 RS lng1 GS key1a US val1a RS key1b US val1b RS key1c US val1c RS ... FS
lat2 RS lng2 GS key2a US val2a RS key2b US val2b RS key2c US val2c RS ... FS
lat3 RS lng3 GS key3a US val3a RS key3b US val3b RS key3c US val3c RS ... FS
:       :       :
```

Please note that this only makes sense if you are sure that all you store are points, otherwise you'd rather
use

```text
lat1a US lng1a RS lat1b US lng1b RS lat1c US lng1c ... GS key1a US val1a RS key1b US val1b RS key1c US val1c RS ... FS
lat2a US lng2a RS lat2b US lng2b RS lat2c US lng2c ... GS key2a US val2a RS key2b US val2b RS key2c US val2c RS ... FS
lat3a US lng3a RS lat3b US lng3b RS lat3c US lng3c ... GS key3a US val3a RS key3b US val3b RS key3c US val3c RS ... FS
:       :       :
```

In case you wonder why I named the format after flare gas recovery units as used in refineries: I did not,
that just happen to be the first letters of FS, GS, RS and US, respectively.
