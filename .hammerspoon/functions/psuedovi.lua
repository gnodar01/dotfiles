_viEnabled = false

function _thunk_emit(mods, key)
  function _emit()
    hs.eventtap.keyStroke(mods, key)
  end
  return _emit
end

function _thunk_emit_chords(chords)
  function _emit()
    for _, chord in ipairs(chords) do
      hs.eventtap.keyStroke(chord[1], chord[2])
    end
  end
  return _emit
end

-- mod is a single modifier string
-- seq is a table of keys to press while mod is held
function _thunk_emit_seq(mod, seq)
  function _emit()
    hs.eventtap.event.newKeyEvent(mod, true):post()
    for _, key in ipairs(seq) do
      hs.eventtap.event.newKeyEvent(key, true):post()
      hs.eventtap.event.newKeyEvent(key, false):post()
    end
    hs.eventtap.event.newKeyEvent(mod, false):post()
  end
  return _emit
end

_viKeys = {
  h = hs.hotkey.new(nil, 'h', _thunk_emit(nil, 'left')),
  l = hs.hotkey.new(nil, 'l', _thunk_emit(nil, 'right')),
  j = hs.hotkey.new(nil, 'j', _thunk_emit(nil, 'down')),
  k = hs.hotkey.new(nil, 'k', _thunk_emit(nil, 'up')),


  e = hs.hotkey.new(nil, 'e', _thunk_emit('alt', 'right')),
  --w = hs.hotkey.new(nil, 'w', _thunk_emit_chords({
  --  {'alt', 'right'},
  --  {'alt', 'right'},
  --  {'alt', 'left'}
  --}))
  w = hs.hotkey.new(nil, 'w', _thunk_emit_seq(
    'alt', {'right', 'right', 'left'}
  ))
}

function _registerViKeys()
  print('registering vi keys')
  for _,v in pairs(_viKeys) do
    v:enable()
  end
end

function _unregisterViKeys()
  print('unregistering vi keys')
  for _,v in pairs(_viKeys) do
    v:disable()
  end
end

function vimode()
  if _viEnabled then
    print('disabling vi')
    _viEnabled = false
    _unregisterViKeys()
  else
    print('enabling vi')
    _viEnabled = true
    _registerViKeys()
  end
end
