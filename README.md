Wordpress localization benchmark
====

Wordpress uses a notoriously slow, PHP-based implementation of gettext (see
https://core.trac.wordpress.org/ticket/17268).

This is a simple benchmark using a Docker container, a Debian-based image, PHP
7.2, MariaDB 10.1 and PHP's own HTTP server to get an idea of the impact.

Results on a i7-7500U @2.70GHz (only the non-localized vs. localized ratio
really matters) :

```
$ make
...
Failed requests:        0
Time per request:       16.013 [ms] (mean)

$ make WPLANG=fr_FR
...
Failed requests:        0
Time per request:       30.003 [ms] (mean)
```

It's *twice as slow*. It actually depends on the number of *.mo* files to load, but
most plugins come with their localization files. In my experience, heavy WPs
(30+ plugins, +1000ms response time) tend to waste 30% of their CPU usage in
the *.mo* loading routines (using XDebug's profiler).
