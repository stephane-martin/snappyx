# -*- coding: utf-8 -*-

from setup import extensions, runsetup, Extension, snappy_source_files, snappy_dir, setup_requires

extensions[:] = []

extensions.append(
    Extension(
        name="snappyx._snappyx",
        sources=['snappyx/_snappyx.pyx'] + snappy_source_files,
        include_dirs=[snappy_dir],
        language="c++"
    )
)

setup_requires.append('cython')

if __name__ == "__main__":
    runsetup()

