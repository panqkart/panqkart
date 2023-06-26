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

import collections, copy
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

def _default_dump_func(obj):
    return _dump(obj, _default_dump_func)

def _dump(obj, dump_func):
    if isinstance(obj, (set, frozenset)):
        obj = dict.fromkeys(obj, True)

    if isinstance(obj, dict):
        res = []
        for k, v in obj.items():
            res.append('[' + dump_func(k) + '] = ' + dump_func(v))
        return '{' + ', '.join(res) + '}'

    if isinstance(obj, (tuple, list)):
        return '{' + ', '.join(map(dump_func, obj)) + '}'

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
        return _dump(obj, _default_dump_func)
    except _PartialTypeError as e:
        msg = str(e)

    # Clean tracebacks
    raise TypeError(msg)

def serialize(obj):
    """
    Serialize an object into valid Lua code. This will raise a TypeError if the
    object cannot be serialized into lua.
    """

    return 'return ' + dump(obj)

def _walk(obj, seen):
    yield obj
    if isinstance(obj, dict):
        for k, v in obj.items():
            # yield from _walk(k, seen)
            yield from _walk(v, seen)
    elif isinstance(obj, (tuple, list, set, frozenset)):
        try:
            if obj in seen:
                return
            seen.add(obj)
        except TypeError:
            pass
        for v in obj:
            yield from _walk(v, seen)

def _replace_values(obj):
    if isinstance(obj, dict):
        it = obj.items()
    elif isinstance(obj, list):
        it = enumerate(obj)
    else:
        return

    for k, v in it:
        if isinstance(v, tuple):
            new_obj = list(v)
            _replace_values(new_obj)
            obj[k] = tuple(new_obj)
            continue
        _replace_values(v)
        if isinstance(v, list):
            obj[k] = tuple(v)

def serialize_readonly(obj):
    """
    Serializes an object into a Lua table with the assumption that the
    resulting table will never be modified. This allows any duplicate lists and
    tuples to be reused.
    """

    # Count all tuples
    ref_count = collections.Counter()

    obj = copy.deepcopy(obj)
    _replace_values(obj)

    for item in _walk(obj, set()):
        if isinstance(item, (tuple, frozenset)):
            try:
                ref_count[item] += 1
            except TypeError:
                pass

    # This code is heavily inspired by MT's builtin/common/serialize.lua
    # Copyright that may apply to this code (which is MIT licensed):
    # @copyright 2006-2997 Fabien Fleutot <metalua@gmail.com>
    dumped = {}
    res = []
    def dump_or_ref(obj2):
        try:
            count = ref_count[obj2]
        except TypeError:
            count = 0
        if count >= 2:
            if obj2 not in dumped:
                code = _dump(obj2, dump_or_ref)
                idx = len(res) + 1
                res.append('a[{}] = {}'.format(idx, code))
                dumped[obj2] = idx
            return 'a[{}]'.format(dumped[obj2])
        return _dump(obj2, dump_or_ref)

    try:
        res.append('return ' + _dump(obj, dump_or_ref))
        if len(res) > 1:
            res.insert(0, 'local a = {}')
        return '\n'.join(res)
    except _PartialTypeError as e:
        msg = str(e)

    # Clean tracebacks
    raise TypeError(msg)
