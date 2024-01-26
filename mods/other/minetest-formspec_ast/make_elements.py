#!/usr/bin/env python3
#
# A primitive script to parse lua_api.txt for formspec elements.
# This script needs Python 3.8+ and ruamel.yaml to work.
#

import copy, json, lua_dump, os, re, ruamel.yaml, urllib.request

def _make_known(**kwargs):
    known = {}
    for k, v in kwargs.items():
        for i in v:
            known[i] = k
    return known

_known = _make_known(
    number=('x', 'y', 'w', 'h', 'selected_idx', 'version', 'current_tab',
            'starting_item_index', 'scroll_factor', 'frame_count',
            'frame_duration', 'frame_start', 'animation_speed', 'value'),
    boolean=('auto_clip', 'fixed_size', 'transparent', 'draw_border', 'bool',
             'noclip', 'drawborder', 'selected', 'force', 'close_on_enter',
             'continuous', 'mouse_control', 'index_event', 'enter_after_edit'),
    fullscreen=('fullscreen',),
    table=('params', 'opts', 'props'),
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

def _fix_param_name(param):
    param = param.lower().strip().strip('<>').replace(' ', '_')
    param = _aliases.get(param, param)
    assert param != '...'
    return param

def _fix_param(param):
    if isinstance(param, str):
        if ',' not in param:
            param = _fix_param_name(param)
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
            res.append((_fix_param(name + 's'), '...'))
        break

    return res

_hooks = {}
_passive_hooks = set()
def hook(name, *, passive=False):
    if passive:
        _passive_hooks.add(name)
    def add_hook(func):
        _hooks[name] = func
        return func
    return add_hook

# Fix 9-slice co-ordinates
@hook('background9')
@hook('image', passive=True)
@hook('animated_image', passive=True)
def _background9_hook(params):
    if params[-1] != ('middle', 'string'):
        assert ('middle', 'string') not in params
        return

    params[-1] = param = []
    param.append(('middle_x', 'number'))
    yield params
    param.append(('middle_y', 'number'))
    yield params
    param.append(('middle_x2', 'number'))
    param.append(('middle_y2', 'number'))
    yield params
    del params[-1]

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

# Fix dropdown
@hook('dropdown', passive=True)
def _scroll_container_hook(params):
    if isinstance(params[1][0], str):
        params[1] = [('w', 'number'), ('h', 'number')]
    else:
        params[1] = ('w', 'number')

    # Hooks have to return generators
    return ()

# Fix textlist
@hook('textlist', passive=True)
def _textlist_hook(params):
    if len(params) > 5:
        yield params[:5]
    return ()

# Swap order of tooltip definitions around to fix position parsing
@hook('tooltip', passive=True)
def _tooltip_hook(params):
    if params[0][0] == 'gui_element_name':
        params[0] = [('x', 'number'), ('y', 'number')]
        params.insert(1, [('w', 'number'), ('h', 'number')])
    else:
        params[0] = ('gui_element_name', 'string')
        del params[1]
    return ()

# Work around inconsistent documentation for model[]
@hook('model')
def _model_hook(params):
    # Make textures a list
    assert params[4] == ('textures', 'string')
    params[4] = [(('textures', 'string'), '...')]

    # Fix rotation
    assert params[5] == [('rotation_x', 'string'), ('y', 'number')]
    params[5] = [('rotation_x', 'number'), ('rotation_y', 'number')]

    # Convert frame_loop_range to frame_loop_{begin,end}
    assert params[8] == ('frame_loop_range', 'string')
    params[8] = [('frame_loop_begin', 'number'), ('frame_loop_end', 'number')]

    # Add optional parameters
    for i in range(5, len(params) + 1):
        yield params[:i]

# Parse image_button/image_button_exit like the source code does
# image_button_exit[] can have the extra parameters as well and
# pressed_texture_name is optional if noclip and drawborder are specified.
@hook('image_button')
@hook('image_button_exit')
def _image_button_hook(params):
    if len(params) != 5:
        assert len(params) == 8
        return

    yield params
    params.append(('noclip', 'boolean'))
    params.append(('drawborder', 'boolean'))
    yield params
    params.append(('pressed_texture_name', 'string'))
    yield params


# Work around tabheader's documentation
@hook('tabheader')
def _tabheader_hook(params):
    yield params
    if len(params) == 6:
        assert params[4:] == [
            ('transparent', 'boolean'),
            ('draw_border', 'boolean'),
        ]
        yield params[:4]


# Support MultiCraft's non-standard scrollbar styling
# WARNING: This may be removed or broken without notice
@hook('scrollbar')
def _scrollbar_hook(params):
    assert len(params) == 5
    yield params

    params.append([
        ('scrollbar_bg', 'string'), ('slider', 'string'),
        ('arrow_up', 'string'), ('arrow_down', 'string')
    ])
    yield params

_param_re = re.compile(r'^\* `([^`]+)`(?: and `([^`]+)`)?:? ')
def _raw_parse(data):
    # Get everything from the elements heading to the end of the next heading
    data = data.split('\nElements\n--------\n', 1)[-1].split('\n----', 1)[0]

    # Remove the next heading
    data = data.rsplit('\n', 1)[0]

    # Get element data
    for elem_data in data.split('\n### '):
        lines = elem_data.split('\n')
        raw_elem = lines.pop(0)
        if not raw_elem.startswith('`') or not raw_elem.endswith('`'):
            continue

        name, params = raw_elem[1:-2].split('[', 1)
        if params:
            params = _fix_param(params.split(';'))
        else:
            params = []

        if name in _hooks:
            for p in reversed(tuple(map(copy.deepcopy, _hooks[name](params)))):
                yield name, p
            if name not in _passive_hooks:
                continue

        # Optional parameters
        optional_params = set()
        for line in lines:
            match = _param_re.match(line)
            if not match or 'optional' not in line.lower():
                continue

            optional_params.add(_fix_param_name(match.group(1)))
            if p2 := match.group(2):
                optional_params.add(_fix_param_name(p2))

        # if optional_params:
        #     print('Optional', name, optional_params)

        # Convert the optional parameters into a format formspec_ast can
        # understand without major changes
        while True:
            yield name, params

            if not params:
                break
            last_param = params[-1]
            if (not isinstance(last_param, tuple) or
                    not isinstance(last_param[0], str) or
                    last_param[0] not in optional_params):
                break
            # print('Optional', name, last_param)
            params = params[:-1]

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

URL = 'https://github.com/minetest/minetest/raw/master/doc/lua_api.md'
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

_yaml_comment = """
#
# This file is automatically generated by make_elements.py and isn't actually
# used by formspec_ast, however it is useful for comparing changes across
# lua_api versions.
#

"""

def main():
    dirname = os.path.dirname(__file__)
    filename = os.path.join(dirname, 'elements.lua')
    data = fetch_and_parse()

    # Horrible code to create elements.yaml
    filename2 = os.path.join(dirname, 'elements.yaml')
    print('Writing to ' + filename2 + '...')
    with open(filename2, 'w') as f:
        f.write(_yaml_comment.lstrip())
        # Yuck - Unparsing then re-parsing the data as JSON is the easiest way
        # I can think of to convert tuples to lists.
        ruamel.yaml.dump(json.loads(json.dumps(data)), f)

    print('Writing to ' + filename + '...')
    with open(filename, 'w') as f:
        f.write(_comment.lstrip())
        f.write(lua_dump.serialize_readonly(data))
        f.write('\n')
    print('Done.')

if __name__ == '__main__':
    main()
