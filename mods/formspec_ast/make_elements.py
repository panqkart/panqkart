#!/usr/bin/env python3
#
# A primitive script to parse lua_api.txt for formspec elements.
#

import copy, lua_dump, os, urllib.request

def _make_known(**kwargs):
    known = {}
    for k, v in kwargs.items():
        for i in v:
            known[i] = k
    return known

_known = _make_known(
    number=('x', 'y', 'w', 'h', 'selected_idx', 'version',
            'starting_item_index', 'scroll_factor'),
    boolean=('auto_clip', 'fixed_size', 'transparent', 'draw_border', 'bool',
             'fullscreen', 'noclip', 'drawborder', 'selected', 'force'),
    table=('param', 'opt', 'prop'),
    null=('',),
)

def _get_name(n):
    if not isinstance(n, tuple) or n[1] == '...':
        return '...'
    return n[0][:-1].rsplit('_', 1)[0].rstrip('_')

_aliases = {
    'type': 'elem_type',
    'cell': 'cells',
}

def _fix_param(param):
    if isinstance(param, str):
        if ',' not in param:
            param = param.lower().strip().strip('<>').replace(' ', '_')
            param = _aliases.get(param, param)
            assert param != '...'
            return (param, _known.get(param, 'string'))
        param = param.split(',')

    res = []
    for p in map(str.strip, param):
        if p != '...':
            res.append(_fix_param(p))
            continue
        assert res

        last = res.pop()
        # Workaround
        if res and last and isinstance(last, list) and \
                last[0][0].endswith('2') and isinstance(res[-1], list) and \
                res[-1] and res[-1][0][0].endswith('1'):
            last = res.pop()
            last[0] = (last[0][0][:-2], last[0][1])

        name = _get_name(last)
        if name == '...':
            res.append((last, '...'))
        else:
            while res and _get_name(res[-1]) == name:
                res.pop()
            res.append((_fix_param(name), '...'))
        break

    return res

_hooks = {}
def hook(name):
    def add_hook(func):
        _hooks[name] = func
        return func
    return add_hook

# Fix background9
@hook('background9')
def _background9_hook(params):
    assert params[-1] == ('middle', 'string')
    params[-1] = param = []
    param.append(('middle_x', 'number'))
    yield params
    param.append(('middle_y', 'number'))
    yield params
    param.append(('middle_x2', 'number'))
    param.append(('middle_y2', 'number'))
    yield params

# Fix bgcolor
@hook('bgcolor')
def _bgcolor_hook(params):
    yield params
    for i in range(1, len(params)):
        yield params[:-i]

# Fix size
@hook('size')
def _size_hook(params):
    yield params
    yield [[('w', 'number'), ('h', 'number')]]

# Fix style and style_type
@hook('style')
@hook('style_type')
def _style_hook(params):
    # This is not used when parsing but keeps backwards compatibility when
    # unparsing.
    params[0] = [('name', 'string')]
    yield params

    params[0] = [(('selectors', 'string'), '...')]
    yield params

# Fix scroll_container
@hook('scroll_container')
def _scroll_container_hook(params):
    yield params
    yield params[:4]

# Fix dropdown
@hook('dropdown')
def _scroll_container_hook(params):
    if isinstance(params[1][0], str):
        params[1] = [('w', 'number'), ('h', 'number')]
    else:
        params[1] = ('w', 'number')
    yield params[:5]
    yield params

def _raw_parse(data):
    data = data.split('\nElements\n--------\n', 1)[-1].split('\n----', 1)[0]
    for line in data.split('\n'):
        if not line.startswith('### `') or not line.endswith('`'):
            continue

        elem = line[5:-2]
        name, params = elem.split('[', 1)
        if params:
            params = _fix_param(params.split(';'))
        else:
            params = []

        if name in _hooks:
            for p in reversed(tuple(map(copy.deepcopy, _hooks[name](params)))):
                yield name, p
        else:
            yield name, params

def parse(data):
    """
    Returns a dict:
    {
        'element_name': [
            ['param1', 'param2'],
            ['alternate_params'],
        ]
    }
    """
    res = {}
    for k, v in _raw_parse(data):
        if k not in res:
            res[k] = []
        res[k].append(v)

    for v in res.values():
        v.sort(key=len, reverse=True)

    return res

URL = 'https://github.com/minetest/minetest/raw/master/doc/lua_api.txt'
def fetch_and_parse(*, url=URL):
    with urllib.request.urlopen(url) as f:
        raw = f.read()
    return parse(raw.decode('utf-8', 'replace'))

_comment = """
--
-- Formspec elements list. Do not update this by hand, it is auto-generated
-- by make_elements.py.
--

"""

def main():
    dirname = os.path.dirname(__file__)
    filename = os.path.join(dirname, 'elements.lua')
    print('Writing to ' + filename + '...')
    with open(filename, 'w') as f:
        f.write(_comment.lstrip())
        f.write(lua_dump.serialize(fetch_and_parse()))
        # elems = fetch_and_parse()
        # for elem in sorted(elems):
        #     for def_ in elems[elem]:
        #         f.write('formspec_ast.register_element({}, {})\n'.format(
        #             lua_dump.dump(elem), lua_dump.dump(def_)
        #         ))
    print('Done.')

if __name__ == '__main__':
    main()
