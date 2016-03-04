=======
Snappyx
=======

A simple Cython wrapper for the snappy compression library

Installation
============

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
