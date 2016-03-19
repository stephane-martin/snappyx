# -*- coding: utf-8 -*-

# noinspection PyUnresolvedReferences
from cpython.buffer cimport PyObject_CheckBuffer, PyObject_GetBuffer, PyBuffer_Release, Py_buffer, PyBUF_SIMPLE
from cpython.mem cimport PyMem_Malloc, PyMem_Free
# noinspection PyUnresolvedReferences
from cpython.ref cimport PyObject


cpdef compress(object inpt):
    """
    compress(object inpt)
    Compress some bytes using the snappy library.

    Parameters
    ----------
    inpt: bytes or bytearray or any object that supports the buffer protocol
        The bytes the compress

    Returns
    -------
    output: bytearray
        The compressed result
    """
    cdef size_t compressed_length
    cdef char* c_output
    cdef int res
    cdef Py_buffer* view

    if isinstance(inpt, unicode):
        raise TypeError("unicode objects are not accepted")
    if not inpt:
        return b''
    if not PyObject_CheckBuffer(inpt):
        raise TypeError("inpt does not support the buffer interface")
    view = <Py_buffer*> PyMem_Malloc(sizeof(Py_buffer))
    if view == NULL:
        raise MemoryError()
    res = PyObject_GetBuffer(inpt, view, PyBUF_SIMPLE)
    if res == -1:
        PyMem_Free(view)
        raise RuntimeError("PyObject_GetBuffer failed")

    try:
        if view.len == 0:
            return b''
        output = bytearray(MaxCompressedLength(view.len))
        c_output = <char*> output
        with nogil:
            RawCompress(<char*> view.buf, <size_t> view.len, c_output, &compressed_length)
        PyByteArray_Resize(output, compressed_length)
        return output
    finally:
        PyBuffer_Release(view)
        PyMem_Free(view)


cpdef decompress(object compressed):
    """
    decompress(object compressed)
    Decompress using snappy.

    Parameters
    ----------
    compressed: bytes, bytearray or any object that supports the buffer protocol

    Returns
    -------
    output: bytearray
        The decompressed result

    """
    cdef int res
    cdef cpp_bool bres
    cdef size_t uncompressed_length
    cdef size_t compressed_length
    cdef char* compressed_buf
    cdef Py_buffer* view
    cdef char* c_output

    if isinstance(compressed, unicode):
        raise TypeError("unicode objects are not accepted")
    if not compressed:
        return b''
    if not PyObject_CheckBuffer(compressed):
        raise TypeError("compressed does not support the buffer interface")
    view = <Py_buffer*> PyMem_Malloc(sizeof(Py_buffer))
    if view == NULL:
        raise MemoryError()
    res = PyObject_GetBuffer(compressed, view, PyBUF_SIMPLE)
    if res == -1:
        PyMem_Free(view)
        raise RuntimeError("PyObject_GetBuffer failed")
    try:
        compressed_buf = <char*> view.buf
        compressed_length = view.len

        bres = GetUncompressedLength(compressed_buf, compressed_length, &uncompressed_length)
        if not bres:
            raise ValueError("parsing error in GetUncompressedLength")
        output = bytearray(uncompressed_length)
        c_output = <char*> output
        with nogil:
            bres = RawUncompress(compressed_buf, compressed_length, c_output)
        if not bres:
            raise ValueError("message looks corrupted in RawUncompress")
        return output

    finally:
        PyBuffer_Release(view)
        PyMem_Free(view)
