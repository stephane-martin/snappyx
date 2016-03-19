=======
Snappyx
=======

A simple Cython wrapper for the snappy compression library

Installation
============

Requirements
------------

* Python 2.7 or Python 3
* A C++ compiler
* On MacOSX, if no wheel package is available, snappyx will try to compile against the same C++ SDK than Python. So
probably the relevant version of XCode is necessary.

Snappy source is embedded in the package, so you don't need to download or install snappy.


Install with pip
----------------

With pip::

    pip install snappyx

Usage
=====

Deadly simple::

    import snappyx
    s = "Oh please compress me babe!..." * 10
    c = snappyx.compress(s)
    print("Raw size: {}\nCompressed size: {}\n".format(len(s), len(c)))
    d = snappyx.decompress(c)
    print("Checking: ", s == d)

That's all.
