#!/usr/bin/env python3
#
# Converts Python objects into Lua ones. This allows more things to be used as
# keys than JSON.
#
# The MIT License (MIT)
#
# Copyright © 2019 by luk3yx.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#

from decimal import Decimal

def _escape_string(x):
    yield '"'
    for char in x:
        if char == 0x22: # "
            yield r'\"'
        elif char == 0x5c:
            yield r'\\'
        elif 0x7f > char > 0x1f:
            yield chr(char)
        else:
            yield '\\' + str(char).zfill(3)
    yield '"'

class _PartialTypeError(TypeError):
    def __str__(self):
        return 'Object of type ' + repr(type(self.args[0]).__name__) + \
            ' is not Lua serializable.'

def _dump(obj):
    if isinstance(obj, set):
        obj = dict.fromkeys(obj, True)

    if isinstance(obj, dict):
        res = []
        for k, v in obj.items():
            res.append('[' + _dump(k) + '] = ' + _dump(v))
        return '{' + ', '.join(res) + '}'

    if isinstance(obj, (tuple, list)):
        return '{' + ', '.join(map(_dump, obj)) + '}'

    if isinstance(obj, bool):
        return 'true' if obj else 'false'

    if isinstance(obj, (int, float, Decimal)):
        return str(obj)

    if isinstance(obj, str):
        obj = obj.encode('utf-8', 'replace')

    if isinstance(obj, bytes):
        return ''.join(_escape_string(obj))

    if obj is None:
        return 'nil'

    raise _PartialTypeError(obj)

def dump(obj):
    """
    Similar to serialize(), however doesn't prepend return.
    """

    try:
        return _dump(obj)
    except _PartialTypeError as e:
        msg = str(e)

    # Clean tracebacks
    raise TypeError(msg)

def serialize(obj):
    """
    Serialize an object into valid Lua code. This will raise a TypeError if the
    object cannot be serialized into lua.
    """

    try:
        return 'return ' + _dump(obj)
    except _PartialTypeError as e:
        msg = str(e)

    # Clean tracebacks
    raise TypeError(msg)
