#!/usr/bin/env python3
"""Temporarily focus/fullscreen windows and reload Hyprland, then restore state."""
import argparse
import json
import subprocess
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--live', action='store_true')
if not parser.parse_args().live:
    parser.error('Pass --live to allow temporary desktop changes and config reload')


def run(*args):
    p = subprocess.run(['hyprctl', *args], capture_output=True, text=True,
                       check=True, timeout=5)
    out = p.stdout.strip()
    if 'error' in out.lower():
        raise RuntimeError(out)
    return out


def js(command):
    return json.loads(run(command, '-j'))


def focus(w):
    run('dispatch', 'hl.dsp.focus({window="address:' + w['address'] + '"})')


def toggle():
    run('dispatch', 'hl.dsp.window.fullscreen({mode="fullscreen"})')


def submap():
    return run('repl', 'return "[" .. hl.get_current_submap() .. "]"')


def check(label, expected):
    for _ in range(40):
        got = submap()
        if got == expected:
            print('PASS:', label, flush=True)
            return
        time.sleep(.05)
    raise AssertionError(f'{label}: got {got}, expected {expected}')


def restore(w):
    focus(w)
    run('dispatch', 'hl.dsp.window.fullscreen_state({internal=' +
        str(w['fullscreen']) + ',client=' + str(w['fullscreenClient']) + '})')


old = js('activewindow')
if not old or old.get('class') == 'rustdesk':
    raise SystemExit('Focus a local non-RustDesk window before running this test.')
remote = next((w for w in js('clients') if w['class'] == 'rustdesk'
               and 'Remote Desktop' in w['title']), None)
if remote is None:
    raise SystemExit('Open a RustDesk remote desktop session first.')
if run('repl', 'return tostring(_G.omarchy_rustdesk_passthrough ~= nil)') != 'true':
    raise SystemExit('Enable the packaged plugin before running this test.')
if submap() != '[]':
    raise SystemExit('Leave any active Hyprland submap before running this test.')

try:
    focus(remote)
    run('dispatch', 'hl.dsp.window.fullscreen_state({internal=0,client=0})')
    check('windowed session keeps local shortcuts', '[]')
    toggle()
    check('fullscreen enters passthrough', '[rustdesk-fullscreen]')
    binds = [b for b in js('binds') if b['submap'] == 'rustdesk-fullscreen']
    assert len(binds) == 1 and binds[0]['key'] == 'F' and binds[0]['modmask'] == 64
    toggle()
    check('fullscreen exit restores local shortcuts', '[]')
    toggle()
    check('fullscreen re-entry', '[rustdesk-fullscreen]')
    focus(old)
    check('focus away restores local shortcuts', '[]')
    focus(remote)
    check('focus return restores passthrough', '[rustdesk-fullscreen]')
    run('reload', 'config-only')
    time.sleep(.3)
    check('reload restores passthrough', '[rustdesk-fullscreen]')
    binds = [b for b in js('binds') if b['submap'] == 'rustdesk-fullscreen']
    assert len(binds) == 1, 'Reload duplicated bindings'
    toggle()
    check('exit works after reload', '[]')
finally:
    # Attempt both restorations even if the user closes one test window.
    for window in (remote, old):
        try:
            restore(window)
        except (subprocess.SubprocessError, RuntimeError) as exc:
            print('Could not restore a window:', exc)
    print('Configuration errors:', run('configerrors') or 'none')
