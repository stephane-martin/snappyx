# -*- coding: utf-8 -*-

from setuptools import setup, find_packages, Extension
from os.path import join, dirname, abspath, exists
import os
import platform
import distutils.sysconfig
import sysconfig
import sys

on_rtd = os.environ.get('READTHEDOCS', None) == 'True'

requirements = []

setup_requires = [
    'setuptools_git', 'setuptools', 'twine', 'wheel', 'pip'
]

root_dir = abspath(dirname(__file__))
snappy_dir = join(root_dir, 'snappy_src')
snappy_source_files = [
    'snappy_src/snappy.cc',
    'snappy_src/snappy-sinksource.cc',
    'snappy_src/snappy-stubs-internal.cc',
    'snappy_src/snappy-c.cc'
]

extensions = [
    Extension(
        name="snappyx._snappyx",
        sources=['snappyx/_snappyx.cpp'] + snappy_source_files,
        include_dirs=[snappy_dir],
        language="c++"
    )
]

name = 'snappyx'
version = '0.5'
description = 'A simple Cython wrapper for the snappy compression library'
author = 'Stephane Martin',
author_email = 'stephane.martin_github@vesperal.eu',
url = 'https://github.com/stephane-martin/snappyx',
licens = "see LICENSE file"
keywords = 'python snappy compression'
data_files = []

classifiers = [
    'Development Status   :: 4 - Beta',
    'Programming Language :: C++',
    'Programming Language :: Python :: 2.7',
    'Programming Language :: Python :: 3',
    'Programming Language :: Cython',
    'Operating System     :: POSIX',
    'Topic :: Software Development :: Libraries',
    'Topic :: System :: Archiving  :: Compression'

]

entry_points = dict()

with open('README.rst') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read()

long_description = readme + '\n\n' + history

IS_MACOSX = platform.system().lower().strip() == "darwin"


def info(s):
    sys.stderr.write(s + "\n")


def runsetup():

    if IS_MACOSX:
        disutils_sysconfig = distutils.sysconfig.get_config_vars()
        # don't build useless i386 architecture
        disutils_sysconfig['LDSHARED'] = disutils_sysconfig['LDSHARED'].replace('-arch i386', '')
        disutils_sysconfig['CFLAGS'] = disutils_sysconfig['CFLAGS'].replace('-arch i386', '')
        # suppress painful warnings
        disutils_sysconfig['CFLAGS'] = disutils_sysconfig['CFLAGS'].replace('-Wstrict-prototypes', '')

        python_config_vars = sysconfig.get_config_vars()
        # use the same SDK as python executable
        if not exists(python_config_vars['UNIVERSALSDK']):
            info("'{}' SDK does not exist. Aborting.\n".format(python_config_vars['UNIVERSALSDK']))
            sys.exit(-1)
        info("Building for MacOSX SDK: {}".format(python_config_vars["MACOSX_DEPLOYMENT_TARGET"]))
        os.environ["MACOSX_DEPLOYMENT_TARGET"] = python_config_vars["MACOSX_DEPLOYMENT_TARGET"]
        os.environ["SDKROOT"] = python_config_vars["UNIVERSALSDK"]

    setup(
        name=name,
        version=version,
        description=description,
        long_description=long_description,
        author=author,
        author_email=author_email,
        url=url,
        packages=find_packages(),
        setup_requires=setup_requires,
        include_package_data=True,
        install_requires=requirements,
        license=licens,
        zip_safe=False,
        keywords=keywords,
        classifiers=classifiers,
        entry_points=entry_points,
        data_files=data_files,
        ext_modules=extensions
    )


if __name__ == "__main__":
    runsetup()
