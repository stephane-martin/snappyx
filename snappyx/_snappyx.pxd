# -*- coding: utf-8 -*-

# noinspection PyUnresolvedReferences
from libc.stdint cimport uint8_t, uintptr_t, int64_t, uint64_t, uint32_t
from libcpp.string cimport string
# noinspection PyUnresolvedReferences
from libcpp cimport bool as cpp_bool
# noinspection PyUnresolvedReferences
from cpython.ref cimport PyObject

cdef extern from "Python.h":
    int PyByteArray_Resize(PyObject* ba, Py_ssize_t l)

cdef extern from "snappy-sinksource.h" namespace "snappy" nogil:

    # A Source is an interface that yields a sequence of bytes
    cdef cppclass Source:
        size_t Available() const
        const char* Peek(size_t* l)
        void Skip(size_t n)

    # A Source implementation that yields the contents of a flat array
    cdef cppclass ByteArraySource(Source):
        ByteArraySource(const char* p, size_t n)

    # A Sink is an interface that consumes a sequence of bytes.
    cdef cppclass Sink:
        void Append(const char* b, size_t n)
        char* GetAppendBuffer(size_t length, char* scratch)
        void AppendAndTakeOwnership(char* b, size_t n, void (*deleter)(void*, const char*, size_t), void *deleter_arg)
        char* GetAppendBufferVariable(size_t min_size, size_t desired_size_hint, char* scratch, size_t scratch_size, size_t* allocated_size)

    # A Sink implementation that writes to a flat array without any bound checks.
    cdef cppclass UncheckedByteArraySink(Sink):
        UncheckedByteArraySink(char* dest)

cdef extern from "snappy.h" namespace "snappy" nogil:

    # Sets "*output" to the compressed version of "input[0,input_length-1]".
    # Original contents of *output are lost.
    # REQUIRES: "input[]" is not an alias of "*output".
    size_t Compress(char* inpt, size_t input_length, string* output)

    # Compress the bytes read from "*source" and append to "*sink". Return the
    # number of bytes written.
    size_t Compress(Source* source, Sink* sink)

    # REQUIRES: "compressed" must point to an area of memory that is at
    # least "MaxCompressedLength(input_length)" bytes in length.
    # Takes the data stored in "input[0..input_length]" and stores
    # it in the array pointed to by "compressed".
    # "*compressed_length" is set to the length of the compressed output.
    void RawCompress(const char* inpt, size_t input_length, char* compressed, size_t* compressed_length)

    # Decompresses "compressed[0,compressed_length-1]" to "*uncompressed".
    # Original contents of "*uncompressed" are lost.
    # REQUIRES: "compressed[]" is not an alias of "*uncompressed".
    # returns false if the message is corrupted and could not be decompressed
    cpp_bool Uncompress(char* compressed, size_t compressed_length, string* uncompressed)

    # Decompresses "compressed" to "*uncompressed".
    # returns false if the message is corrupted and could not be decompressed
    cpp_bool Uncompress(Source* compressed, Sink* uncompressed)

    # Given data in "compressed[0..compressed_length-1]" generated by
    # calling the Snappy::Compress routine, this routine
    # stores the uncompressed data to uncompressed[0..GetUncompressedLength(compressed)-1]
    # returns false if the message is corrupted and could not be decrypted
    cpp_bool RawUncompress(const char* compressed, size_t compressed_length, char* uncompressed)

    # This routine uncompresses as much of the "compressed" as possible
    # into sink.  It returns the number of valid bytes added to sink
    # (extra invalid bytes may have been added due to errors; the caller
    # should ignore those). The emitted data typically has length
    # GetUncompressedLength(), but may be shorter if an error is
    # encountered.
    size_t UncompressAsMuchAsPossible(Source* compressed, Sink* uncompressed)

    # Find the uncompressed length of the given stream, as given by the header.
    # Note that the true length could deviate from this; the stream could e.g.
    # be truncated.
    # Also note that this leaves "*source" in a state that is unsuitable for
    # further operations, such as RawUncompress(). You will need to rewind
    # or recreate the source yourself before attempting any further calls.
    cpp_bool GetUncompressedLength(Source* source, uint32_t* result)

    # Returns the maximal size of the compressed representation of
    # input data that is "source_bytes" bytes in length;
    size_t MaxCompressedLength(size_t source_bytes)

    # REQUIRES: "compressed[]" was produced by RawCompress() or Compress()
    # Returns true and stores the length of the uncompressed data in
    # *result normally.  Returns false on parsing error.
    # This operation takes O(1) time.
    cpp_bool GetUncompressedLength(const char* compressed, size_t compressed_length, size_t* result)

    # Returns true if the contents of "compressed[]" can be uncompressed
    # successfully.  Does not return the uncompressed data.  Takes
    # time proportional to compressed_length, but is usually at least
    # a factor of four faster than actual decompression.
    cpp_bool IsValidCompressedBuffer(const char* compressed, size_t compressed_length)

    # Returns true if the contents of "compressed" can be uncompressed
    # successfully.  Does not return the uncompressed data.  Takes
    # time proportional to *compressed length, but is usually at least
    # a factor of four faster than actual decompression.
    # On success, consumes all of *compressed.  On failure, consumes an
    # unspecified prefix of *compressed.
    cpp_bool IsValidCompressed(Source* compressed)



cpdef compress(object inpt)
cpdef decompress(object compressed)