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
    if isinstance(inpt, unicode):
        raise TypeError("unicode objects are not accepted")
    if not inpt:
        return b''
    if not PyObject_CheckBuffer(inpt):
        raise TypeError("inpt does not support the buffer interface")
    cdef Py_buffer* view = <Py_buffer*> PyMem_Malloc(sizeof(Py_buffer))
    if view == NULL:
        raise MemoryError()
    cdef int res = PyObject_GetBuffer(inpt, view, PyBUF_SIMPLE)
    if res == -1:
        PyMem_Free(view)
        raise RuntimeError("PyObject_GetBuffer failed")
    cdef size_t compressed_length
    try:
        if view.len == 0:
            return b''
        output = bytearray(MaxCompressedLength(view.len))
        RawCompress(<char*> view.buf, <size_t> view.len, <char*> output, &compressed_length)
        PyByteArray_Resize(<PyObject*> output, compressed_length)
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
    cdef size_t uncompressed_length
    cdef size_t compressed_length
    cdef char* compressed_buf

    if isinstance(compressed, unicode):
        raise TypeError("unicode objects are not accepted")
    if not compressed:
        return b''
    if not PyObject_CheckBuffer(compressed):
        raise TypeError("compressed does not support the buffer interface")
    cdef string uncompressed
    cdef Py_buffer* view = <Py_buffer*> PyMem_Malloc(sizeof(Py_buffer))
    if view == NULL:
        raise MemoryError()
    res = PyObject_GetBuffer(compressed, view, PyBUF_SIMPLE)
    if res == -1:
        PyMem_Free(view)
        raise RuntimeError("PyObject_GetBuffer failed")
    try:
        compressed_buf = <char*> view.buf
        compressed_length = view.len
        if IsValidCompressedBuffer(compressed_buf, compressed_length):
            GetUncompressedLength(compressed_buf, compressed_length, &uncompressed_length)
            output = bytearray(uncompressed_length)
            if RawUncompress(compressed_buf, compressed_length, <char*> output):
                return output
            raise RuntimeError("error while uncompressing")
        raise ValueError("invalid compressed buffer")
    finally:
        PyBuffer_Release(view)
        PyMem_Free(view)

